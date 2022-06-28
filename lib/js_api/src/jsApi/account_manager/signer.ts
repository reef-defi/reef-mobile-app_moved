import { hexToU8a, u8aToHex, isHex, stringToU8a } from "@polkadot/util";
import { WsProvider, ApiPromise } from "@polkadot/api";
import Keyring from "./keyring";
import { AvailableNetworks, availableNetworks } from "./network";

let api: ApiPromise;

async function connect(network: AvailableNetworks) {  
    console.log(`Connecting to ${network}...`);
    const endPoint = availableNetworks[network].rpcUrl;

    return new Promise(async (resolve) => {
        const wsProvider = new WsProvider(endPoint);
        try {
            api = await ApiPromise.create({provider: wsProvider});
            console.log(`${endPoint} wss connected success`);
            resolve(endPoint);
        } catch (err) {
            console.log(`connect to ${endPoint} failed`);
            wsProvider.disconnect();
            resolve(null);
        }
    });
}

async function sign(mnemonic: string, payload: any) {
    const { method, params } = payload;
    const address = params[0];
    const keyPair = await Keyring.keyPairFromMnemonic(mnemonic);
    if (!keyPair) return;

    try {
        if (method == "signExtrinsic") {
          const txInfo = params[1];
          const { header, mortalLength, nonce } = (await api.derive.tx.signingInfo(address)) as any;
          const tx = api.tx[txInfo.module][txInfo.call](...txInfo.params);

          const signerPayload = api.registry.createType("SignerPayload", {
            address,
            blockHash: header.hash,
            blockNumber: header ? header.number : 0,
            era: api.registry.createType("ExtrinsicEra", {
              current: header.number,
              period: mortalLength,
            }),
            genesisHash: api.genesisHash,
            method: tx.method,
            nonce,
            signedExtensions: ["CheckNonce"],
            tip: txInfo.tip,
            runtimeVersion: {
              specVersion: api.runtimeVersion.specVersion,
              transactionVersion: api.runtimeVersion.transactionVersion,
            },
            version: api.extrinsicVersion,
          });
          const payload = signerPayload.toPayload();
          const txPayload = api.registry.createType("ExtrinsicPayload", payload, {
            version: payload.version,
          });
          const signed = txPayload.sign(keyPair);
          return signed;
        }
        if (method == "signBytes") {
          const msg = params[1];
          const isDataHex = isHex(msg);
          return {
            signature: u8aToHex(keyPair.sign(isDataHex ? hexToU8a(msg) : stringToU8a(msg))),
          };
        }
    } catch (err: any) {
      console.log(err.message);
    }

    return {};
}

async function signAndSend(mnemonic:string, payload: any) {
  const { method, params } = payload;
  const address = params[0];
  const keyPair = await Keyring.keyPairFromMnemonic(mnemonic);
  if (!keyPair) return;

  try {
      if (method == "signExtrinsic") {
        const txInfo = params[1];
        const { header, mortalLength, nonce } = (await api.derive.tx.signingInfo(address)) as any;
        const tx = api.tx[txInfo.module][txInfo.call](...txInfo.params);

        const result = await tx.signAndSend(keyPair, {blockHash: header.hash, era: api.registry.createType("ExtrinsicEra", {
          current: header.number,
          period: mortalLength,
        }), nonce,tip: txInfo.tip })

        return result;
      }
      // TODO
      // if (method == "signBytes") {
      //   const msg = params[1];
      //   const isDataHex = isHex(msg);
      //   return {
      //     signature: u8aToHex(keyPair.sign(isDataHex ? hexToU8a(msg) : stringToU8a(msg))),
      //   };
      // }
  } catch (err: any) {
    console.log(err.message);
  }

  return {};
}

export default {
    connect,
    sign,
    signAndSend,
};
