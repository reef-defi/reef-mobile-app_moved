import polyfill from './polyfill';
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import {appState} from "@reef-defi/react-lib";
import {initFlutterApi} from "./jsApi/initFlutterApi";
import accountManager from "./jsApi/account_manager/index";

polyfill;
window['flutterJS'] = new FlutterJS(initFlutterApi);
window['appState'] = appState;
window['accountManager'] = accountManager;

