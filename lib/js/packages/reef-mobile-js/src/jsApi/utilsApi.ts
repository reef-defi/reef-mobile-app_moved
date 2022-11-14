import { appState, graphql, availableNetworks, Network } from '@reef-defi/react-lib';
import { map, switchMap, take } from "rxjs/operators";
import { combineLatest, firstValueFrom } from "rxjs";
import { fetchTokenData } from './utils/tokenUtils';
import { ethers } from 'ethers';
import { Metadata, TypeRegistry } from '@polkadot/types';
import type { AnyJson } from "@polkadot/types/types";
import type { Call } from "@polkadot/types/interfaces";
import { Provider } from "@reef-defi/evm-provider";
import { getSpecTypes } from "@polkadot/types-known";
import { base64Decode, base64Encode } from '@reef-defi/util-crypto';
import { isAscii, u8aToString, u8aUnwrapBytes } from '@reef-defi/util';

export const initApi = () => {
    (window as any).utils = {
        findToken: async (tokenAddress: string) => {
            return firstValueFrom(
                combineLatest([graphql.apolloClientInstance$, appState.currentNetwork$, appState.currentProvider$, appState.reefPrice$]).pipe(
                    take(1),
                    switchMap(async ([apolloInstance, network, provider, reefPrice]) => {
                        return await fetchTokenData(apolloInstance, tokenAddress, provider, network.factoryAddress, reefPrice);
                    }),
                    take(1)
                )
            );
        },
        isValidEvmAddress: (address: string) => {
            return ethers.utils.isAddress(address);
        },
        decodeMethod: (data: string, types: any) => {
            return firstValueFrom(appState.currentProvider$.pipe(
                take(1),
                map(async (provider: Provider) => {
                    const api = provider.api;
                    await api.isReady;

                    if (!types) {
                        types = getSpecTypes(api.registry, api.runtimeChain.toString(), api.runtimeVersion.specName, api.runtimeVersion.specVersion ) as unknown as Record<string, string>;
                    }
                    
                    let args: AnyJson | null = null;
                    let method: Call | null = null;
        
                    try {
                        const registry = new TypeRegistry();
                        registry.register(types);
                        registry.setChainProperties(registry.createType('ChainProperties', {
                            ss58Format: 42,
                            tokenDecimals: 18,
                            tokenSymbol: "REEF",
                        }));
                        const metaCalls = base64Encode(api.runtimeMetadata.asCallsOnly.toU8a());
                        // @ts-ignore
                        const metadata = new Metadata(registry, base64Decode(metaCalls || ''));
                        registry.setMetadata(metadata, undefined, undefined);

                        method = registry.createType("Call", data);
                        args = (method.toHuman() as { args: AnyJson }).args;
                    } catch (error) {
                        console.log('utils.decodeMethod: ERROR decoding method');
                        args = null;
                        method = null;
                    }
        
                    const info = method?.meta ? method.meta.docs.map((d) => d.toString().trim()).join(' ') : '';
                    const methodParams = method?.meta ? `(${method.meta.args.map(({ name }) => name).join(', ')})` : '';
                    const methodName = method ? `${method.section}.${method.method}${methodParams}` : '';
        
                    return { methodName, args, info };
                }),
                take(1)
            ));
        },
        setCurrentNetwork: (networkName: string) => {
            const network: Network = availableNetworks[networkName] || availableNetworks.mainnet;
            return appState.setCurrentNetwork(network);
        },
        bytesString: (bytes: string) => {
            return isAscii(bytes) ? u8aToString(u8aUnwrapBytes(bytes)) : bytes;
        }
    }
}