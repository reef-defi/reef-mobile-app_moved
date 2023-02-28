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

type RequestMsgHandler = (flutterRequestIdent: string, actionIdent: MessageTypes, value: any) => void;
type ResponseMsgHandler = (handlerObj: Handler, value: any) => Promise<any>;

export class FlutterConnector {

    flutterJS: FlutterJS;
    handlers: Handlers = {};
    idCounter = 0;
    responseFnName: string;
    flutterJsRequestFn: RequestMsgHandler;
    responseMsgHandler: ResponseMsgHandler;

    constructor(flutterJS: FlutterJS, responseFnName: string, flutterJsRequestFn: RequestMsgHandler, responseMsgHandler: ResponseMsgHandler) {
        this.flutterJS = flutterJS;
        this.responseFnName = responseFnName;
        this.flutterJsRequestFn = flutterJsRequestFn;
        this.responseMsgHandler = responseMsgHandler;
        this.registerResponseFn(flutterJS, responseFnName);
    }

    sendMessage<TMessageType extends MessageTypes>(messageType: TMessageType, request: RequestTypes[TMessageType], subscriber?: (data: any) => void): Promise<ResponseTypes[TMessageType]> {
        return new Promise((resolve, reject): void => {
            const flutterRequestIdent = `${this.responseFnName}.${Date.now()}.${++this.idCounter}`;
            this.handlers[flutterRequestIdent] = {reject, resolve, subscriber, request, messageType};
            this.flutterJsRequestFn(flutterRequestIdent, messageType, request);
        });
    }

    receiveMessage(flutterRequestIdent: string, value: any) {
        const handlerObj = this.handlers[flutterRequestIdent];
        if (handlerObj) {
            let handlerPromise = this.responseMsgHandler(handlerObj, value);
            handlerPromise.then(handlerObj.resolve, handlerObj.reject);
        }
    }

    private registerResponseFn(flutterJS: FlutterJS, responseFnName: string) {
        const self = this;
        window[responseFnName] = (flutterRequestIdent: string, value?: any)=> {
            self.receiveMessage(flutterRequestIdent, value||null);
        }
    }
}
