import {appState, graphql} from "@reef-defi/react-lib";
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
}

export function testReefObservables() {
    graphql.apolloClientInstance$.subscribe(
        {
            next: (v) =>
                console.log('APOLLO ', v),
            error: (e) => console.log('APOLLO ERR', e.message)
        });
    appState.signers$.subscribe(
        {
            next: (v) =>
                console.log('SIGNERS', v?.length),
            error: (e) => console.log('SIGNERS ERR', e.message)
        });
    appState.currentAddress$.subscribe(
        {
            next: (v) =>
                console.log('ADDRESS', v),
            error: (e) => console.log('ADDRESS ERR', e.message)
        });
    appState.selectedSigner$.subscribe(
        {
            next: (v) =>
                console.log('SIGNER', v),
            error: (e) => console.log('SIGNER ERR', e.message)
        });
    appState.selectedSignerTokenBalances$.subscribe(
        {
            next: (v) =>
                console.log('TOKENS', v),
            error: (e) => console.log('TOKENS ERR', e.message)
        });
}
