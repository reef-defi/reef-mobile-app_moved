import {ReefAccount, reefState} from '@reef-chain/util-lib';
import {map, switchMap, take, withLatestFrom} from "rxjs/operators";
import {firstValueFrom, of} from "rxjs";
import {stringToHex} from "@polkadot/util";
import type {SignerPayloadJSON} from "@polkadot/types/types";
import type {HexString} from "@reef-defi/util/types";
import Signer from "@reef-defi/extension-base/page/Signer";

export const findAccount = (signers: ReefAccount[], address: string) => {
    return signers.find(s => s.address === address);
};

export const initApi = (signingKey: Signer) => {
    (window as any).signApi = {
        signRawPromise: (address: string, message: string | HexString) => {
            // TODO getting account is in many places - create method
            return firstValueFrom(reefState.accounts$.pipe(
                withLatestFrom([of(address)]),
                take(1),
                map(([sgnrs,addr]: [ReefAccount[]|undefined|null, string]) => findAccount(sgnrs, addr)),
                switchMap((signer: ReefAccount | undefined) => {
                    if (!signer) {
                        throw Error('signer not found addr=' + address);
                    }
                    return signingKey.signRaw({
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
            return firstValueFrom(reefState.accounts$.pipe(
                withLatestFrom([of(address)]),
                take(1),
                map(([sgnrs,addr]: [ReefAccount[], string]) => findAccount(sgnrs, addr)),
                switchMap((signer: ReefAccount | undefined) => {
                    if (!signer) {
                        throw Error('signer not found addr=' + address);
                    }
                    return signingKey.signPayload(payload);
                })
            ));
        }
    }
}
