import {FlutterJS} from "./FlutterJS";
import {appState} from '@reef-defi/react-lib';
import {map} from "rxjs/operators";

export const innitApi = (flutterJS: FlutterJS) => {
    // post selected address as appState.currentAddress
    // appState.currentAddress$.subscribe({
    //     next: (addr) => flutterJS.postToFlutterStream('appState.currentAddress', addr)
    // });

    // account.selectedSigner$ without signer object from ReefSigner
    (window as any).account = {
        selectedSigner$: appState.selectedSigner$.pipe(
            map(sig => ({
                address: sig.address,
                name: sig.name,
                balance: sig.balance.toString(),
                isEvmClaimed: sig.isEvmClaimed
            }))
        )
    };
}

