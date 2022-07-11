import polyfill from './polyfill';
import {appState} from "@reef-defi/react-lib";
import {FlutterJS} from "flutter-js-bridge";
import accountManager from "./jsApi/account_manager/index";
import {initFlutterApi} from "./jsApi/initFlutterApi";

polyfill;
window['flutterJS'] = new FlutterJS(initFlutterApi);
window['appState'] = appState;
window['accountManager'] = accountManager;

