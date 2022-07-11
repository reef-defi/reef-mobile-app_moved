import {FlutterSigningConnector} from "./FlutterSigningConnector";
import FlutterSigner from "./FlutterSigner";
import {FlutterJS} from "../FlutterJS";

export const initFlutterSigningKey = (flutterJS: FlutterJS) => {
    const fSignConnector = new FlutterSigningConnector(flutterJS);
    return new FlutterSigner(fSignConnector.sendMessage.bind(fSignConnector));
}
