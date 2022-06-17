// import { initWasm } from "@polkadot/wasm-crypto/initOnlyAsm";
// import "@polkadot/wasm-crypto/initWasmAsm";
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

let keyring = new Keyring({ type: CRYPTO_TYPE, ss58Format: SS58_FORMAT });

async function callCryptoWaitReady() {
    return await cryptoWaitReady();
    // return await initWasm();
}

/**
 * Generate a set of new mnemonic.
 */
async function gen() {
    // TODO put in another place?
    // we only need to do this once per app, somewhere in our init code
    // (when using the API and waiting on `isReady` this is done automatically)
    await cryptoWaitReady();
    // await initWasm();

    const key = mnemonicGenerate();

    if (!mnemonicValidate(key)) return null;

    const keyPair = keyring.addFromMnemonic(key, {}, CRYPTO_TYPE);
    const address = encodeAddress(keyPair.publicKey, SS58_FORMAT);
    const icons = genIcons([address]);

    console.log(`address created: ${address}`);

    return {
        mnemonic: key,
        address,
        svg: icons[0][1],
    };
}

/**
 * mnemonic validate.
 */
function checkMnemonicValid(mnemonic: string): boolean {
    return mnemonicValidate(mnemonic);
}

/**
 * get address and avatar from mnemonic.
 */
function addressFromMnemonic(mnemonic: string): string {
    let keyPair: KeyringPair;
    try {
        keyPair = keyring.addFromMnemonic(mnemonic, {}, CRYPTO_TYPE);
        const address = encodeAddress(keyPair.publicKey, SS58_FORMAT);
        // const icons = genIcons([address]);
        return address; // svg: icons[0][1],
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
    callCryptoWaitReady,
    gen,
    checkMnemonicValid,
    addressFromMnemonic,
};
