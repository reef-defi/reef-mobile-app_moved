import polyfill from './polyfill';
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import {reefState, tokenUtil} from "@reef-chain/util-lib";
import {initFlutterApi} from "./jsApi/initFlutterApi";
import Keyring from "./jsApi/keyring";
import Signer from "./jsApi/signing/signer";

polyfill;
window['flutterJS'] = new FlutterJS(initFlutterApi);
window['reefState'] = reefState;
window['tokenUtil'] = tokenUtil;
window['keyring'] = Keyring;
window['signer'] = Signer;
