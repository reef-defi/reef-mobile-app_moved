import * as accountApi from "./accountApi";
import {appState, availableNetworks, Network, ReefSigner} from "@reef-defi/react-lib";
import {BigNumber} from "ethers";
import {FlutterJS} from "./FlutterJS";

export const initFlutterApi = (flutterJS: FlutterJS) => {
    try {
        (window as any).jsApi = {
            availableNetworks:JSON.stringify(availableNetworks),
            initReefState: (network: Network, signers: ReefSigner[]) => {
                console.log("IIIIII=",network.name);
                /*appState.initReefState({
                    network,
                    signers
                });*/
            }
        };
        // testReefObservables();
        accountApi.innitApi(flutterJS);
        /*appState.initReefState({
            network: availableNetworks.testnet,
            signers: [{
                name: 'test',
                signer: {} as Signer,
                balance: BigNumber.from('0'),
                address: '5EUWG6tCA9S8Vw6YpctbPHdSrj95d18uNhRqgDniW3g9ZoYc',
                evmAddress: '',
                isEvmClaimed: false,
                source: 'mobileApp',
                genesisHash: undefined
            } as ReefSigner]
        });*/
    } catch (e) {
        console.log("INIT ERROR=", e.message);
    }
};
