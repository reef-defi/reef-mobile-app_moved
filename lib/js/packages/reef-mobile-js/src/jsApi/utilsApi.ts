import { appState, graphql } from '@reef-defi/react-lib';
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
        decodeMethod: (data: string, types: Record<string, Record<string, any> | string>) => {
            return firstValueFrom(appState.currentProvider$.pipe(
                take(1),
                map(async (provider: Provider) => {
                    const api = provider.api;
                    await api.isReady;
                    const systemChain = api.runtimeChain.toString();
                    // const chain =  {
                    //     chain: systemChain,
                    //     chainType: CHAIN_TYPE,
                    //     color: COLOR,
                    //     genesisHash: api.genesisHash.toHex(),
                    //     icon: CHAIN_TYPE,
                    //     metaCalls: Buffer.from(api.runtimeMetadata.asCallsOnly.toU8a()).toString('base64'),
                    //     specVersion: parseInt(api.runtimeVersion.specVersion.toString(), 16),
                    //     ss58Format: DEFAULT_SS58,
                    //     tokenDecimals: TOKEN_DECIMALS,
                    //     tokenSymbol: TOKEN_SYMBOL,
                    //     types: getSpecTypes(api.registry, systemChain, api.runtimeVersion.specName, api.runtimeVersion.specVersion ) as unknown as Record<string, string>
                    // };

                    types = getSpecTypes(api.registry, systemChain, api.runtimeVersion.specName, api.runtimeVersion.specVersion ) as unknown as Record<string, string>;
                    data = "0x15000a3f2785dbbc5f022de511aab8846388b78009fd902e519f900000000000000000000000000000000000000000000000000000000000000193000064a7b3b6e00d0000000000000000bd39250000000000d0070000";
                    // types = {
                    //     "CallOf": "Call",
                    //     "DispatchTime": {
                    //         "_enum": {
                    //             "At": "BlockNumber",
                    //             "After": "BlockNumber"
                    //         }
                    //     },
                    //     "ScheduleTaskIndex": "u32",
                    //     "DelayedOrigin": {
                    //         "delay": "BlockNumber",
                    //         "origin": "PalletsOrigin"
                    //     },
                    //     "StorageValue": "Vec<u8>",
                    //     "GraduallyUpdate": {
                    //         "key": "StorageKey",
                    //         "targetValue": "StorageValue",
                    //         "perBlock": "StorageValue"
                    //     },
                    //     "StorageKeyBytes": "Vec<u8>",
                    //     "StorageValueBytes": "Vec<u8>",
                    //     "RpcDataProviderId": "Text",
                    //     "OrderedSet": "Vec<AccountId>",
                    //     "OrmlAccountData": {
                    //         "free": "Balance",
                    //         "frozen": "Balance",
                    //         "reserved": "Balance"
                    //     },
                    //     "OrmlBalanceLock": {
                    //         "amount": "Balance",
                    //         "id": "LockIdentifier"
                    //     },
                    //     "DelayedDispatchTime": {
                    //         "_enum": {
                    //             "At": "BlockNumber",
                    //             "After": "BlockNumber"
                    //         }
                    //     },
                    //     "DispatchId": "u32",
                    //     "Price": "FixedU128",
                    //     "OrmlVestingSchedule": {
                    //         "start": "BlockNumber",
                    //         "period": "BlockNumber",
                    //         "periodCount": "u32",
                    //         "perPeriod": "Compact<Balance>"
                    //     },
                    //     "VestingScheduleOf": "OrmlVestingSchedule",
                    //     "PalletBalanceOf": "Balance",
                    //     "ChangeBalance": {
                    //         "_enum": {
                    //             "NoChange": "Null",
                    //             "NewValue": "Balance"
                    //         }
                    //     },
                    //     "BalanceWrapper": {
                    //         "amount": "Balance"
                    //     },
                    //     "BalanceRequest": {
                    //         "amount": "Balance"
                    //     },
                    //     "EvmAccountInfo": {
                    //         "nonce": "Index",
                    //         "contractInfo": "Option<EvmContractInfo>",
                    //         "developerDeposit": "Option<Balance>"
                    //     },
                    //     "CodeInfo": {
                    //         "codeSize": "u32",
                    //         "refCount": "u32"
                    //     },
                    //     "EvmContractInfo": {
                    //         "codeHash": "H256",
                    //         "maintainer": "H160",
                    //         "deployed": "bool"
                    //     },
                    //     "EvmAddress": "H160",
                    //     "CallRequest": {
                    //         "from": "Option<H160>",
                    //         "to": "Option<H160>",
                    //         "gasLimit": "Option<u32>",
                    //         "storageLimit": "Option<u32>",
                    //         "value": "Option<U128>",
                    //         "data": "Option<Bytes>"
                    //     },
                    //     "CID": "Vec<u8>",
                    //     "ClassId": "u32",
                    //     "ClassIdOf": "ClassId",
                    //     "TokenId": "u64",
                    //     "TokenIdOf": "TokenId",
                    //     "TokenInfoOf": {
                    //         "metadata": "CID",
                    //         "owner": "AccountId",
                    //         "data": "TokenData"
                    //     },
                    //     "TokenData": {
                    //         "deposit": "Balance"
                    //     },
                    //     "Properties": {
                    //         "_set": {
                    //             "_bitLength": 8,
                    //             "Transferable": 1,
                    //             "Burnable": 2
                    //         }
                    //     },
                    //     "BondingLedger": {
                    //         "total": "Compact<Balance>",
                    //         "active": "Compact<Balance>",
                    //         "unlocking": "Vec<UnlockChunk>"
                    //     },
                    //     "Amount": "i128",
                    //     "AmountOf": "Amount",
                    //     "AuctionId": "u32",
                    //     "AuctionIdOf": "AuctionId",
                    //     "TokenSymbol": {
                    //         "_enum": {
                    //             "REEF": 0,
                    //             "RUSD": 1
                    //         }
                    //     },
                    //     "CurrencyId": {
                    //         "_enum": {
                    //             "Token": "TokenSymbol",
                    //             "DEXShare": "(TokenSymbol, TokenSymbol)",
                    //             "ERC20": "EvmAddress"
                    //         }
                    //     },
                    //     "CurrencyIdOf": "CurrencyId",
                    //     "AuthoritysOriginId": {
                    //         "_enum": [
                    //             "Root"
                    //         ]
                    //     },
                    //     "TradingPair": "(CurrencyId,  CurrencyId)",
                    //     "AsOriginId": "AuthoritysOriginId",
                    //     "SubAccountStatus": {
                    //         "bonded": "Balance",
                    //         "available": "Balance",
                    //         "unbonding": "Vec<(EraIndex,Balance)>",
                    //         "mockRewardRate": "Rate"
                    //     },
                    //     "Params": {
                    //         "targetMaxFreeUnbondedRatio": "Ratio",
                    //         "targetMinFreeUnbondedRatio": "Ratio",
                    //         "targetUnbondingToFreeRatio": "Ratio",
                    //         "unbondingToFreeAdjustment": "Ratio",
                    //         "baseFeeRate": "Rate"
                    //     },
                    //     "Ledger": {
                    //         "bonded": "Balance",
                    //         "unbondingToFree": "Balance",
                    //         "freePool": "Balance",
                    //         "toUnbondNextEra": "(Balance, Balance)"
                    //     },
                    //     "ChangeRate": {
                    //         "_enum": {
                    //             "NoChange": "Null",
                    //             "NewValue": "Rate"
                    //         }
                    //     },
                    //     "ChangeRatio": {
                    //         "_enum": {
                    //             "NoChange": "Null",
                    //             "NewValue": "Ratio"
                    //         }
                    //     },
                    //     "BalanceInfo": {
                    //         "amount": "Balance"
                    //     },
                    //     "Rate": "FixedU128",
                    //     "Ratio": "FixedU128",
                    //     "PublicKey": "[u8; 20]",
                    //     "DestAddress": "Vec<u8>",
                    //     "Keys": "SessionKeys2",
                    //     "PalletsOrigin": {
                    //         "_enum": {
                    //             "System": "SystemOrigin",
                    //             "Timestamp": "Null",
                    //             "RandomnessCollectiveFlip": "Null",
                    //             "Balances": "Null",
                    //             "Accounts": "Null",
                    //             "Currencies": "Null",
                    //             "Tokens": "Null",
                    //             "Vesting": "Null",
                    //             "Utility": "Null",
                    //             "Multisig": "Null",
                    //             "Recovery": "Null",
                    //             "Proxy": "Null",
                    //             "Scheduler": "Null",
                    //             "Indices": "Null",
                    //             "GraduallyUpdate": "Null",
                    //             "Authorship": "Null",
                    //             "Babe": "Null",
                    //             "Grandpa": "Null",
                    //             "Staking": "Null",
                    //             "Session": "Null",
                    //             "Historical": "Null",
                    //             "Authority": "DelayedOrigin",
                    //             "ElectionsPhragmen": "Null",
                    //             "Contracts": "Null",
                    //             "EVM": "Null",
                    //             "Sudo": "Null",
                    //             "TransactionPayment": "Null"
                    //         }
                    //     },
                    //     "LockState": {
                    //         "_enum": {
                    //             "Committed": "None",
                    //             "Unbonding": "BlockNumber"
                    //         }
                    //     },
                    //     "LockDuration": {
                    //         "_enum": [
                    //             "OneMonth",
                    //             "OneYear",
                    //             "TenYears"
                    //         ]
                    //     },
                    //     "EraIndex": "u32",
                    //     "Era": {
                    //         "index": "EraIndex",
                    //         "start": "BlockNumber"
                    //     },
                    //     "Commitment": {
                    //         "state": "LockState",
                    //         "duration": "LockDuration",
                    //         "amount": "Balance",
                    //         "candidate": "AccountId"
                    //     },
                    //     "Multisig": {
                    //       "when": "Timepoint",
                    //       "deposit": "Balance",
                    //       "depositor": "AccountId",
                    //       "approvals": "Vec<AccountId>"
                    //     },
                    //     "Timepoint": {
                    //       "height": "BlockNumber",
                    //       "index": "u32"
                    //     }
                    // };
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
                        // const metaCalls = Buffer.from(api.runtimeMetadata.asCallsOnly.toU8a()).toString('base64');
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
        
                    console.log('utils.decodeMethod: method', method);
                    console.log('utils.decodeMethod: args', args);
        
                    return { args, method };
                }),
                take(1)
            )
        );
        }
    }
}