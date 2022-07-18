import {FlutterJS} from "./FlutterJS";
import {FlutterConnector, Handler} from "./FlutterConnector";
import dAppResponseMsgHandler from "./dappFlutterResponseHandler";

let dAppSendRequestFn;

export const getDAppSendRequestFn = (flutterJS: FlutterJS) => {
    if (!dAppSendRequestFn) {
        // TODO make base type and extend separately FlutterConnectorDapp, FlutterConnectorMobileApi and hardcode some values
        const fSignConnector = new FlutterConnector(
            flutterJS,
            flutterJS.DAPP_REQ_CONFIRMATION_JS_FN_NAME,
            flutterJS.sendFlutterDAppMsgRequest.bind(flutterJS),
            dAppResponseMsgHandler
        );
        dAppSendRequestFn = fSignConnector.sendMessage.bind(fSignConnector);
    }
    return dAppSendRequestFn;
}
