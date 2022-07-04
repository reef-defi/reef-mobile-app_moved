import {FlutterJS} from "./FlutterJS";
import {appState, rpc} from '@reef-defi/react-lib';
import {map} from "rxjs/operators";
import FlutterSigner from "./account_manager/FlutterSigner";
import {sendMessage} from "./account_manager/messaging"

export const innitApi = (flutterJS: FlutterJS) => {
    // post selected address as appState.currentAddress
    // appState.currentAddress$.subscribe({
    //     next: (addr) => flutterJS.postToFlutterStream('appState.currentAddress', addr)
    // });

    const fSigner = new FlutterSigner(sendMessage);
    const provider = appState.currentProvider$


        // account.selectedSigner$ without signer object from ReefSigner
        (window as any).account = {
        selectedSigner$: appState.selectedSigner$.pipe(
            map(sig => ({
                address: sig.address,
                name: sig.name,
                balance: sig.balance.toString(),
                isEvmClaimed: sig.isEvmClaimed
            }))
        ),
        testReefSignerPromise: (address: string)=>{
            return appState.currentProvider$.toPromise()
                .then((provider)=>rpc.metaAccountToSigner({}, provider, fSigner))
                .then((signer: FlutterSigner|undefined)=>{
                    console.log("SIGNER=",signer?.signer);
                    return 'ok signer'
                })
        }
    };
}

