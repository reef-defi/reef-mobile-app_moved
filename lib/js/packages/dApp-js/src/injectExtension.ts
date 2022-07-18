import {injectExtension} from "@reef-defi/extension-inject";
import RMInjected from "./ReefMobileInjected";
import FlutterJS from "flutter-js-bridge";
import {getDAppSendRequestFn} from "flutter-js-bridge/src/sendRequestDApp";
import Injected from "@reef-defi/extension-base/page/Injected";
import Signer from "@reef-defi/extension-base/page/Signer";

let sendDAppMessage;
let signingKey;

export function injectMobileExtension(flutterJS: FlutterJS, sigKey: Signer) {
    signingKey = sigKey;
    sendDAppMessage = getDAppSendRequestFn(flutterJS);
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
    return Promise.resolve(false);
}

async function enable (origin: string): Promise<Injected> {
    await sendDAppMessage('pub(authorize.tab)', { origin });
    return new RMInjected(sendDAppMessage, signingKey);
}

function inject () {
    injectExtension(enable, {
        name: 'reef-mobile-app',
        version: '0.0.1'// TODO process?.env?.PKG_VERSION as string
    });
}
