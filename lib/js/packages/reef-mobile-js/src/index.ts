import polyfill from './polyfill';
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import {appState} from "@reef-defi/react-lib";
import {initFlutterApi} from "./jsApi/initFlutterApi";
import Keyring from "./jsApi/keyring";
import Signer from "./jsApi/signing/signer";

polyfill;
window['flutterJS'] = new FlutterJS(initFlutterApi);
window['appState'] = appState;
window['keyring'] = Keyring;
window['signer'] = Signer;