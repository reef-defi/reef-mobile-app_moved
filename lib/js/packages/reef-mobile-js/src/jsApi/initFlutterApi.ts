import * as accountApi from "./accountApi";
import * as transferApi from "./transferApi";
import * as swapApi from "./swapApi";
import * as signApi from "./signApi";
import * as utilsApi from "./utilsApi";
import {appState, AvailableNetworks, availableNetworks, ReefSigner} from "@reef-defi/react-lib";
import {map, switchMap, take} from "rxjs/operators";
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import type {InjectedAccountWithMeta} from "@reef-defi/extension-inject/types";
import Signer from "@reef-defi/extension-base/page/Signer";
import {getSignatureSendRequest} from "flutter-js-bridge/src/sendRequestSignature";
import {INJECTED_EXT_IDENT} from "dapp/src/injectExtension";

export interface Account {
    address: string;
    name: string;
};

export const initFlutterApi = async (flutterJS: FlutterJS) => {
    try {
        console.log("INIT FLUTTER JS API");
        const signingKey = getFlutterSigningKey(flutterJS);
        (window as any).jsApi = {
            initReefState: async (selNetwork: AvailableNetworks, accounts: Account[]) => {
                let accountsWithMeta: InjectedAccountWithMeta[] = await Promise.all(
                    accounts.map(async (account: Account) => {
                        return await buildAccountWithMeta(account.name, account.address);
                    }
                ));
                // console.log("init reef state=",accountsWithMeta.length);
                const destroyFn = await appState.initReefState({
                    network: availableNetworks[selNetwork],
                    jsonAccounts: {accounts: accountsWithMeta, injectedSigner: signingKey}
                });
                // TODO check if it's really destroyed
                /*setTimeout((  )=>{
                    destroyFn();
                    console.log('destroyed')
                },5000)*/
                window.addEventListener("beforeunload", function(e){
                    console.log('DESTROY Reef Api');
                    destroyFn();
                }, false);
            }
        };
        // testReefObservables();
        accountApi.innitApi();
        transferApi.initApi(flutterJS);
        swapApi.initApi();
        signApi.initApi();
        utilsApi.initApi();
    } catch (e) {
        console.log("INIT ERROR=", e.message);
    }
};

export const buildAccountWithMeta = async (name: string, address: string): Promise<InjectedAccountWithMeta> => {
    const acountWithMeta: InjectedAccountWithMeta = {
        address,
        meta: {
            name,
            source: INJECTED_EXT_IDENT
        }
    };

    return acountWithMeta;
}


function getFlutterSigningKey (flutterJS: FlutterJS) {
        let sendRequest = getSignatureSendRequest(flutterJS);
        return  new Signer(sendRequest);
}
