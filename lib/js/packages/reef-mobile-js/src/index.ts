import polyfill from './polyfill';
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import {reefState, tokenUtil} from "@reef-chain/util-lib";
import {version} from "../../../../js/node_modules/@reef-chain/util-lib/package.json";
import {initFlutterApi} from "./jsApi/initFlutterApi";
import Keyring from "./jsApi/keyring";
import Signer from "./jsApi/signing/signer";

polyfill;
window['flutterJS'] = new FlutterJS(initFlutterApi);
window['reefState'] = reefState;
window['tokenUtil'] = tokenUtil;
window['keyring'] = Keyring;
window['signer'] = Signer;
window['getReefJsVer'] = ()=>({reefAppJs:'0 .0.1', utilLib:version});
