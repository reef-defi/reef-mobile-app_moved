import {appState, ReefSigner, utils} from '@reef-defi/react-lib';
import {map, switchMap, take} from "rxjs/operators";
import { Account, buildAccountWithMeta } from "./initFlutterApi";
import type {InjectedAccountWithMeta} from "@reef-defi/extension-inject/types";
import { firstValueFrom } from 'rxjs';

export const innitApi = () => {

    // return account.selectedSigner$ without big signer object from ReefSigner
    (window as any).account = {
        selectedSigner$: appState.selectedSigner$.pipe(
            map(sig =>sig? ({
                address: sig.address,
                name: sig.name,
                balance: sig.balance,
                isEvmClaimed: sig.isEvmClaimed
            }):null),
        ),
        availableSigners$: appState.signers$.pipe(
            map((signers: ReefSigner[]) =>
                signers.map(sig => ({
                    address: sig.address,
                    evmAddress: sig.evmAddress,
                    name: sig.name,
                    balance: sig.balance,
                    isEvmClaimed: sig.isEvmClaimed
                })
            )),
        ),
        updateAccounts: async (accounts: Account[]) => {
            let accountsWithMeta: InjectedAccountWithMeta[] = await Promise.all(
                accounts.map(async (account: Account) => {
                    return await buildAccountWithMeta(account.name, account.address);
                }
            ));
            console.log("updateAccounts=",accountsWithMeta);
            appState.accountsJsonSubj.next(accountsWithMeta);
        },
        claimEvmAccount: async (nativeAddress: string) => {
            return firstValueFrom(appState.signers$.pipe(
                take(1),
                map((signers: ReefSigner[]) => {
                    return signers.find((s)=> s.address === nativeAddress);
                }),
                switchMap(async (signer: ReefSigner | undefined) => {
                    if (!signer) {
                        console.log("account.claimEvmAccount() - NO SIGNER FOUND",);
                        return false
                    }

                    try {
                        await signer.signer.claimDefaultAccount();
                        console.log("account binded:", signer.address, signer.isEvmClaimed, signer.evmAddress);
                        return true;
                    } catch (e) {
                        console.log(' account.claimEvmAccount() - ', e);
                        return null;
                    }
                }),
                take(1)
            ));
        },
        toReefEVMAddressWithNotification: (evmAddress: string)=>{
            return utils.toReefEVMAddressWithNotification(evmAddress);
        }
    };
}

