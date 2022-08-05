import { appState, graphql } from '@reef-defi/react-lib';
import { switchMap, take } from "rxjs/operators";
import { combineLatest, firstValueFrom } from "rxjs";
import { fetchTokenData } from './utils/tokenUtils';

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
    }
}