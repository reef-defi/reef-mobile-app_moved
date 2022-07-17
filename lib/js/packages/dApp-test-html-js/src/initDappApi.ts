import FlutterJS from "flutter-js-bridge";
import {injectMobileExtension} from "./injectExtension";
import {getFlutterSigningKey} from "flutter-js-bridge/src/flutterSigningKey";

export const initDappApi = (flutterJS: FlutterJS) => {
    try {
        console.log("INIT DApp JS API");
        const flutterSigKey =  getFlutterSigningKey(flutterJS);
        injectMobileExtension(flutterJS, flutterSigKey);

    } catch (e) {
        console.log("INIT DAPP ERROR=", e.message);
    }
};
