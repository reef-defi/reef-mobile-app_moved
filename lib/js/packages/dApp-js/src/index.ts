import polyfill from './polyfill';
import {initDappApi} from './initDappApi';
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";

polyfill;
// TODO remove after in lib
(window as any).onReefInjectedPromise = ()=>{
    return new Promise((resolve, reject)=>{
        document.addEventListener('reef-injected', ()=>resolve(true), false);
    })
}
window['flutterJS'] = new FlutterJS(initDappApi);
