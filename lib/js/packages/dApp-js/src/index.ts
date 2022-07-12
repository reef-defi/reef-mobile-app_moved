import polyfill from './polyfill';
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";

polyfill;
window['testInjected'] = new FlutterJS((v)=>{});
