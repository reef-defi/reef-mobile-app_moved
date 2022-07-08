import * as accountApi from "./accountApi";
import {appState, AvailableNetworks, availableNetworks, Network, ReefSigner} from "@reef-defi/react-lib";
import {FlutterJS} from "./FlutterJS";
import {map, switchMap} from "rxjs/operators";
import {Provider, Signer} from "@reef-defi/evm-provider";
import type {InjectedAccountWithMeta} from "@reef-defi/extension-inject/types";
import {initFlutterSigningKey} from "./signing/flutterSigningKey";

export const initFlutterApi = (flutterJS: FlutterJS) => {
    try {
        const signingKey = initFlutterSigningKey(flutterJS);
        (window as any).jsApi = {
            initReefState: (network: AvailableNetworks, accounts: InjectedAccountWithMeta[]) => {
                appState.initReefState({
                    network: availableNetworks[network],
                    jsonAccounts: {accounts, injectedSigner:signingKey}
                });
            },
            testReefSignerPromise: (address: string) => {
                return appState.signers$.pipe(
                    map((signers: ReefSigner[]) => {
                        const signer = signers.find(s => s.address === address);
                        console.log("ssss=",address ,signer?.address);
                        return signer;
                    }),
                    switchMap((signer: ReefSigner | undefined) => {
                        console.log("TEST SIGNER EVM=", signer?.signer.computeDefaultEvmAddress());
                        return signer.signer.signMessage("hello world").then((res)=>{
                            console.log("SIGNRES=",res);
                            return res;
                        });
                    })
                ).toPromise();
            }
        };
        // testReefObservables();
        accountApi.innitApi(flutterJS);

    } catch (e) {
        console.log("INIT ERROR=", e.message);
    }
};
