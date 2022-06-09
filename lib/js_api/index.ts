import poly from './polyfill';
import {interval, map} from 'rxjs';
import {FlutterJS} from "./service/flutterConnectService";
import {appState, availableNetworks} from "@reef-defi/react-lib";

poly;
window['flutterJS'] = new FlutterJS();
console.log('INITTTT ');

window['testObs'] = interval().pipe(
    map((value) => {
        return {value, msg: 'hey'}
    })
);
appState.initReefState({network:availableNetworks.testnet});
window['testApi'] = function (param) {
    console.log('js test log', {value:'test123'}, true);
    // return {id:'123', value:{works:'ok', param}};
    return param + '_ok';
}

appState.currentNetwork$.subscribe((sss) => console.log('NNN =', sss.name));
appState.selectedSigner$.subscribe((sss) => console.log('SS =', sss.name));

