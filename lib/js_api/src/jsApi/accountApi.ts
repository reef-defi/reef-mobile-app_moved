import {FlutterJS} from "./FlutterJS";
import {appState, rpc} from '@reef-defi/react-lib';
import {map, switchMap} from "rxjs/operators";
import FlutterSigner from "./signing/FlutterSigner";
import {FlutterSigningConnector, sendMessage} from "./signing/FlutterSigningConnector";
import {Signer, Provider} from '@reef-defi/evm-provider';

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

