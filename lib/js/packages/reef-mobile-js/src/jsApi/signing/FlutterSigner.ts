// Copyright 2019-2021 @polkadot/extension-base authors & contributors
// SPDX-License-Identifier: Apache-2.0

import type { Signer as SignerInterface, SignerResult } from '@polkadot/api/types';
import type { SignerPayloadJSON, SignerPayloadRaw } from '@polkadot/types/types';
import type { SendRequest } from './types';

let sendRequest: SendRequest;
let nextId = 0;

export default class FlutterSigner implements SignerInterface {
    constructor (_sendRequest: SendRequest) {
        sendRequest = _sendRequest;
    }

    public async signPayload (payload: SignerPayloadJSON): Promise<SignerResult> {
        const id = ++nextId;
        const result = await sendRequest('pub(extrinsic.sign)', payload);
        console.log("SIG PAYLOAD RES", result);

        return {
            ...result,
            id
        };
    }

    public async signRaw (payload: SignerPayloadRaw): Promise<SignerResult> {
        const id = ++nextId;
        const result = await sendRequest('pub(bytes.sign)', payload);
        console.log("SIG RAW RES",result);

        return {
            ...result,
            id
        };
    }
}
