import {interval, map, Observable} from 'rxjs';

let flutterLog;
let reefMobile;

window['testObs'] = interval().pipe(
    map((value) => {
        return {value, msg:'hey'}
    })
);

window['console'].log = function (arg){
    window['flutterLog'].postMessage('js CHANNN log='+arg.toString());
}
window['testApi'] = function (param){
    console.log('js test log', {value:'test123'});
    return {id:'123', value:{works:'ok', param}};
}

window['reefMobileObservables']={
    subscribeTo: function (refName, id) {
        const obs = window[refName] as Observable<any>;
        obs?.subscribe((value) => window['reefMobile'].postMessage(JSON.stringify({id, value})));
        return true;
    }
}
