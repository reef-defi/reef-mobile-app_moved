import {from, Observable} from "rxjs";
import {MessageTypes} from "@reef-defi/extension-base/background/types";

export class FlutterJS {

    REEF_MOBILE_CHANNEL_NAME: string;
    TX_SIGNATURE_CONFIRMATION_JS_FN_NAME: string;
    DAPP_REQ_CONFIRMATION_JS_FN_NAME: string;
    private txSignStreamId: string;
    private txDappStreamId: string;
    private onInit?: (fltJS: FlutterJS) => void;

    constructor(onInitFn?: (fltJS: FlutterJS) => void) {
        if (onInitFn) {
            this.onInit = onInitFn;
        }
    }

    init(reefMobileChannelName: string, logStreamId: string, flutterSubscribeMethodName: string, apiReadyStreamId: string,
         apiTxSignStreamId: string, txSignatureConfirmationJsFnName: string,
         apiDappStreamId: string, dAppMsgConfirmationJsFnName: string,
    ) {
        this.REEF_MOBILE_CHANNEL_NAME = reefMobileChannelName;
        this.overrideJSLogs(logStreamId);
        this.registerMobileSubscriptionMethod(flutterSubscribeMethodName);
        this.initFlutterSignatureConfirmationBridge(apiTxSignStreamId, txSignatureConfirmationJsFnName);
        this.initFlutterDAppConfirmationBridge(apiDappStreamId, dAppMsgConfirmationJsFnName)
        if (this.onInit) {
            this.onInit(this);
            this.sendToFlutterStream(apiReadyStreamId, true);
        }
    }

    sendToFlutterStream(streamId, value, msgType: string='', reqId: string='', jsChannelName?: string) {
        return window[jsChannelName || this.REEF_MOBILE_CHANNEL_NAME].postMessage(JSON.stringify({
            streamId,
            msgType,
            reqId,
            value
        }));
    }

    sendFlutterSignatureRequest(reqId: string, msgType: MessageTypes, value: any) {
        window[this.REEF_MOBILE_CHANNEL_NAME].postMessage(JSON.stringify({
            streamId: this.txSignStreamId,
            msgType,
            reqId,
            value
        }));
    }

    sendFlutterDAppMsgRequest(reqId: string, msgType: MessageTypes, value: any) {
        let url = window.location.hostname;
        if(!url){
            url = 'localhost';
        }
        window[this.REEF_MOBILE_CHANNEL_NAME].postMessage(JSON.stringify({
            streamId: this.txDappStreamId,
            msgType,
            reqId,
            value,
            url
        }));
    }

    private initFlutterSignatureConfirmationBridge (apiTxSignStreamId: string, txSignatureConfirmationJsFnName: string) {
        this.txSignStreamId = apiTxSignStreamId;
        this.TX_SIGNATURE_CONFIRMATION_JS_FN_NAME = txSignatureConfirmationJsFnName;
    }

    private initFlutterDAppConfirmationBridge (apiDappMsgIdentName: string, confirmationJsFnName: string) {
        this.txDappStreamId = apiDappMsgIdentName;
        this.DAPP_REQ_CONFIRMATION_JS_FN_NAME = confirmationJsFnName;
    }

    private overrideJSLogs(logIdentName: string) {
        window['console'].log = (...arg) => {
            this.sendToFlutterStream(logIdentName, arg.map(a => {
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
                from(observableRef).subscribe((value) => this.sendToFlutterStream(subscriptionId, value));
            } else {
                this.sendToFlutterStream(subscriptionId, observableRef);
            }
            return true;
        };
    }
}
