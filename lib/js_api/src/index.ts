import polyfill from './polyfill';
import {FlutterJS} from "./jsApi/FlutterJS";
import {appState} from "@reef-defi/react-lib";
import {initFlutterApi} from "./jsApi/initFlutterApi";

polyfill;
window['flutterJS'] = new FlutterJS(initFlutterApi);
window['appState'] = appState;

