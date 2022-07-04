
import type { AccountJson, AllowedPath, AuthorizeRequest, MessageTypes, MessageTypesWithNoSubscriptions, MessageTypesWithNullRequest, MessageTypesWithSubscriptions, MetadataRequest, RequestTypes, ResponseAuthorizeList, ResponseDeriveValidate, ResponseJsonGetAccountInfo, ResponseSigningIsLocked, ResponseTypes, SeedLengths, SigningRequest, SubscriptionMessageTypes } from '@reef-defi/extension-base/background/types';

interface Handler {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    resolve: (data: any) => void;
    reject: (error: Error) => void;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    subscriber?: (data: any) => void;
}
type Handlers = Record<string, Handler>;

const handlers: Handlers = {};
let idCounter = 0;

export function sendMessage<TMessageType extends MessageTypes> (message: TMessageType, request?: RequestTypes[TMessageType], subscriber?: (data: unknown) => void): Promise<ResponseTypes[TMessageType]> {
    return new Promise((resolve, reject): void => {
        const id = `${Date.now()}.${++idCounter}`;

        handlers[id] = { reject, resolve, subscriber };

        console.log("TODO post message to flutter",);
        // port.postMessage({ id, message, request: request || {} });
    });
}
