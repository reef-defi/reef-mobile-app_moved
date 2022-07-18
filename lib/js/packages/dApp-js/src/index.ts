import polyfill from './polyfill';
import {initDappApi} from './initDappApi';
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";

polyfill;
(window as any).reefMobileInjected = ()=>{
    return new Promise((resolve, reject)=>{
        document.addEventListener('reef-mobile-injected', ()=>resolve(true), false);
    })
}
window['flutterJS'] = new FlutterJS(initDappApi);
