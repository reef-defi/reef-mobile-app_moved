import {reefState, ReefAccount, network, tokenUtil, getAccountSigner} from '@reef-chain/util-lib';
import {catchError, combineLatest, map, switchMap, take, tap} from "rxjs/operators";
import {Contract} from "ethers";
import {Provider, Signer as EvmSigner} from "@reef-defi/evm-provider";
import {ERC20} from "./abi/ERC20";
import {firstValueFrom, Observable, of} from "rxjs";
import {findAccount} from "./signApi";
import Signer from "@reef-defi/extension-base/page/Signer";

const nativeTransfer = async (amount: string, destinationAddress: string, provider: Provider, signer: ReefAccount, signingKey: Signer): Promise<any> => {
    return await provider.api.tx.balances
        .transfer(destinationAddress, amount)
        .signAndSend(signer.address, {signer: signingKey});
};

const nativeTransfer$ = (amount: string, destinationAddress: string, provider: Provider, signer: ReefAccount, signingKey: Signer): Observable<any> => {
    console.log('NATIVE TRRRRRRRR11')
    return new Observable((observer) => {
        const unsub = provider.api.tx.balances
            .transfer(destinationAddress, amount)
            .signAndSend(signer.address, {signer: signingKey}, (result) => {
                console.log(`Current status is ${result.status}`);

                if (result.status.isInBlock) {
                    console.log(`Transaction included at blockHash ${result.status.asInBlock}`);
                    observer.next(result.status.asInBlock);
                } else if (result.status.isFinalized) {
                    console.log(`Transaction finalized at blockHash ${result.status.asFinalized}`);
                    observer.next(result.status.asInBlock);
                    unsub();
                    observer.complete();
                }
            });
    })

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

async function reef20Transfer$(to: string, provider, tokenAmount: string, tokenContract) {
    const STORAGE_LIMIT = 2000;
    const toAddress = to.length === 48
        ? await getSignerEvmAddress(to, provider)
        : to;
    const ARGS = [toAddress, tokenAmount];
    return new Observable((observer) => {

        tokenContract ['transfer'](...ARGS, {
            customData: {
                storageLimit: STORAGE_LIMIT
            }
        }).then((tx) => {
            observer.next(tx);
            console.log('tx in progress =', tx.hash);
            tx.wait().then((receipt) => {
                console.log("SIGN AND SEND RESULT=", JSON.stringify(receipt));
                observer.next(receipt);
                observer.complete();
            });
        });

    });
}

export const initApi = (signingKey: Signer) => {
    (window as any).transfer = {
        sendObs: (from: string, to: string, tokenAmount: string, tokenDecimals: number, tokenAddress: string) => {
            console.log('making transfer tx')

            return reefState.accounts$.pipe(
                combineLatest([of(from)]),
                take(1),
                map(([sgnrs, addr]: [ReefAccount[], string]) => findAccount(sgnrs, addr)),
                combineLatest([reefState.selectedProvider$]),
                switchMap(async ([signer, provider]: [ReefAccount | undefined, Provider]) => {
                    console.log('START TRANSFERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR')
                    if (!signer) {
                        console.log(" transfer.send() - NO SIGNER FOUND",);
                        return {success: false, data: null};
                    }
                    const evmSigner = await getAccountSigner(signer.address, provider, signingKey);
                    if (!evmSigner) {
                        throw new Error('Signer not created');
                    }
                    // try {
                    if (tokenAddress === tokenUtil.REEF_ADDRESS && to.length === 48) {
                        console.log('transfering native REEF');
                        console.log(tokenAmount);
                        return nativeTransfer$(tokenAmount, to, provider, signer, signingKey).pipe(
                            map(data => ({
                                success: true,
                                type: 'native',
                                data
                            }))
                        );
                    } else {
                        const tokenContract = new Contract(tokenAddress, ERC20, evmSigner as EvmSigner);
                        console.log('transfering REEF20');
                        return reef20Transfer$(to, provider, tokenAmount, tokenContract);
                    }
                }),
                catchError(err => of({success: false, data: err.message}))
            );
        },
        sendPromise: async (from: string, to: string, tokenAmount: string, tokenDecimals: number, tokenAddress: string) => {
            console.log('making transfer tx returning observable')
            //console.log(`From: ${from} | To: ${to} | Token Amount: ${tokenAmount} | Token Decimals: ${tokenDecimals} | Token Address: ${tokenAddress}`)
            return firstValueFrom(reefState.accounts$.pipe(
                combineLatest([of(from)]),
                take(1),
                map(([sgnrs, addr]: [ReefAccount[], string]) => findAccount(sgnrs, addr)),
                combineLatest([reefState.selectedProvider$]),
                switchMap(async ([signer, provider]: [ReefAccount | undefined, Provider]) => {
                    if (!signer) {
                        console.log(" transfer.send() - NO SIGNER FOUND",);
                        return {success: false, data: null};
                    }
                    const STORAGE_LIMIT = 2000;
                    const evmSigner = await getAccountSigner(signer.address, provider, signingKey);
                    if (!evmSigner) {
                        throw new Error('Signer not created');
                    }
                    const tokenContract = new Contract(tokenAddress, ERC20, evmSigner as EvmSigner);
                    try {
                        if (tokenAddress === tokenUtil.REEF_ADDRESS && to.length === 48) {
                            console.log('transfering native REEF');
                            console.log(tokenAmount);
                            const res = await nativeTransfer(tokenAmount, to, provider, signer, signingKey);
                            console.log('NATIVE TR=', JSON.stringify(res));
                            return {success: res != null, data: res};
                        } else {
                            console.log('transfering REEF20');
                            console.log(tokenAmount);
                            const toAddress = to.length === 48
                                ? await getSignerEvmAddress(to, provider)
                                : to;
                            const ARGS = [toAddress, tokenAmount];
                            console.log("args=", ARGS);
                            const tx = await tokenContract ['transfer'](...ARGS, {
                                customData: {
                                    storageLimit: STORAGE_LIMIT
                                }
                            });
                            console.log('tx in progress =', tx.hash);
                            const receipt = await tx.wait();
                            console.log("SIGN AND SEND RESULT=", JSON.stringify(receipt));
                            return {success: true, data: receipt.transactionHash};
                        }
                    } catch (e) {
                        console.log('EEEEEE', e.message);
                        return {success: false, data: e.message};
                    }
                }),
                take(1)
            ));
        }
    }
}
