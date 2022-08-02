import { appState } from '@reef-defi/react-lib';
import { switchMap, take } from "rxjs/operators";
import { Contract} from "ethers";
import { Signer as EvmProviderSigner, Provider } from "@reef-defi/evm-provider";
import { ReefswapRouter } from "./abi/ReefswapRouter";
import { ERC20 } from "./abi/ERC20";
import { combineLatest, firstValueFrom } from "rxjs";
import { calculateAmount, calculateAmountWithPercentage, calculateDeadline, getInputAmount, getOutputAmount } from "./utils/math";
import { ReefswapFactory } from './abi/ReefswapFactory';
import { ReefswapPair } from './abi/ReefswapPair';

const EMPTY_ADDRESS = '0x0000000000000000000000000000000000000000';

interface SwapSettings {
    deadline: number;
    slippageTolerance: number;
}

const defaultSwapSettings: SwapSettings = {
    deadline: 1,
    slippageTolerance: 0.8
};

const resolveSettings = (
    { deadline, slippageTolerance }: SwapSettings,
  ): SwapSettings => ({
    deadline: Number.isNaN(deadline) ? defaultSwapSettings.deadline : deadline,
    slippageTolerance: Number.isNaN(slippageTolerance) ? defaultSwapSettings.slippageTolerance : slippageTolerance,
  });

const getREEF20Contract = async (address: string, signer: EvmProviderSigner): Promise<Contract> => {
    try {
        const contract = new Contract(address, ERC20, signer);
        // Check if contract exists and is ERC20
        await contract.name();
        await contract.symbol();
        await contract.decimals();
        return contract;
    } catch (error) {
        throw new Error("Unknown address");
    }
};

const approveTokenAmount = async (
    tokenAddress: string,
    sellAmount: string,
    routerAddress: string,
    signer: EvmProviderSigner
  ): Promise<void> => {
    const tokenContract = await getREEF20Contract(tokenAddress, signer);
    if (tokenContract) {
      await tokenContract.approve(routerAddress, sellAmount);
      return;
    }
    throw new Error(`Token contract does not exist addr=${tokenAddress}`);
  }

  const findPoolTokenAddress = async (
    address1: string,
    address2: string,
    signerOrProvider: EvmProviderSigner | Provider,
    factoryAddress: string,
  ): Promise<string> => {
    const reefswapFactory = new Contract(factoryAddress, ReefswapFactory, signerOrProvider)
    const address = await reefswapFactory.getPair(address1, address2);
    return address;
  };

export const initApi = () => {
    (window as any).swap = {
        // Executes a swap
        execute: async (signerAddress: string, token1: TokenWithAmount, token2: TokenWithAmount, settings: SwapSettings) => {
            console.log(token1, token2);
            return firstValueFrom(
                combineLatest([appState.currentNetwork$, appState.signers$]).pipe(
                    take(1),
                    switchMap(async ([network, reefSigners]) => {
                        const reefSigner = reefSigners.find((s)=>s.address===signerAddress);
                        if (!reefSigner) {
                            console.log("swap.send() - NO SIGNER FOUND",);
                            return false;
                        }
    
                        settings = resolveSettings(settings);
                        const sellAmount = calculateAmount({ decimals: token1.decimals, amount: token1.amount });
                        const minBuyAmount = calculateAmountWithPercentage(
                            { decimals: token2.decimals, amount: token2.amount }, 
                            settings.slippageTolerance
                        );
                        const swapRouter = new Contract(
                            network.routerAddress,
                            ReefswapRouter,
                            reefSigner.signer
                        );
    
                        try {
                            // Approve token1
                            console.log("Waiting for confirmation of token approval...");
                            await approveTokenAmount(
                                token1.address,
                                sellAmount,
                                network.routerAddress,
                                reefSigner.signer
                            );
                            console.log("Token approved");
    
                            // Swap
                            console.log("Waiting for confirmation of swap...");
                            const tx = await swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                              sellAmount,
                              minBuyAmount,
                              [token1.address, token2.address],
                              reefSigner.evmAddress,
                              calculateDeadline(settings.deadline)
                            );
                            const receipt = await tx.wait();
                            console.log("SWAP RESULT=", receipt);
    
                            return receipt;
                        } catch (e) {
                            console.log("ERROR swapping tokens", e);
                            return null;
                        }
                    }),
                    take(1)
                )
            );
        },
        // Returns pool reserves, if pool exists
        getPoolReserves: async (token1Address: string, token2Address: string) => {
            return firstValueFrom(
                combineLatest([appState.currentNetwork$, appState.currentProvider$]).pipe(
                    take(1),
                    switchMap(async ([network, provider]) => {
                        const poolAddress = await findPoolTokenAddress(
                            token1Address, token2Address, provider, network.factoryAddress);
                        console.log("poolAddress", poolAddress);
                        if (poolAddress === EMPTY_ADDRESS) {
                            console.log("swap.loadPool() - NO POOL FOUND",);
                            return false;
                        }
    
                        const poolContract = new Contract(poolAddress, ReefswapPair, provider);
                        const reserves = await poolContract.getReserves();
                        const address1 = await poolContract.token1();
                        const [finalReserve1, finalReserve2] = token1Address !== address1
                            ? [reserves[0], reserves[1]]
                            : [reserves[1], reserves[0]];
    
                        return {
                            reserve1: finalReserve1.toString(),
                            reserve2: finalReserve2.toString(),
                        };
                    }),
                    take(1)
                )
            );
        },
        /* 
        * buy == true
        *     tokenAmount: amount of token2 to buy
        *     returns amount of token1 required
        * buy == false
        *     tokenAmount: amount of token1 to sell
        *     returns amount of token2 received
        */
        getSwapAmount:(tokenAmount: string, buy: boolean, token1Reserve: TokenWithAmount, token2Reserve: TokenWithAmount) => {
            return buy ? getInputAmount(tokenAmount, token1Reserve, token2Reserve) : getOutputAmount(tokenAmount, token1Reserve, token2Reserve);
        }
    }
}