import FlutterJS from "flutter-js-bridge";
import {injectMobileExtension} from "./injectExtension";

export const initDappApi = (flutterJS: FlutterJS) => {
    try {
        console.log("INIT DApp JS API");
        injectMobileExtension(flutterJS);
    } catch (e) {
        console.log("INIT DAPP ERROR=", e.message);
    }
};
