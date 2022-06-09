import {Observable} from "rxjs";

export class FlutterJS {

    REEF_MOBILE_CHANNEL_NAME: string;

    init (reefMobileChannelName: string, logIdentName: string, flutterSubscribeMethodName: string) {
        this.REEF_MOBILE_CHANNEL_NAME = reefMobileChannelName;
        this.overrideJSLogs(logIdentName);
        this.registerMobileSubscriptionMethod(flutterSubscribeMethodName);
    }

    postToFlutterStream(subscriptionId, value, jsChannelName?: string) {
        return window[jsChannelName||this.REEF_MOBILE_CHANNEL_NAME].postMessage(JSON.stringify({id: subscriptionId, value}));
    }

    private overrideJSLogs(logIdentName: string) {
        window['console'].log = (...arg) => {
            this.postToFlutterStream(logIdentName, arg.map(a => {
                if (a instanceof Object) {
                    return JSON.stringify(a);
                }
                return a.toString();
            }).join(', '));
        }
    }

    private registerMobileSubscriptionMethod(flutterSubscribeMethodName: string) {
        window[flutterSubscribeMethodName] = (observableRefName, subscriptionId) => {
            const obs = window[observableRefName] as Observable<any>;
            obs?.subscribe((value) => this.postToFlutterStream(subscriptionId, value));
            return true;
        };
    }
}
