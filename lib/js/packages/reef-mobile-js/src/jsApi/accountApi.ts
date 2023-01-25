import {AddressName, ReefSigner, reefState} from '@reef-chain/util-lib';
import {map, switchMap, take} from "rxjs/operators";
import type {InjectedAccountWithMeta} from "@reef-defi/extension-inject/types";
import {firstValueFrom} from 'rxjs';
import {REEF_EXTENSION_IDENT} from "@reef-defi/extension-inject";
import { resolveEvmAddress as utilsResolveEvmAddr} from "@reef-defi/evm-provider/utils";
import {Provider} from "@reef-defi/evm-provider";

export const buildAccountWithMeta = async (name: string, address: string): Promise<InjectedAccountWithMeta> => {
    const acountWithMeta: InjectedAccountWithMeta = {
        address,
        meta: {
            name,
            source: REEF_EXTENSION_IDENT
        }
    };

    return acountWithMeta;
}

export const innitApi = () => {

    (window as any).account = {
        /*selectedSigner$: reefState.selectedAccount$.pipe(
            map(sig =>sig? ({
                address: sig.address,
                name: sig.name,
                balance: sig.balance,
                isEvmClaimed: sig.isEvmClaimed
            }):null),
        ),
        availableSigners$: reefState.accounts$*//*.pipe(
            map((signers: ReefAccount[]) =>
                signers.map(sig => ({
                    address: sig.address,
                    evmAddress: sig.evmAddress,
                    name: sig.name,
                    balance: sig.balance,
                    isEvmClaimed: sig.isEvmClaimed
                })
            )),
        ),*/
        updateAccounts: async (accounts: AddressName[]) => {
            let accountsWithMeta: InjectedAccountWithMeta[] = await Promise.all(
                accounts.map(async (account: AddressName) => {
                    return await buildAccountWithMeta(account.name, account.address);
                }
            ));
            console.log("updateAccounts=",accountsWithMeta);
            reefState.setAccounts(accountsWithMeta);
        },
        claimEvmAccount: async (nativeAddress: string) => {
            return firstValueFrom(reefState.accounts$.pipe(
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
        },

        resolveEvmAddress:async(nativeAddress:string)=>{
            const provider = await firstValueFrom(reefState.selectedProvider$);
            return utilsResolveEvmAddr(provider,nativeAddress);
        }

    };
}

