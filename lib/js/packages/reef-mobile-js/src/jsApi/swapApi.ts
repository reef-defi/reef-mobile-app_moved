import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import {appState, ReefSigner} from '@reef-defi/react-lib';
import {map, switchMap, take} from "rxjs/operators";
import { Contract} from "ethers";
import { Signer as EvmProviderSigner } from "@reef-defi/evm-provider";
import { ReefswapRouter } from "./abi/ReefswapRouter";
import { ERC20 } from "./abi/ERC20";
import { firstValueFrom } from "rxjs";

const calculateDeadline = (minutes: number): number => Date.now() + minutes * 60 * 1000;
  
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

export const initApi = (flutterJS: FlutterJS) => {
    console.log ('init');
    (window as any).swap = {
        send: async (to: string, tokenAmount: string, tokenDecimals: number, tokenAddress: string) => {
            return firstValueFrom(appState.selectedSigner$.pipe(
                map((signer: ReefSigner) => {
                    return signer;
                }),
                switchMap(async (signer: ReefSigner | undefined) => {
                     // Input data TODO
                    const routerAddress = "0x0a2906130b1ecbffbe1edb63d5417002956dfd41";
                    const sellAmount = "1000000000000000000";
                    const minBuyAmount = "28624000000000000";
                    const token1Address = "0x0000000000000000000000000000000001000000";
                    const token2Address = "0x4676199AdA480a2fCB4b2D4232b7142AF9fe9D87";
                    const deadline = 1;
                    
                    const STORAGE_LIMIT = 2000; // TODO needed?

                    try {
                        // Approve token1
                        await approveTokenAmount(
                            token1Address,
                            sellAmount,
                            routerAddress,
                            signer.signer
                        );

                        // Swap
                        const swapRouter = new Contract(
                            routerAddress,
                            ReefswapRouter,
                            signer.signer
                        );
                        const tx = await swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                          sellAmount,
                          minBuyAmount,
                          [token1Address, token2Address],
                          signer.evmAddress,
                          calculateDeadline(deadline)
                        );

                        console.log ('tx', tx);
                        const receipt = await tx.wait();
                        console.log("SWAP RESULT=", receipt);
                        return receipt;
                    } catch (e) {
                        console.log(e);
                        return null;
                    }
                }),
                take(1)
            ));
        }
    }
}