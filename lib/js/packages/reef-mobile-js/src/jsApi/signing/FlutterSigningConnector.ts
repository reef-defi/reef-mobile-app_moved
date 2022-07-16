import type {MessageTypes, RequestTypes, ResponseTypes,} from '@reef-defi/extension-base/background/types';
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import type {SignerPayloadRaw, SignerPayloadJSON} from "@polkadot/types/types";
import signer from './signer';

interface Handler {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    resolve: (data: any) => void;
    reject: (error: Error) => void;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    subscriber?: (data: any) => void;
    request: RequestTypes[MessageTypes];
    messageType: MessageTypes;
}

type Handlers = Record<string, Handler>;

export class FlutterSigningConnector {

    flutterJS: FlutterJS;
    handlers: Handlers = {};
    idCounter = 0;

    constructor(flutterJS: FlutterJS) {
        this.flutterJS = flutterJS;
        this.initSignatureConfirmationFn(flutterJS);
    }

    sendMessage<TMessageType extends MessageTypes>(message: TMessageType, request: RequestTypes[TMessageType], subscriber?: (data: unknown) => void): Promise<ResponseTypes[TMessageType]> {
        return new Promise((resolve, reject): void => {
            const signRequestIdent = `${Date.now()}.${++this.idCounter}`;
            this.handlers[signRequestIdent] = {reject, resolve, subscriber, request: request, messageType: message};
            this.flutterJS.flutterSignatureRequest(signRequestIdent, request);
        });
    }

    receiveMessage(signRequestIdent: string, mnemonic?: string) {
        const handlerObj = this.handlers[signRequestIdent];
        if (handlerObj) {
            if (!mnemonic) {
                console.log("SIGNATURE REQUEST REJECTED=", signRequestIdent);
                handlerObj.reject(new Error('Signature canceled'));
            }
            let signaturePromise: Promise<string>;
            switch(handlerObj.messageType) {
                case 'pub(bytes.sign)':
                    signaturePromise = signer.signRaw(mnemonic, (handlerObj.request as SignerPayloadRaw).data);
                    break;
                case 'pub(extrinsic.sign)':
                    signaturePromise = signer.signPayload(mnemonic, handlerObj.request as SignerPayloadJSON);
                    break;
                default: throw Error('Unknown message type');
            }

            signaturePromise.then((signature) => { 
                handlerObj.resolve({signature}); 
            });  
        }
    }

    private initSignatureConfirmationFn(flutterJS: FlutterJS) {
        window[flutterJS.TX_SIGNATURE_CONFIRMATION_JS_FN_NAME] = (signatureIdent: string, mnemonic: string) => {
            console.log("RECEIVED SIGN CONF=",signatureIdent);
            this.receiveMessage(signatureIdent, mnemonic);
        }
    }
}
