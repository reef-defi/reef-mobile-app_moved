import {injectExtension} from "@reef-defi/extension-inject";
import FlutterJS from "flutter-js-bridge";
import {getDAppSendRequestFn} from "flutter-js-bridge/src/sendRequestDApp";
import Injected from "@reef-defi/extension-base/page/Injected";
let sendDAppMessage;

export function injectMobileExtension(flutterJS: FlutterJS) {
    sendDAppMessage = getDAppSendRequestFn(flutterJS);
    redirectIfPhishing().then(( gotRedirected) => {
        console.log('REDIRRRRRR', gotRedirected)
        if (!gotRedirected) {
            inject();
        }
    }).catch((e) => {
        console.warn(`Unable to determine if the site is in the phishing list: ${(e as Error).message}`);
        inject();
    });
}

function redirectIfPhishing(): Promise<boolean>{
    // const isInDenyList = await checkIfDenied(url);
    return sendDAppMessage('pub(phishing.redirectIfDenied)', { url: window.location.href });
    // return Promise.resolve(resolve);
}

async function enable (origin: string): Promise<Injected> {
    console.log('EEEEEE',origin)
    const res = await sendDAppMessage('pub(authorize.tab)', { origin });
    console.log("ENABLE=",res);
    return new Injected(sendDAppMessage);
}

function inject () {
    injectExtension(enable, {
        name: 'reef-mobile-app',
        version: '0.0.1'// TODO process?.env?.PKG_VERSION as string
    });
}
