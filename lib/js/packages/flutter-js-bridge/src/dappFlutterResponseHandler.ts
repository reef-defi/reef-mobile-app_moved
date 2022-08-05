import {Handler} from "./FlutterConnector";
import type {InjectedAccount} from "@reef-defi/extension-inject/types";

export default function dAppResponseMsgHandler(handlerObj: Handler, value: any): Promise<any> {
    let dAppPromise: Promise<any>;
    switch (handlerObj.messageType) {
        case 'pub(bytes.sign)':
            return Promise.resolve(JSON.parse(value));
        case 'pub(extrinsic.sign)':
            return Promise.resolve(JSON.parse(value));
        case 'pub(phishing.redirectIfDenied)':
            return Promise.resolve(value!=='false' );
        case 'pub(authorize.tab)':
            return Promise.resolve(value==='true');
        case 'pub(accounts.list)':
            dAppPromise = Promise.resolve(JSON.parse(value) as InjectedAccount[]); //Promise<InjectedAccount[]>
            break;
        case 'pub(accounts.subscribe)':
            // TODO handle subscribtion callback
            dAppPromise = Promise.resolve(null);
            break;
        case 'pub(metadata.list)':
            // TODO return metadata
            dAppPromise = Promise.resolve([]); // Promise<InjectedMetadataKnown[]>
            break;
        case 'pub(metadata.provide)':
            // TODO return metadata
            dAppPromise = Promise.resolve([]); // Promise<boolean>
            break;
        default:
            throw Error('Unknown message type from flutter DApp response');
    }
    return dAppPromise;
}
