import {Handler} from "./FlutterConnector";

export default function dAppResponseMsgHandler(handlerObj: Handler, value: any): Promise<any> {
    let dAppPromise: Promise<any>;
    switch (handlerObj.messageType) {
        case 'pub(bytes.sign)':
            console.log("TODO handle response");
            break;
        case 'pub(extrinsic.sign)':
            console.log("TODO handle response");
            break;
        case 'pub(phishing.redirectIfDenied)':
            dAppPromise = Promise.resolve(false);
            break;
        case 'pub(authorize.tab)':
            dAppPromise = value===true||value==='true'?Promise.resolve(true):Promise.reject('Not approved');
            break;
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
