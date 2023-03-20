import {graphql, network, reefState, tokenUtil, signatureUtils} from '@reef-chain/util-lib';
import {map, switchMap, take} from "rxjs/operators";
import {combineLatest, firstValueFrom} from "rxjs";
import {fetchTokenData} from './utils/tokenUtils';
import {ethers} from 'ethers';
import {Metadata, TypeRegistry} from '@polkadot/types';
import type {AnyJson} from "@polkadot/types/types";
import type {Call} from "@polkadot/types/interfaces";
import {Provider} from "@reef-defi/evm-provider";
import {getSpecTypes} from "@polkadot/types-known";
import {base64Decode, base64Encode} from '@reef-defi/util-crypto';
import {isAscii, u8aToString, u8aUnwrapBytes} from '@reef-defi/util';
import {ERC20} from "./abi/ERC20";

export const initApi = () => {
    (window as any).utils = {
        findToken: async (tokenAddress: string) => {
            let price$ = reefState.skipBeforeStatus$(tokenUtil.reefPrice$, reefState.FeedbackStatusCode.COMPLETE_DATA).pipe(
                map((value => value.data))
            );
            return firstValueFrom(
                combineLatest([graphql.apolloClientInstance$, reefState.selectedNetwork$, reefState.selectedProvider$, price$]).pipe(
                    take(1),
                    switchMap(async ([apolloInstance, net, provider, reefPrice]:[any, network.Network, Provider, number]) => {
                        return await fetchTokenData(apolloInstance, tokenAddress, provider, network.getReefswapNetworkConfig(net).factoryAddress, reefPrice);
                    }),
                    take(1)
                )
            );
        },
//         isValidEvmAddress: (address: string) => {
//             return ethers.utils.isAddress(address);
//         },

        decodeMethod: (data: string, types?: any) => {
            return firstValueFrom(reefState.selectedProvider$.pipe(
                take(1),
                map(async (provider: Provider) => {
                    const api = provider.api;
                    await api.isReady;

                    const abi = ERC20;
                    const sentValue = '0';
                    return signatureUtils.decodePayloadMethod(provider, data, abi, sentValue, types);

                }),
                take(1)
            ));
        },
        setSelectedNetwork: (networkName: string) => {
            const network: Network = network.AVAILABLE_NETWORKS[networkName] || network.AVAILABLE_NETWORKS.mainnet;
            return reefState.setSelectedNetwork(network);
        },
        bytesString: (bytes: string) => {
            return isAscii(bytes) ? u8aToString(u8aUnwrapBytes(bytes)) : bytes;
        }
    }
}
