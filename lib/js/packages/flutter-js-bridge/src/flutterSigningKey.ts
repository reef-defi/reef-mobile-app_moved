import FlutterSigner from "reef-mobile-js/src/jsApi/signing/FlutterSigner";
import FlutterJS from "flutter-js-bridge";
import {getSignatureSendRequest} from "./sendRequestSignature";

let signingKey;

export const getFlutterSigningKey = (flutterJS: FlutterJS) => {
    if (!signingKey) {
        let sendRequest = getSignatureSendRequest(flutterJS);
        signingKey = new FlutterSigner(sendRequest);
    }
    return signingKey;
}
