import {AddressName, getAccountSigner, ReefAccount, reefState, addressUtils} from '@reef-chain/util-lib';
import {combineLatest, map, switchMap, take} from "rxjs/operators";
import type {InjectedAccountWithMeta} from "@reef-defi/extension-inject/types";
import {firstValueFrom} from 'rxjs';
import {REEF_EXTENSION_IDENT} from "@reef-defi/extension-inject";
import { resolveEvmAddress as utilsResolveEvmAddr, resolveAddress as utilsResolveToNativeAddress, isSubstrateAddress } from "@reef-defi/evm-provider/utils";
import {Provider} from "@reef-defi/evm-provider";
import Signer from "@reef-defi/extension-base/page/Signer";
import {ethers} from 'ethers';

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

export const innitApi = (signingKey: Signer) => {

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
                map((accounts: ReefAccount[]) => {
                    return accounts.find((s)=> s.address === nativeAddress);
                }),
                combineLatest([reefState.selectedProvider$]),
                switchMap(async ([signer, provider]: [ReefAccount | undefined, Provider]) => {
                    if (!signer) {
                        console.log("account.claimEvmAccount() - NO SIGNER FOUND",);
                        return false
                    }

                    try {

                        const evmSigner = await getAccountSigner(signer.address, provider, signingKey);
                        await evmSigner.claimDefaultAccount();
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
            return addressUtils.addReefSpecificStringFromAddress(evmAddress);
        },

        toReefEVMAddressNoNotification: (evmAddressMsg: string)=>{
            return addressUtils.removeReefSpecificStringFromAddress(evmAddressMsg);
        },

        resolveEvmAddress:async(nativeAddress:string)=>{
            const provider = await firstValueFrom(reefState.selectedProvider$);
            return utilsResolveEvmAddr(provider,nativeAddress);
        },

        resolveFromEvmAddress:async(evmAddress:string)=>{
            const provider = await firstValueFrom(reefState.selectedProvider$);
            const nativeAddress=await utilsResolveToNativeAddress(provider,evmAddress);
            return nativeAddress||null;
        },

        isValidEvmAddress: (address: string) =>  ethers.utils.isAddress(address),

        isValidSubstrateAddress: (address: string) => isSubstrateAddress(address),
    };
}

