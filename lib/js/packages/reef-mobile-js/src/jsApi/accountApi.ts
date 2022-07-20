import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import {appState} from '@reef-defi/react-lib';
import {map} from "rxjs/operators";
import { Account, buildAccountWithMeta } from "./initFlutterApi";
import type {InjectedAccountWithMeta} from "@reef-defi/extension-inject/types";

export const innitApi = (flutterJS: FlutterJS) => {

    // return account.selectedSigner$ without big signer object from ReefSigner
    (window as any).account = {
        selectedSigner$: appState.selectedSigner$.pipe(
            map(sig => ({
                address: sig.address,
                name: sig.name,
                balance: sig.balance.toString(),
                isEvmClaimed: sig.isEvmClaimed
            })),
        ),
        availableSigners$: appState.signers$.pipe(
            map(signers =>
                signers.map(sig => ({
                    address: sig.address,
                    evmAddress: sig.evmAddress,
                    name: sig.name,
                    balance: sig.balance.toString(),
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
            appState.accountsJsonSubj.next(accountsWithMeta);
        },
    };
}

