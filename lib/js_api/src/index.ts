import polyfill from './polyfill';
import {FlutterJS} from "./jsApi/FlutterJS";
import {appState} from "@reef-defi/react-lib";
import {initFlutterApi} from "./jsApi/initFlutterApi";
import keyring from "./jsApi/keyring";

polyfill;
window['flutterJS'] = new FlutterJS(initFlutterApi);
window['appState'] = appState;
window['keyring'] = keyring;
