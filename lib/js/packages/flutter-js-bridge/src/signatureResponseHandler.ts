import {Handler} from "./FlutterConnector";
import signer from "reef-mobile-js/src/jsApi/signing/signer";
import {SignerPayloadJSON, SignerPayloadRaw} from "@polkadot/types/types";

export default function signatureResponseMsgHandler(handlerObj: Handler, value:any): Promise<any> {
    let signaturePromise: Promise<string>;
    if (value==='_canceled') {
        return Promise.reject(new Error('_canceled'));
    }
    if (!value) {
        return Promise.reject(new Error('_empty-mnemonic-value'));
    }
    switch (handlerObj.messageType) {
        case 'pub(bytes.sign)':
            signaturePromise = signer.signRaw(value, (handlerObj.request as SignerPayloadRaw).data);
            break;
        case 'pub(extrinsic.sign)':
            signaturePromise = signer.signPayload(value, handlerObj.request as SignerPayloadJSON);
            break;
        default:
            throw Error('Unknown message type');
    }
    return signaturePromise.then((signature)=>({signature}));
}