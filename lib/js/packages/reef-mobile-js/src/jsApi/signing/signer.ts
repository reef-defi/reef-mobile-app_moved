import type { HexString } from '@reef-defi/util/types';
import type { SignerPayloadJSON } from '@polkadot/types/types';
import { TypeRegistry } from '@polkadot/types';
import Keyring from '../account_manager/keyring';
import { KeyringPair } from '@polkadot/keyring/types';

/**
 * Signs a payload using the given mnemonic.
 */
async function sign(mnemonic: string, payload: SignerPayloadJSON): Promise<string>  {
  const registry = new TypeRegistry();
  registry.setSignedExtensions(payload.signedExtensions);

  const pair: KeyringPair = await Keyring.keyPairFromMnemonic(mnemonic);

  return (registry
    .createType('ExtrinsicPayload', payload, { version: payload.version })
    .sign(pair) as { signature: HexString }).signature;
}

export default {
  sign
};
