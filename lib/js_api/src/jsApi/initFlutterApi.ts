import * as accountApi from "./accountApi";
import {appState, AvailableNetworks, availableNetworks, Network, ReefSigner} from "@reef-defi/react-lib";
import {FlutterJS} from "./FlutterJS";

export const initFlutterApi = (flutterJS: FlutterJS) => {
    try {
        (window as any).jsApi = {
            initReefState: (network: AvailableNetworks, signers: ReefSigner[]) => {
                appState.initReefState({
                    network: availableNetworks[network],
                    signers
                });
            },
        };
        // testReefObservables();
        accountApi.innitApi(flutterJS);
    } catch (e) {
        console.log("INIT ERROR=", e.message);
    }
};
