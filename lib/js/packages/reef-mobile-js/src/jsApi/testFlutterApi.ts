import {reefState, graphql} from "@reef-chain/util-lib";
import {map} from "rxjs/operators";
import {interval} from "rxjs/dist/types";

export function testMethods() {
    window['testObs'] = interval().pipe(
        map((value) => {
            return {value, msg: 'hey'}
        })
    );
    window['testApi'] = function (param) {
        // return {id:'123', value:{works:'ok', param}};
        return param + '_ok';
    }
    window['futureFn'] = (val) => Promise.resolve('Promise =' + val);
}

export function testReefObservables() {
    graphql.apolloClientInstance$.subscribe(
        {
            next: (v) =>
                console.log('APOLLO ', v),
            error: (e) => console.log('APOLLO ERR', e.message)
        });
    reefState.accounts$.subscribe(
        {
            next: (v) =>
                console.log('SIGNERS', v?.length),
            error: (e) => console.log('SIGNERS ERR', e.message)
        });
    reefState.selectedAddress$.subscribe(
        {
            next: (v) =>
                console.log('ADDRESS', v),
            error: (e) => console.log('ADDRESS ERR', e.message)
        });
    reefState.selectedAccount$.subscribe(
        {
            next: (v) =>
                console.log('SIGNER', v),
            error: (e) => console.log('SIGNER ERR', e.message)
        });
    reefState.selectedSignerTokenBalances$.subscribe(
        {
            next: (v) =>
                console.log('TOKENS', v),
            error: (e) => console.log('TOKENS ERR', e.message)
        });

    /*testReefSignerRawPromise: (address: string, message: string) => {
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
                ));*/
}
