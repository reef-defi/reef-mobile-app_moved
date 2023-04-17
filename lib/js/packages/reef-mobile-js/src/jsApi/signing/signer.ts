import { u8aToHex } from "@polkadot/util";
import { wrapBytes } from '@reef-defi/extension-dapp/wrapBytes';
import { TypeRegistry } from '@polkadot/types';
import Keyring from '../keyring';
import { KeyringPair, KeyringPair$Json } from '@polkadot/keyring/types';
import type { SignerPayloadJSON } from '@polkadot/types/types';

async function signPayload(mnemonic: string, payload: SignerPayloadJSON): Promise<string> {
  const registry = new TypeRegistry();
  registry.setSignedExtensions(payload.signedExtensions);
  var pair: KeyringPair;
  //if the mnemonic phrase consists of plus it means it is not the normal mnemonic instead we are using this to get the keyring with which we will sign the tx

  // we can not sign the tx with private/secret key as there isn't any such function

  // IF ANY OF THE STEPS IS WRONG THEN THE TX WILL BE FAILED : INVALID
  if (mnemonic.indexOf('+') != -1) {
    // fetching the params for getting account.json file 
    const delimiterIndex = mnemonic.indexOf('+');
    const accountJsonDataParams = [
      mnemonic.slice(0, delimiterIndex),
      mnemonic.slice(delimiterIndex + 1)
    ];

    const _address = accountJsonDataParams[0]; // address of account
    const _password = accountJsonDataParams[1]; // password to decrypt account.json

    var accountJsonData = await Keyring.exportAccountQr(_address, _password); // getting account.json
    pair = await Keyring.krFromJson(accountJsonData["exportedJson"]); // generating pair with exported json file
    await pair.unlock(_password); // unlocking the pair for signing tx
  } else {
    // If the mnemonic doesn't have a "+" , it is normal mnemonic with which we will sign the tx
    pair = await Keyring.keyPairFromMnemonic(mnemonic);
  }
  return registry
    .createType('ExtrinsicPayload', payload, { version: payload.version })
    .sign(pair).signature;
}

async function signRaw(mnemonic: any, message: string): Promise<string> {
  var pair: KeyringPair;
  //if the mnemonic phrase consists of plus it means it is not the normal mnemonic instead we are using this to get the keyring with which we will sign the tx

  // we can not sign the tx with private/secret key as there isn't any such function

  // IF ANY OF THE STEPS IS WRONG THEN THE TX WILL BE FAILED : INVALID
  if (mnemonic.indexOf('+') != -1) {
    // fetching the params for getting account.json file 
    const delimiterIndex = mnemonic.indexOf('+');
    const accountJsonDataParams = [
      mnemonic.slice(0, delimiterIndex),
      mnemonic.slice(delimiterIndex + 1)
    ];

    const _address = accountJsonDataParams[0]; // address of account
    const _password = accountJsonDataParams[1]; // password to decrypt account.json

    var accountJsonData = await Keyring.exportAccountQr(_address, _password); // getting account.json
    pair = await Keyring.krFromJson(accountJsonData["exportedJson"]); // generating pair with exported json file
    await pair.unlock(_password); // unlocking the pair for signing tx
  } else {
    // If the mnemonic doesn't have a "+" , it is normal mnemonic with which we will sign the tx
    pair = await Keyring.keyPairFromMnemonic(mnemonic);
  }

  return u8aToHex(pair.sign(wrapBytes(message)));
}

export default {
  signPayload,
  signRaw
};