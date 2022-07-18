import {Handler} from "./FlutterConnector";

export default function dAppResponseMsgHandler(handlerObj: Handler, value: any): Promise<any> {
    console.log('DAPP RESPONSE',handlerObj.messageType, ' VAL=', value);
    let dAppPromise: Promise<any>;
    switch (handlerObj.messageType) {
        case 'pub(bytes.sign)':
            console.log("TODO handle response");
            break;
        case 'pub(extrinsic.sign)':
            console.log("TODO handle response");
            break;
        case 'pub(phishing.redirectIfDenied)':
            return Promise.resolve(value!=='false' );
        case 'pub(authorize.tab)':
            return Promise.resolve(value==='true');
        case 'pub(accounts.list)':
            console.log("RES pub(accounts.list)=",value);
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
