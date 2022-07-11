import * as accountApi from "./accountApi";
import {appState, AvailableNetworks, availableNetworks, ReefSigner} from "@reef-defi/react-lib";
import {map, switchMap} from "rxjs/operators";
import type {InjectedAccountWithMeta} from "@reef-defi/extension-inject/types";
import {initFlutterSigningKey} from "./signing/flutterSigningKey";
import {FlutterJS} from "flutter-js-bridge";

export const initFlutterApi = (flutterJS: FlutterJS) => {
    try {
        console.log("INIT FLUTTER JS API");
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
                        return  signers.find(s => s.address === address);
                    }),
                    switchMap((signer: ReefSigner | undefined) => {
                        return signer.signer.signMessage("hello world").then((res)=>{
                            console.log("SIGN RESULT=",res);
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
