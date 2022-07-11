import polyfill from './polyfill';
import {FlutterJS} from "flutter-js-bridge";

polyfill;
window['testInjected'] = new FlutterJS((v)=>{});
