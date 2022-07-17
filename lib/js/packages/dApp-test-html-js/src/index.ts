import polyfill from './polyfill';
import {initDappApi} from './initDappApi';
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";

polyfill;
window['flutterJS'] = new FlutterJS(initDappApi);
