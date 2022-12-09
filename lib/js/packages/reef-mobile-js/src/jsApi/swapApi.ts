import { reefState } from '@reef-chain/util-lib';
import { switchMap, take } from "rxjs/operators";
import { Contract} from "ethers";
import { ReefswapRouter } from "./abi/ReefswapRouter";
import { combineLatest, firstValueFrom } from "rxjs";
import { calculateAmount, calculateAmountWithPercentage, calculateDeadline, getInputAmount, getOutputAmount } from "./utils/math";
import { approveTokenAmount } from './utils/tokenUtils';
import { getPoolReserves } from './utils/poolUtils';

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

export const initApi = () => {
    (window as any).swap = {
        // Executes a swap
        execute: async (signerAddress: string, token1: TokenWithAmount, token2: TokenWithAmount, settings: SwapSettings) => {
            return firstValueFrom(
                combineLatest([reefState.selectedNetwork$, reefState.accounts$]).pipe(
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
                combineLatest([appState.selectedNetwork$, appState.selectedProvider$]).pipe(
                    take(1),
                    switchMap(async ([network, provider]) => {
                        return getPoolReserves(token1Address, token2Address, provider, network.factoryAddress);
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
