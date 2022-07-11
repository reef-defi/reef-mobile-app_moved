import { Keyring } from "@polkadot/keyring";
import {
    mnemonicGenerate,
    mnemonicValidate,
    encodeAddress,
    cryptoWaitReady,
} from "@polkadot/util-crypto";
import { KeypairType } from "@polkadot/util-crypto/types";
import { KeyringPair } from "@polkadot/keyring/types";
import { polkadotIcon } from "@polkadot/ui-shared";

const CRYPTO_TYPE: KeypairType = "sr25519";
const SS58_FORMAT = 42;
const keyring = new Keyring({ type: CRYPTO_TYPE, ss58Format: SS58_FORMAT });

export interface Account {
    mnemonic: string,
    address: string,
    svg: string
}

async function initWasm(): Promise<boolean> {
    console.log("initWasm");
    // we only need to do this once per app, somewhere in our init code
    // (when using the API and waiting on `isReady` this is done automatically)
    return await cryptoWaitReady();
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
 * Validate mnemonic.
 */
function checkMnemonicValid(mnemonic: string): boolean {
    return mnemonicValidate(mnemonic);
}

/**
 * Get key pair from mnemonic.
 */
 async function keyPairFromMnemonic(mnemonic: string): Promise<KeyringPair> {
    try {
        return keyring.addFromMnemonic(mnemonic, {}, CRYPTO_TYPE);
    } catch (err: any) {
        console.log(err);
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

export default {
    keyring,
    initWasm,
    generate,
    checkMnemonicValid,
    keyPairFromMnemonic,
    accountFromMnemonic,
    genIcons, 
};
