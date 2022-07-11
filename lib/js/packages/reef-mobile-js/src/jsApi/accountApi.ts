import {appState} from '@reef-defi/react-lib';
import {map} from "rxjs/operators";
import {FlutterJS} from "flutter-js-bridge";

export const innitApi = (flutterJS: FlutterJS) => {

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
    };
}

