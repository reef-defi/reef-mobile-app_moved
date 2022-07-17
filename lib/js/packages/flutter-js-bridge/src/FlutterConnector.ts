import type {MessageTypes, RequestTypes, ResponseTypes,} from '@reef-defi/extension-base/background/types';
import {FlutterJS} from "./FlutterJS";

export interface Handler {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    resolve: (data: any) => void;
    reject: (error: Error) => void;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    subscriber?: (data: any) => void;
    request: RequestTypes[MessageTypes];
    messageType: MessageTypes;
}

type Handlers = Record<string, Handler>;

type ResponseMsgHandler = (handlerObj: Handler, value: any) => Promise<any>;

export class FlutterConnector {

    flutterJS: FlutterJS;
    handlers: Handlers = {};
    idCounter = 0;
    responseFnName: string;
    flutterJsRequestFn: (flutterRequestIdent: string, value: any)=>void;
    responseMsgHandler: ResponseMsgHandler;

    constructor(flutterJS: FlutterJS, responseFnName: string, flutterJsRequestFn: (flutterRequestIdent: string, value: any)=>void, responseMsgHandler: ResponseMsgHandler) {
        this.flutterJS = flutterJS;
        this.responseFnName = responseFnName;
        this.flutterJsRequestFn = flutterJsRequestFn;
        this.responseMsgHandler=responseMsgHandler;
        this.registerResponseFn(flutterJS, responseFnName);
    }

    sendMessage<TMessageType extends MessageTypes>(message: TMessageType, request: RequestTypes[TMessageType], subscriber?: (data: any) => void): Promise<ResponseTypes[TMessageType]> {
        return new Promise((resolve, reject): void => {
            const flutterRequestIdent = `${this.responseFnName}.${Date.now()}.${++this.idCounter}`;
            this.handlers[flutterRequestIdent] = {reject, resolve, subscriber, request, messageType: message};
            this.flutterJsRequestFn(flutterRequestIdent, request);
        });
    }

    receiveMessage(flutterRequestIdent: string, value: any) {
        const handlerObj = this.handlers[flutterRequestIdent];
        if (handlerObj) {
            if (!value) {
                console.log("SIGNATURE REQUEST REJECTED=", flutterRequestIdent);
                handlerObj.reject(new Error('Signature canceled'));
                return;
            }
            let signaturePromise = this.responseMsgHandler(handlerObj, value);

            signaturePromise.then((signature) => {
                handlerObj.resolve({signature});
            });
        }
    }

    private registerResponseFn(flutterJS: FlutterJS, responseFnName: string) {
        const self = this;
        window[responseFnName] = (flutterRequestIdent: string, value?: any)=> {
            self.receiveMessage(flutterRequestIdent, value||null);
        }
    }
}
