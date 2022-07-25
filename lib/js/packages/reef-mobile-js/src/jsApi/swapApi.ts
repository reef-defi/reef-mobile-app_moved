import {appState, ReefSigner, Network} from '@reef-defi/react-lib';
import {map, switchMap, take} from "rxjs/operators";
import { Contract} from "ethers";
import { Signer as EvmProviderSigner } from "@reef-defi/evm-provider";
import { ReefswapRouter } from "./abi/ReefswapRouter";
import { ERC20 } from "./abi/ERC20";
import { firstValueFrom } from "rxjs";
import { calculateAmount, calculateAmountWithPercentage, calculateDeadline } from "./utils/math";

interface TokenWithAmount {
    address: string;
    amount: string;
    decimals: number;
}

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

export const initApi = () => {
    (window as any).swap = {
        send: async (signerAddress: string, token1: TokenWithAmount, token2: TokenWithAmount, settings: SwapSettings) => {
            const routerAddress = await firstValueFrom(appState.currentNetwork$.pipe(
                take(1),
                switchMap(async (network: Network) => {
                    return network.routerAddress;
                })
            ));

            return firstValueFrom(appState.signers$.pipe(
                take(1),
                map((reefSigners: ReefSigner[]) => {
                    return reefSigners.find((s)=>s.address===signerAddress);
                }),
                switchMap(async (reefSigner: ReefSigner | undefined) => {                    
                    if (!reefSigner) {
                        console.log("swap.send() - NO SIGNER FOUND",);
                        return false
                    }

                    settings = resolveSettings(settings);
                    const sellAmount = calculateAmount({ decimals: token1.decimals, amount: token1.amount });
                    const minBuyAmount = calculateAmountWithPercentage(
                        { decimals: token2.decimals, amount: token2.amount }, 
                        settings.slippageTolerance
                    );
                    const swapRouter = new Contract(
                        routerAddress,
                        ReefswapRouter,
                        reefSigner.signer
                    );

                    try {
                        // Approve token1
                        console.log("Waiting for confirmation of token approval...");
                        await approveTokenAmount(
                            token1.address,
                            sellAmount,
                            routerAddress,
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
            ));
        }
    }
}