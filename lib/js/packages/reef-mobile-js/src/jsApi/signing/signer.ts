import { u8aToHex } from "@polkadot/util";
import { wrapBytes } from '@reef-defi/extension-dapp/wrapBytes';
import { TypeRegistry } from '@polkadot/types';
import Keyring from '../keyring';
import { KeyringPair } from '@polkadot/keyring/types';
import type { SignerPayloadJSON } from '@polkadot/types/types';


async function signPayload(mnemonic: string, payload: SignerPayloadJSON): Promise<string> {
    const registry = new TypeRegistry();
    registry.setSignedExtensions(payload.signedExtensions);

    const pair: KeyringPair = await Keyring.keyPairFromMnemonic(mnemonic);

    return registry
        .createType('ExtrinsicPayload', payload, { version: payload.version })
        .sign(pair).signature;
}

async function signRaw(mnemonic: string, message: string): Promise<string>  {
  const pair: KeyringPair = await Keyring.keyPairFromMnemonic(mnemonic);

  return u8aToHex(pair.sign(wrapBytes(message)));
}

export default {
  signPayload,
  signRaw
};
