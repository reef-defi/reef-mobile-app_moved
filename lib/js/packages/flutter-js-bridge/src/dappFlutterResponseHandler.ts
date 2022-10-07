import {Handler} from "./FlutterConnector";
import type {InjectedAccount, InjectedMetadataKnown} from "@reef-defi/extension-inject/types";

export default function dAppResponseMsgHandler(handlerObj: Handler, value: any): Promise<any> {
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
            return Promise.resolve(JSON.parse(value) as InjectedAccount[]);
        case 'pub(accounts.subscribe)':
            return Promise.resolve(value==='true');
        case 'pub(metadata.list)':
            return Promise.resolve(JSON.parse(value) as InjectedMetadataKnown[]);
        case 'pub(metadata.provide)':
            return Promise.resolve(value==='true');
        default:
            throw Error('Unknown message type from flutter DApp response');
    }
}
