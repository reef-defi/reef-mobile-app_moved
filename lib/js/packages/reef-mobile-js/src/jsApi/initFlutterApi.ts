import * as accountApi from "./accountApi";
import {appState, AvailableNetworks, availableNetworks, ReefSigner} from "@reef-defi/react-lib";
import {map, switchMap} from "rxjs/operators";
import {initFlutterSigningKey} from "./signing/flutterSigningKey";
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import {firstValueFrom } from "rxjs";
import {stringToHex} from '@polkadot/util';
import {SignerPayloadJSON} from "@polkadot/types/types";
import {ethers} from "ethers";
import {Signer} from "@reef-defi/evm-provider";
import type {InjectedAccountWithMeta} from "@reef-defi/extension-inject/types";

export interface Account {
    address: string;
    name: string;
};

export const initFlutterApi = async (flutterJS: FlutterJS) => {
    try {
        console.log("INIT FLUTTER JS API");
        const signingKey = initFlutterSigningKey(flutterJS);
        (window as any).jsApi = {
            initReefState: async (selNetwork: AvailableNetworks, accounts: Account[]) => {
                let accountsWithMeta: InjectedAccountWithMeta[] = await Promise.all(
                    accounts.map(async (account: Account) => {
                        return await buildAccountWithMeta(account.name, account.address);
                    }
                ));
                return appState.initReefState({
                    network: availableNetworks[selNetwork],
                    jsonAccounts: {accounts: accountsWithMeta, injectedSigner: signingKey}
                });
            },
            testReefSignerRawPromise: (address: string, message: string) => {
                return firstValueFrom(appState.signers$.pipe(
                    map((signers: ReefSigner[]) => {
                        console.log("ADDRESS=", address);
                        signers.forEach(signer => console.log(signer.address));
                        const signer = signers.find(s => s.address === address);
                        console.log("TEST SIGNER RAW=", signer.address);
                        return signer;
                    }),
                    switchMap((signer: ReefSigner | undefined) => {
                        return signer.signer.signingKey.signRaw({
                            address: signer.address,
                            data: stringToHex(message),
                            type: 'bytes'
                        }).then((res)=>{
                            console.log("SIGN RESULT=",res);
                            return res;
                        });
                    })
                ));
            },
            testReefSignerPayloadPromise: (address: string, payload: SignerPayloadJSON) => {
                return firstValueFrom(appState.signers$.pipe(
                    map((signers: ReefSigner[]) => {
                        console.log("ADDRESS=", address);
                        signers.forEach(signer => console.log(signer.address));
                        const signer = signers.find(s => s.address === address);
                        console.log("TEST SIGNER PAYLOAD=", signer.address);
                        return signer;
                    }),
                    switchMap((signer: ReefSigner | undefined) => {
                        return signer.signer.signingKey.signPayload(payload);
                    })
                ));
            }
        };
        // testReefObservables();
        accountApi.innitApi(flutterJS);

    } catch (e) {
        console.log("INIT ERROR=", e.message);
    }
};

export const buildAccountWithMeta = async (name: string, address: string): Promise<InjectedAccountWithMeta> => {
    const acountWithMeta: InjectedAccountWithMeta = {
        address,
        meta: {
            name,
            source: "ReefMobileWallet"
        }
    };

    return acountWithMeta;
}
