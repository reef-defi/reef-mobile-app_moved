import polyfill from './polyfill';
import {interval, map} from 'rxjs';
import {FlutterJS} from "./service/flutterConnectService";
import {appState, availableNetworks, ReefSigner} from "@reef-defi/react-lib";
import {BigNumber} from 'ethers';
import * as account from "./account";

polyfill;

const onInitFn = () => {
    try {
        // TODO set in flutter - appState.selectAddressSubj;
        account.innitApi(flutterJS);
        // appState.currentSelectedAddress$.subscribe((v)=>console.log('CURR AA',v))
        appState.selectedSignerTokenBalances$.subscribe((v)=>console.log('CURR TTTT',v), (e)=>console.log('EEETKNBal',e.message))
        appState.initReefState({network: availableNetworks.testnet, signers:[{
                name: 'test1',
                signer: {  } as Signer,
                balance: BigNumber.from('0'),
                address: '5EUWG6tCA9S8Vw6YpctbPHdSrj95d18uNhRqgDniW3g9ZoYc',
                evmAddress: '',
                isEvmClaimed: false,
                source: 'mobileApp',
                genesisHash: undefined
            } as ReefSigner]
    });
    } catch (e) {
        console.log("INIT ERROR=", e.message);
    }
};

const flutterJS = new FlutterJS(onInitFn);
window['flutterJS'] = flutterJS;
window['appState'] = appState;

/*window['testObs'] = interval().pipe(
    map((value) => {
        return {value, msg: 'hey'}
    })
);
window['testApi'] = function (param) {
    // return {id:'123', value:{works:'ok', param}};
    return param + '_ok';
}*/


