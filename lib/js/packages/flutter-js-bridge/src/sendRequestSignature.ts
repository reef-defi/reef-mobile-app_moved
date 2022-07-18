import {FlutterJS} from "./FlutterJS";
import {FlutterConnector, Handler} from "./FlutterConnector";
import signer from "reef-mobile-js/src/jsApi/signing/signer";
import {SignerPayloadJSON, SignerPayloadRaw} from "@polkadot/types/types";

let signatureSendRequestFn;

export const getSignatureSendRequest = (flutterJS: FlutterJS) => {
    if (!signatureSendRequestFn) {
        const fSignConnector = new FlutterConnector(
            flutterJS,
            flutterJS.TX_SIGNATURE_CONFIRMATION_JS_FN_NAME,
            flutterJS.sendFlutterSignatureRequest.bind(flutterJS),
            signatureResponseMsgHandler
        );
        signatureSendRequestFn = fSignConnector.sendMessage.bind(fSignConnector);
    }
    return signatureSendRequestFn;
}

function signatureResponseMsgHandler(handlerObj: Handler, value: any): Promise<any> {
    let signaturePromise: Promise<string>;
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
    return signaturePromise;
}
