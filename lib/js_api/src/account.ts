import {FlutterJS} from "./service/flutterConnectService";
import {appState} from '@reef-defi/react-lib';
import {map} from "rxjs/operators";

export const innitApi = (flutterJS: FlutterJS) => {
    appState.currentSelectedAddress$.subscribe((addr) => {
        flutterJS.postToFlutterStream('appState.currentAddress', addr);
    });
    (window as any).account = {
        selectedSigner$: appState.selectedSigner$.pipe(
            map(sig => ({
                address: sig.address,
                name: sig.name,
                balance: sig.balance.toString(),
                isEvmClaimed: sig.isEvmClaimed
            }))
        )
    }
}

