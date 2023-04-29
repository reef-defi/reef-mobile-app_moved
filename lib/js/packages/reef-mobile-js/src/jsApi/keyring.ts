import { u8aToHex , hexToU8a } from "@polkadot/util";
import { naclKeypairFromSeed  } from "@polkadot/util-crypto";
import { Keyring as ReefKeyring } from "@reef-defi/keyring";
import {
    mnemonicGenerate,
    mnemonicValidate,
    encodeAddress,
    cryptoWaitReady,
} from "@reef-defi/util-crypto";
import { KeypairType } from "@reef-defi/util-crypto/types";
import { KeyringPair } from "@reef-defi/keyring/types";
import { polkadotIcon } from "@polkadot/ui-shared";
import {keyring as kr} from '@polkadot/ui-keyring';
import { RequestAccountExport , ResponseAccountExport} from "./background/types";
import type { KeyringPair$Json } from '@polkadot/keyring/types';

const CRYPTO_TYPE: KeypairType = "sr25519";
const SS58_FORMAT = 42;
const keyring = new ReefKeyring({ type: CRYPTO_TYPE, ss58Format: SS58_FORMAT });

export interface Account {
    mnemonic: string,
    address: string,
    svg: string
}

export interface RequestAccountCreateSuri {
    name: string;
    genesisHash?: string | null;
    password: string;
    suri: string;
    type?: KeypairType;
  }

async function initWasm(): Promise<boolean> {
    // we only need to do this once per app, somewhere in our init code
    // (when using the API and waiting on `isReady` this is done automatically)
    const isReady = await cryptoWaitReady();
    kr.loadAll({

    });
    if (isReady) {
        console.log("WASM initialized");
    } else {
        console.log("Error initializing WASM");
    }
    return isReady;
}

/**
 * Generate a set of new mnemonic.
 */
async function generate(): Promise<string> {
    const key = mnemonicGenerate();

    if (!mnemonicValidate(key)) throw new Error("Invalid mnemonic");

    const keyPair = keyring.addFromMnemonic(key, {}, CRYPTO_TYPE);
    const address = encodeAddress(keyPair.publicKey, SS58_FORMAT);
    const icons = genIcons([address]);

    const account: Account = {
        mnemonic: key,
        address,
        svg: icons[0][1],
    };
    return JSON.stringify(account);
}

/**
 * Get key pair from mnemonic.
 */
 async function keyPairFromMnemonic(mnemonic: string): Promise<KeyringPair> {
    try {
        return keyring.addFromMnemonic(mnemonic, {}, CRYPTO_TYPE);
    } catch (err: any) {
        console.log("error in keyPairFromMnemonic", err);
        return null;
    }
}

/**
 * Get account from mnemonic.
 */
async function accountFromMnemonic(mnemonic: string): Promise<string> {
    const keyPair = await keyPairFromMnemonic(mnemonic);
    if (!keyPair) return null;

    try {
        const address = encodeAddress(keyPair.publicKey, SS58_FORMAT);
        const icons = genIcons([address]);
        const account: Account = {
            mnemonic: mnemonic,
            address,
            svg: icons[0][1],
        };
        return JSON.stringify(account);
    } catch (err: any) {
        console.log(err);
        return null;
    }
}
const ETH_DERIVE_DEFAULT = "/m/44'/60'/0'/0/0";

function getSuri (seed: string, type?: KeypairType): string {
    return type === 'ethereum'
      ? `${seed}${ETH_DERIVE_DEFAULT}`
      : seed;
  }

function accountsCreateSuri (suri:string, password:string): boolean {
    kr.addUri(getSuri(suri, 'sr25519'), password, { genesisHash:'', name:'accountFromMnemonic' }, 'sr25519');

    return true;
  }

/**
 * Check if mnemonic is valid.
 */
function checkMnemonicValid(mnemonic: string): any {
    return mnemonicValidate(mnemonic).toString();
}

// Check if private key is valid or not
function checkKeyValidity(privateKey: string): boolean {
    try {
      // Convert the private key from hex to Uint8Array format
      const privateKeyBytes = hexToU8a(privateKey);
  
      // Generate the keypair from the seed (private key)
      const keypair = naclKeypairFromSeed(privateKeyBytes);
  
      // Convert the public key to hex format and verify it starts with the Polkadot prefix "0x" followed by 64 hexadecimal characters
      const publicKeyHex = u8aToHex(keypair.publicKey);
      if (publicKeyHex.length !== 66 || !publicKeyHex.startsWith('0x')) {
        return false;
      }
  
      // The private key is valid if no errors were thrown
      return true;
    } catch {
      // An error was thrown, so the private key is invalid
      return false;
    }
  }

// Restore account from JSON
async function restoreJson(file:KeyringPair$Json,password:string):Promise<any> {
    try {
        return kr.restoreAccount(file, password);
    } catch (error) {
        return "error";
    }
}
// create keyring from json
async function krFromJson(file:KeyringPair$Json):Promise<any> {
    try {
        return kr.createFromJson(file);
    } catch (error) {
        return "error";
    }
}


// Add External account
function exportAccountQr(address:string, password:string): any  {
    try {
        return { exportedJson: kr.backupAccount(kr.getPair(address), password)};
    } catch (error) {
        return "error";
    }
}

/**
 * Get SVG icons of addresses.
 */
function genIcons(addresses: string[]): string[][] {
    return addresses.map((i) => {
        const circles = polkadotIcon(i, { isAlternative: false })
            .map(
                ({ cx, cy, fill, r }) => `<circle cx='${cx}' cy='${cy}' fill='${fill}' r='${r}' />`
            )
            .join("");
        return [i, `<svg viewBox='0 0 64 64' xmlns='http://www.w3.org/2000/svg'>${circles}</svg>`];
    });
}

function changeAccountPassword (address:string, newPass:string, oldPass:string ): boolean {
    const pair = kr.getPair(address);
    try {
      if (!pair.isLocked) {
        pair.lock();
      }
      pair.decodePkcs8(oldPass);
    } catch (error) {
      throw new Error('oldPass is invalid');
    }
    kr.encryptAccount(pair, newPass);
    return true;
  }

export default {
    initWasm,
    generate,
    keyPairFromMnemonic,
    accountFromMnemonic,
    checkMnemonicValid,
    restoreJson,
    exportAccountQr,
    checkKeyValidity,
    krFromJson,
    changeAccountPassword,
    accountsCreateSuri
};