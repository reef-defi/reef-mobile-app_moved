import type {MessageTypes, RequestTypes, ResponseTypes,} from '@reef-defi/extension-base/background/types';
import {FlutterJS} from "../FlutterJS";

interface Handler {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    resolve: (data: any) => void;
    reject: (error: Error) => void;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    subscriber?: (data: any) => void;
    messageToSign: string;
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
            this.handlers[signRequestIdent] = {reject, resolve, subscriber, messageToSign: message};
            console.log("TODO need to add account and check it in receiveMessage?");
            this.flutterJS.flutterSignatureRequest(signRequestIdent, message);
        });
    }

    receiveMessage(signRequestIdent: string, mnemonic?: string) {
        const handlerObj = this.handlers[signRequestIdent];
        if (handlerObj) {
            if (!mnemonic) {
                console.log("SIGNATURE REQUEST REJECTED=", signRequestIdent);
                handlerObj.reject(new Error('Signature canceled'));
            }
            console.log("TODO sign with received mnemonic=", mnemonic);
            //const signature = signer.sign(mnemonic, handlerObj.messageToSign)
            const signature = 'test signature result';
            handlerObj.resolve(signature);
        }
    }

    private initSignatureConfirmationFn(flutterJS: FlutterJS) {
        window[flutterJS.TX_SIGNATURE_CONFIRMATION_JS_FN_NAME] = (signatureIdent: string, mnemonic: string) => {
            console.log("RECEIVED SIGN CONF=",signatureIdent);
            this.receiveMessage(signatureIdent, mnemonic);
        }
    }
}
