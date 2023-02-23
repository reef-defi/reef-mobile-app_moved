import { reefState, tokenUtil, network } from '@reef-chain/util-lib';
import { map, take } from "rxjs/operators";
import { firstValueFrom } from "rxjs";
import { ethers } from 'ethers';
import { Provider } from "@reef-defi/evm-provider";
import { base64Encode } from "@polkadot/util-crypto";
import { getSpecTypes } from "@polkadot/types-known";

const COLOR = "#681cff";
const CHAIN_TYPE = "substrate";

export const initApi = () => {
    (window as any).metadata = {
        getMetadata: async () => {
            return firstValueFrom(reefState.selectedProvider$.pipe(
                    take(1),
                    map(async (provider: Provider) => {
                        const api = provider.api;
                        await api.isReady;
                        const systemChain = api.runtimeChain.toString();
                        return {
                            chain: systemChain,
                            chainType: CHAIN_TYPE,
                            color: COLOR,
                            genesisHash: api.genesisHash.toHex(),
                            icon: CHAIN_TYPE,
                            metaCalls: base64Encode(api.runtimeMetadata.asCallsOnly.toU8a()),
                            specVersion: parseInt(api.runtimeVersion.specVersion.toString()),
                            ss58Format: network.SS58_REEF,
                            tokenDecimals: tokenUtil.REEF_TOKEN.decimals,
                            tokenSymbol: tokenUtil.REEF_TOKEN.symbol,
                            types: getSpecTypes(api.registry, systemChain, api.runtimeVersion.specName, api.runtimeVersion.specVersion ) as unknown as Record<string, string>
                        };
                    }),
                    take(1)
                )
            );
        },
//         isValidEvmAddress: (address: string) => {
//             return ethers.utils.isAddress(address);
//         }
    }
}
