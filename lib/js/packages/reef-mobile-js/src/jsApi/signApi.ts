import {appState, ReefSigner} from '@reef-defi/react-lib';
import {map, switchMap, take} from "rxjs/operators";
import {firstValueFrom} from "rxjs";
import {stringToHex} from "@polkadot/util";
import type {SignerPayloadJSON} from "@polkadot/types/types";
import type {HexString} from "@reef-defi/util/types";

const findSigner = (signers: ReefSigner[], address: string) => {
    return signers.find(s => s.address === address);
};

export const initApi = () => {
    (window as any).signApi = {
        signRawPromise: (address: string, message: string | HexString) => {
            return firstValueFrom(appState.signers$.pipe(
                take(1),
                map((sgnrs: ReefSigner[]) => findSigner(sgnrs, address)),
                switchMap((signer: ReefSigner | undefined) => {
                    if (!signer) {
                        throw Error('signer not found addr=' + address);
                    }
                    return signer.signer.signingKey.signRaw({
                        address: signer.address,
                        data: message.startsWith('0x') ? message : stringToHex(message),
                        type: 'bytes'
                    }).then((res) => {
                        return res;
                    });
                })
            ));
        },
        signPayloadPromise: (address: string, payload: SignerPayloadJSON) => {
            return firstValueFrom(appState.signers$.pipe(
                take(1),
                map((sgnrs: ReefSigner[]) => findSigner(sgnrs, address)),
                switchMap((signer: ReefSigner | undefined) => {
                    if (!signer) {
                        throw Error('signer not found addr=' + address);
                    }
                    return signer.signer.signingKey.signPayload(payload);
                })
            ));
        }
    }
}
