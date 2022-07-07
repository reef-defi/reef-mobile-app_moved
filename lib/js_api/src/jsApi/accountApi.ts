import {FlutterJS} from "./FlutterJS";
import {appState, rpc} from '@reef-defi/react-lib';
import {map, switchMap} from "rxjs/operators";
import FlutterSigner from "./account_manager/FlutterSigner";
import {FlutterSigningConnector, sendMessage} from "./account_manager/messaging";
import {Signer, Provider} from '@reef-defi/evm-provider';

export const innitApi = (flutterJS: FlutterJS) => {

    const fSignConnector = new FlutterSigningConnector(flutterJS);
    const fSigner = new FlutterSigner(fSignConnector.sendMessage.bind(fSignConnector));

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
        testReefSignerPromise: (address: string) => {
            return appState.currentProvider$.pipe(
                map((provider: Provider) => {
                    console.log("PROVIDER genHash=", provider.api.genesisHash);
                    return new Signer(provider, address, fSigner);
                }),
                switchMap((signer: Signer | undefined) => {
                    console.log("TEST SIGNER EVM=", signer?.computeDefaultEvmAddress());
                    return signer.signMessage("hello world").then((res)=>{
                        console.log("SIGNRES=",res);
                        return res;
                    });
                })
            ).toPromise();
        }
    };
}

