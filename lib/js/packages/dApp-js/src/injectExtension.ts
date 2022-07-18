import {injectExtension} from "@reef-defi/extension-inject";
import RMInjected from "./ReefMobileInjected";
import FlutterJS from "flutter-js-bridge";
import {getDAppSendRequestFn} from "flutter-js-bridge/src/sendRequestDApp";
import Injected from "@reef-defi/extension-base/page/Injected";
import Signer from "@reef-defi/extension-base/page/Signer";
import {getSignatureSendRequest} from "flutter-js-bridge/src/sendRequestSignature";
import FlutterSigner from "reef-mobile-js/src/jsApi/signing/FlutterSigner";

let sendDAppMessage;
let signingKey;

export function injectMobileExtension(flutterJS: FlutterJS) {
    sendDAppMessage = getDAppSendRequestFn(flutterJS);
    signingKey = new FlutterSigner(sendDAppMessage);
    redirectIfPhishing().then((gotRedirected) => {
        if (!gotRedirected) {
            inject();
        }
    }).catch((e) => {
        console.warn(`Unable to determine if the site is in the phishing list: ${(e as Error).message}`);
        inject();
    });
}

function redirectIfPhishing(){
    // const isInDenyList = await checkIfDenied(url);
    // TODO sendDAppMessage('pub(phishing.redirectIfDenied)', { url })
    return Promise.resolve(false);
}

async function enable (origin: string): Promise<Injected> {
    const res = await sendDAppMessage('pub(authorize.tab)', { origin });
    console.log("ENABLE=",res);
    return new RMInjected(sendDAppMessage, signingKey);
}

function inject () {
    injectExtension(enable, {
        name: 'reef-mobile-app',
        version: '0.0.1'// TODO process?.env?.PKG_VERSION as string
    });
}
