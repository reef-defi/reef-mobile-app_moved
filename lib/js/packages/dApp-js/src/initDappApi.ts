
export const initDappApi = (flutterJS: FlutterJS) => {
    try {
        console.log("INIT DApp JS API");
        (window as any).jsApi = {
            setAccounts: (accounts: InjectedAccountWithMeta[]) => {
                        console.log('Accs=',accounts);
                },


        };

         /*    testReefSignerPromise: (address: string) => {
                return appState.signers$.pipe(
                    map((signers: ReefSigner[]) => {
                        const signer = signers.find(s => s.address === address);
                        return signer;
                    }),
                    switchMap((signer: ReefSigner | undefined) => {
                        return signer.signer.signMessage("hello world").then((res)=>{
                            console.log("SIGN RESULT=",res);
                            return res;
                        });
                    })
                ).toPromise();
            }
        }; */

    } catch (e) {
        console.log("INIT ERROR=", e.message);
    }
};
