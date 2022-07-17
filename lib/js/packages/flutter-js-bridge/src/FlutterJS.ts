import {from, Observable} from "rxjs";
import {MessageTypes} from "@reef-defi/extension-base/background/types";

export class FlutterJS {

    REEF_MOBILE_CHANNEL_NAME: string;
    TX_SIGNATURE_CONFIRMATION_JS_FN_NAME: string;
    DAPP_REQ_CONFIRMATION_JS_FN_NAME: string;
    private txSignMsgIdent: string;
    private txDappMsgIdent: string;
    private onInit?: (fltJS: FlutterJS) => void;

    constructor(onInitFn?: (fltJS: FlutterJS) => void) {
        if (onInitFn) {
            this.onInit = onInitFn;
        }
    }

    init(reefMobileChannelName: string, logIdentName: string, flutterSubscribeMethodName: string, apiReadyIdentName: string,
         apiTxSignIdentName: string, txSignatureConfirmationJsFnName: string,
         apiDappMsgIdentName: string, dAppMsgConfirmationJsFnName: string,
    ) {
        this.REEF_MOBILE_CHANNEL_NAME = reefMobileChannelName;
        this.overrideJSLogs(logIdentName);
        this.registerMobileSubscriptionMethod(flutterSubscribeMethodName);
        this.initFlutterSignatureConfirmationBridge(apiTxSignIdentName, txSignatureConfirmationJsFnName);
        this.initFlutterDAppConfirmationBridge(apiDappMsgIdentName, dAppMsgConfirmationJsFnName)
        if (this.onInit) {
            this.onInit(this);
            this.postToFlutterStream(apiReadyIdentName, true);
        }
    }

    postToFlutterStream(subscriptionId, value, msgType: string='', jsChannelName?: string) {
        return window[jsChannelName || this.REEF_MOBILE_CHANNEL_NAME].postMessage(JSON.stringify({
            id: subscriptionId,
            msgType,
            value
        }));
    }

    flutterSignatureRequest(signatureIdent: string, msgType: MessageTypes, value: any) {
        window[this.REEF_MOBILE_CHANNEL_NAME].postMessage(JSON.stringify({
            id: this.txSignMsgIdent,
            msgType,
            value:{signatureIdent, value}
        }));
    }

    flutterDAppMsgRequest(signatureIdent: string, msgType: MessageTypes, value: any) {
        console.log("flutter REQQQ=",signatureIdent, value);
        window[this.REEF_MOBILE_CHANNEL_NAME].postMessage(JSON.stringify({
            id: this.txDappMsgIdent,
            msgType,
            value:{signatureIdent, value}
        }));
    }

    private initFlutterSignatureConfirmationBridge (apiTxSignIdentName: string, txSignatureConfirmationJsFnName: string) {
        this.txSignMsgIdent = apiTxSignIdentName;
        this.TX_SIGNATURE_CONFIRMATION_JS_FN_NAME = txSignatureConfirmationJsFnName;
    }

    private initFlutterDAppConfirmationBridge (apiDappMsgIdentName: string, confirmationJsFnName: string) {
        this.txDappMsgIdent = apiDappMsgIdentName;
        this.DAPP_REQ_CONFIRMATION_JS_FN_NAME = confirmationJsFnName;
    }

    private overrideJSLogs(logIdentName: string) {
        window['console'].log = (...arg) => {
            this.postToFlutterStream(logIdentName, arg.map(a => {
                if (a && a instanceof Object) {
                    try {
                        return JSON.stringify(a);
                    } catch (err) {
                    }
                }
                return a?.toString();
            }).join(', '));
        }
    }

    private registerMobileSubscriptionMethod(flutterSubscribeMethodName: string) {
        window[flutterSubscribeMethodName] = (observableRefName, subscriptionId) => {
            const isFn = observableRefName.indexOf('(');
            let observableRef;
            if (isFn > 0) {
                observableRef = (window as any).eval(observableRefName);
            } else {
                const splitRefName = observableRefName.split('.');
                observableRef = splitRefName.reduce((state, curr) => {
                    if (!state) {
                        return undefined;
                    }
                    return state[curr] || undefined;
                }, window) as Observable<any>;
            }

            if (!observableRef) {
                console.log("observable JS object ref not found= window." + observableRefName);
                return false;
            }
            if (!!observableRef.subscribe || !!observableRef.then) {
                // TODO unsubscribe
                from(observableRef).subscribe((value) => this.postToFlutterStream(subscriptionId, value));
            } else {
                this.postToFlutterStream(subscriptionId, observableRef);
            }
            return true;
        };
    }
}
