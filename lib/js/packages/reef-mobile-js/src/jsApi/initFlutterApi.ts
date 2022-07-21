import * as accountApi from "./accountApi";
import {appState, AvailableNetworks, availableNetworks, ReefSigner} from "@reef-defi/react-lib";
import {map, switchMap, take} from "rxjs/operators";
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import {firstValueFrom} from "rxjs";
import {stringToHex} from '@polkadot/util';
import {SignerPayloadJSON} from "@polkadot/types/types";
import type {InjectedAccountWithMeta} from "@reef-defi/extension-inject/types";
import Signer from "@reef-defi/extension-base/page/Signer";
import {getSignatureSendRequest} from "flutter-js-bridge/src/sendRequestSignature";

export interface Account {
    address: string;
    name: string;
};

export const initFlutterApi = async (flutterJS: FlutterJS) => {
    try {
        console.log("INIT FLUTTER JS API");
        const signingKey = getFlutterSigningKey(flutterJS);
        (window as any).jsApi = {
            initReefState: async (selNetwork: AvailableNetworks, accounts: Account[]) => {
                let accountsWithMeta: InjectedAccountWithMeta[] = await Promise.all(
                    accounts.map(async (account: Account) => {
                        return await buildAccountWithMeta(account.name, account.address);
                    }
                ));

                const destroyFn = await appState.initReefState({
                    network: availableNetworks[selNetwork],
                    jsonAccounts: {accounts: accountsWithMeta, injectedSigner: signingKey}
                });

                /*setTimeout((  )=>{
                    destroyFn();
                    console.log('destroyed')
                },5000)*/
                window.addEventListener("beforeunload", function(e){
                    console.log('DESTROY Reef Api');
                    destroyFn();
                }, false);
            },
            testReefSignerRawPromise: (address: string, message: string) => {
                return firstValueFrom(appState.signers$.pipe(
                    map((signers: ReefSigner[]) => {
                        const signer = signers.find(s => s.address === address);
                        console.log("TEST SIGNER RAW=", signer.address);
                        return signer;
                    }),
                    switchMap((signer: ReefSigner | undefined) => {
                        return signer.signer.signingKey.signRaw({
                            address: signer.address,
                            data: stringToHex(message),
                            type: 'bytes'
                        }).then((res)=>{
                            console.log("SIGN RESULT=",res);
                            return res;
                        });
                    })
                ));
            },
            testReefSignerPayloadPromise: (address: string, payload: SignerPayloadJSON) => {
                return firstValueFrom(appState.signers$.pipe(
                    map((signers: ReefSigner[]) => {
                        const signer = signers.find(s => s.address === address);
                        console.log("TEST SIGNER PAYLOAD=", signer.address);
                        return signer;
                    }),
                    switchMap((signer: ReefSigner | undefined) => {
                        return signer.signer.signingKey.signPayload(payload);
                    })
                ));
            },
            testReefSignAndSendTxPromise: (address: string) => {
                return firstValueFrom(appState.signers$.pipe(
                    map((signers: ReefSigner[]) => {
                        const signer = signers.find(s => s.address === address);
                        console.log("TEST SIGN AND SEND=", signer.address);
                        return signer;
                    }),
                    switchMap(async (signer: ReefSigner | undefined) => {
                        // Contract data
                        const CONTRACT_ADDRESS = "0x0a3f2785dbbc5f022de511aab8846388b78009fd";
                        const CONTRACT_ABI = [
                            {
                                inputs: [
                                    {
                                        internalType: "uint256",
                                        name: "positionId",
                                        type: "uint256",
                                    },
                                ],
                                name: "enterRaffle",
                                outputs: [],
                                stateMutability: "payable",
                                type: "function",
                            }
                        ];

                        // Storage and gas limits
                        const STORAGE_LIMIT = 2000;

                        // Input data
                        const FUNCTION_NAME = "enterRaffle";
                        const ARGS = ["164"];
                        const VALUE_SENT = ethers.utils.parseEther("1.0");
                        const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer.signer);

                        const tx = await contract[FUNCTION_NAME](...ARGS, {
                            value: VALUE_SENT,
                            customData: { storageLimit: STORAGE_LIMIT }
                        });

                        const receipt = await tx.wait();
                        console.log("SIGN AND SEND RESULT=", receipt);
                        return receipt;
                    }),
                    take(1)
                ));
            }
        };
        // testReefObservables();
        accountApi.innitApi(flutterJS);

    } catch (e) {
        console.log("INIT ERROR=", e.message);
    }
};

export const buildAccountWithMeta = async (name: string, address: string): Promise<InjectedAccountWithMeta> => {
    const acountWithMeta: InjectedAccountWithMeta = {
        address,
        meta: {
            name,
            source: "ReefMobileWallet"
        }
    };

    return acountWithMeta;
}


function getFlutterSigningKey (flutterJS: FlutterJS) {
        let sendRequest = getSignatureSendRequest(flutterJS);
        return  new Signer(sendRequest);
}
