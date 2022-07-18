import {FlutterJS} from "./FlutterJS";
import {FlutterConnector, Handler} from "./FlutterConnector";

let dAppSendRequestFn;

export const getDAppSendRequestFn = (flutterJS: FlutterJS) => {
    if (!dAppSendRequestFn) {
        const fSignConnector = new FlutterConnector(
            flutterJS,
            flutterJS.DAPP_REQ_CONFIRMATION_JS_FN_NAME,
            flutterJS.sendFlutterDAppMsgRequest.bind(flutterJS),
            dAppResponseMsgHandler
        );
        dAppSendRequestFn = fSignConnector.sendMessage.bind(fSignConnector);
    }
    return dAppSendRequestFn;
}

function dAppResponseMsgHandler(handlerObj: Handler, value: any): Promise<any> {
    let dAppPromise: Promise<any>;
    console.log('RESSS',value);
    switch (handlerObj.messageType) {
        case 'pub(phishing.redirectIfDenied)':
            dAppPromise = Promise.resolve(false);
            break;
        case 'pub(authorize.tab)':
            dAppPromise = Promise.resolve(false);
            break;
        case 'pub(accounts.list)':
            dAppPromise = Promise.resolve([]); //Promise<InjectedAccount[]>
            break;
        case 'pub(accounts.subscribe)':
            // TODO handle subscribtion callback
            dAppPromise = Promise.resolve(null);
            break;
        case 'pub(metadata.list)':
            dAppPromise = Promise.resolve([]); // Promise<InjectedMetadataKnown[]>
            break;
        case 'pub(metadata.provide)':
            dAppPromise = Promise.resolve([]); // Promise<boolean>
            break;
        default:
            throw Error('Unknown message type');
    }
    return dAppPromise;
}
