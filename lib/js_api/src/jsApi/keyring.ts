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

/**
 * Initializes WASM interface.
 */
async function init() {
    return await cryptoWaitReady();
}

/**
 * Generate a set of new mnemonic.
 */
async function gen() {    
    const key = mnemonicGenerate();

    if (!mnemonicValidate(key)) return null;

    const keyPair = keyring.addFromMnemonic(key, {}, CRYPTO_TYPE);
    const address = encodeAddress(keyPair.publicKey, SS58_FORMAT);
    const icons = genIcons([address]);

    return {
        mnemonic: key,
        address,
        svg: icons[0][1],
    };
}

/**
 * Mnemonic validate.
 */
function checkMnemonicValid(mnemonic: string): boolean {
    return mnemonicValidate(mnemonic);
}

/**
 * Get address and avatar from mnemonic.
 */
async function addressFromMnemonic(mnemonic: string) {
    let keyPair: KeyringPair;
    try {
        keyPair = keyring.addFromMnemonic(mnemonic, {}, CRYPTO_TYPE);
        const address = encodeAddress(keyPair.publicKey, SS58_FORMAT);
        const icons = genIcons([address]);
        return {
            mnemonic: mnemonic,
            address,
            svg: icons[0][1],
        };
    } catch (err: any) {
        return null;
    }
}

/**
 * Get svg icons of addresses.
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
    init,
    gen,
    checkMnemonicValid,
    addressFromMnemonic,
};
