import {FlutterJS} from "./FlutterJS";
import {FlutterConnector} from "./FlutterConnector";
import signatureResponseMsgHandler from "./signatureResponseHandler";

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
