import {Observable} from "rxjs/dist/types";

export class FlutterJS {

    REEF_MOBILE_CHANNEL_NAME: string;
    private onInit?: (fltJS: FlutterJS) => void;

    constructor(onInitFn?: (fltJS: FlutterJS) => void) {
        if (onInitFn) {
            this.onInit = onInitFn;
        }
    }

    init(reefMobileChannelName: string, logIdentName: string, flutterSubscribeMethodName: string, apiReadyIdentName: string) {
        this.REEF_MOBILE_CHANNEL_NAME = reefMobileChannelName;
        this.overrideJSLogs(logIdentName);
        this.registerMobileSubscriptionMethod(flutterSubscribeMethodName);
        if (this.onInit) {
            this.onInit(this);
            this.postToFlutterStream(apiReadyIdentName, true);
        }
    }

    postToFlutterStream(subscriptionId, value, jsChannelName?: string) {
        return window[jsChannelName || this.REEF_MOBILE_CHANNEL_NAME].postMessage(JSON.stringify({
            id: subscriptionId,
            value
        }));
    }

    private overrideJSLogs(logIdentName: string) {
        window['console'].log = (...arg) => {
            this.postToFlutterStream(logIdentName, arg.map(a => {
                if (a instanceof Object) {
                    try {
                        return JSON.stringify(a);
                    } catch (err) {
                        return a.toString();
                    }
                }
                return a.toString();
            }).join(', '));
        }
    }

    private registerMobileSubscriptionMethod(flutterSubscribeMethodName: string) {
        window[flutterSubscribeMethodName] = (observableRefName, subscriptionId) => {
            const splitRefName = observableRefName.split('.');
            const observableRef = splitRefName.reduce((state, curr) => {
                if (!state) {
                    return undefined;
                }
                return state[curr] || undefined;
            }, window) as Observable<any>;

            if (!observableRef) {
                console.log("observable JS object ref not found= window." + observableRefName );
                return false;
            }
            //TODO unsubscribe
            observableRef.subscribe((value) => this.postToFlutterStream(subscriptionId, value));
            return true;
        };
    }
}
