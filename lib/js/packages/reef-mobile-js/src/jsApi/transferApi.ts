import {reefState, ReefAccount, network, tokenUtil, getAccountSigner} from '@reef-chain/util-lib';
import {combineLatest, map, switchMap, take} from "rxjs/operators";
import {Contract} from "ethers";
import { Provider , Signer as EvmSigner} from "@reef-defi/evm-provider";
import { ERC20 } from "./abi/ERC20";
import { firstValueFrom, of } from "rxjs";
import {findSigner} from "./signApi";
import Signer from "@reef-defi/extension-base/page/Signer";

const nativeTransfer = async (amount: string, destinationAddress: string, provider: Provider, signer: ReefAccount, signingKey: Signer): Promise<void> => {
    try {
        await provider.api.tx.balances
            .transfer(destinationAddress, amount)
            .signAndSend(signer.address, { signer: signingKey });
    } catch (e) {
        console.log(e);
    }
};

const getSignerEvmAddress = async (address: string, provider: Provider): Promise<string> => {
    if (address.length !== 48 || address[0] !== '5') {
        return address;
    }
    const evmAddress = await provider.api.query.evmAccounts.evmAddresses(address);
    const addr = (evmAddress as any).toString();

    if (!addr) {
        throw new Error('EVM address does not exist');
    }
    return addr;
};

export const initApi = (signingKey: Signer) => {
    (window as any).transfer = {
        send: async (from: string, to: string, tokenAmount: string, tokenDecimals: number, tokenAddress: string) => {
        console.log('making transfer tx')
        console.log(`From: ${from} | To: ${to} | Token Amount: ${tokenAmount} | Token Decimals: ${tokenDecimals} | Token Address: ${tokenDecimals}`)
            return firstValueFrom(reefState.accounts$.pipe(
                combineLatest([of(from)]),
                take(1),
                map(([sgnrs, addr]: [ReefAccount[], string]) => findSigner(sgnrs, addr)),
                combineLatest([reefState.selectedProvider$]),
                switchMap(async ([signer, provider]: [ReefAccount | undefined, Provider]) => {
                    if (!signer) {
                        console.log(" transfer.send() - NO SIGNER FOUND",);
                        return false
                    }
                    const STORAGE_LIMIT = 2000;
                    const evmSigner = await getAccountSigner(signer.address, provider, signingKey);
                    if (!evmSigner) {
                        throw new Error('Signer not created');
                    }
                    const tokenContract = new Contract(tokenAddress, ERC20, evmSigner as EvmSigner);
                    try {
                        if (tokenAddress === tokenUtil.REEF_ADDRESS && to.length === 48) {
                            console.log ('transfering native REEF');
                            console.log (tokenAmount);
                            await nativeTransfer(tokenAmount, to, provider, signer, signingKey);
                            console.log ('transfer success');
                            return true;
                        } else {
                            console.log ('transfering REEF20');
                            console.log (tokenAmount);
                            const toAddress = to.length === 48
                                ? await getSignerEvmAddress(to, provider)
                                : to;
                            const ARGS = [toAddress, tokenAmount];
                            console.log ("args=",ARGS);
                            const tx = await tokenContract ['transfer'] (...ARGS, {
                                customData: {
                                    storageLimit: STORAGE_LIMIT
                                }
                            });
                            console.log ('tx in progress =', tx.hash);
                            const receipt = await tx.wait();
                            console.log("SIGN AND SEND RESULT=", receipt.transactionHash);
                            console.log ('transfer success');
                            return receipt;
                        }
                    } catch (e) {
                        console.log('EEEEEE',e);
                        return null;
                    }
                }),
                take(1)
            ));
        }
    }
}
