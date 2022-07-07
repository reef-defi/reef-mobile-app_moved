import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:reef_mobile_app/components/WebViewStack.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JsApiService {
  final LOG_MSG_IDENT = '_console.log';
  final API_READY_MSG_IDENT = '_windowApisReady';
  final TX_SIGNATURE_CONFIRMATION_MSG_IDENT = '_txSignMsgIdent';
  final TX_SIGN_CONFIRMATION_JS_FN_NAME = '_txSignConfirmationJsFnName';
  final REEF_MOBILE_CHANNEL_NAME = 'reefMobileChannel';
  final FLUTTER_SUBSCRIBE_METHOD_NAME = 'flutterSubscribe';

  final controllerInit = Completer<WebViewController>();
  final jsApiLoaded = Completer<WebViewController>();
  final jsApiReady = Completer<WebViewController>();

  final jsMessageSubj = BehaviorSubject<JsApiMessage>();
  final jsTxSignatureConfirmationMessageSubj = BehaviorSubject<JsApiMessage>();
  final jsMessageUnknownSubj = BehaviorSubject<JsApiMessage>();

  get widget {
    return WebViewOffstage(
      controller: this.controllerInit,
      loaded: jsApiLoaded,
      jsChannels: _createJavascriptChannels(),
    );
  }

  Future<WebViewController> get _controller => jsApiReady.future;

  JsApiService() {
    controllerInit.future
        .then((ctrl) => _loadJs(ctrl, 'lib/js_api/dist/index.js'));
  }

  Future<String> jsCall(String executeJs) {
    return _controller
        .then((ctrl) => ctrl.runJavascriptReturningResult(executeJs));
  }

  Future jsPromise(String jsObsRefName) {
    return jsObservable(jsObsRefName).first;
  }

  Stream jsObservable(String jsObsRefName) {
    String ident = Random()
        .nextInt(9999999)
        .toString();

    jsCall(
        "window['$FLUTTER_SUBSCRIBE_METHOD_NAME']('$jsObsRefName', '$ident')");
    return jsMessageSubj.stream
        .where((event) => event.id == ident)
        .map((event) => event.value);
  }

  void confirmTxSignature(String signatureIdent) {
    print('TODO GET MNEMONIC FOR ACC');
    jsCall('${TX_SIGN_CONFIRMATION_JS_FN_NAME}($signatureIdent, "test mnemonic string")');
  }

  void _loadJs(WebViewController ctrl, String assetsFilePath) async {
    var jsScript = await rootBundle.loadString(assetsFilePath, cache: true);
    var htmlString = """<html><head>
    <script>
    // polyfills
    window.global = window;
    </script>
    <script>${jsScript}</script>
    <script>window.flutterJS.init( '$REEF_MOBILE_CHANNEL_NAME', 
    '$LOG_MSG_IDENT', 
    '$FLUTTER_SUBSCRIBE_METHOD_NAME', 
    '$API_READY_MSG_IDENT', 
    '$TX_SIGNATURE_CONFIRMATION_MSG_IDENT', 
    '$TX_SIGN_CONFIRMATION_JS_FN_NAME')</script>
    </head><body></body></html>""";
    ctrl.loadHtmlString(htmlString).then((value) => ctrl).catchError((err) {
      print('Error loading HTML=$err');
    });
  }

  Set<JavascriptChannel> _createJavascriptChannels() {
    return {
      JavascriptChannel(
        name: REEF_MOBILE_CHANNEL_NAME,
        onMessageReceived: (message) {
          JsApiMessage apiMsg =
              JsApiMessage.fromJson(jsonDecode(message.message));
          if (apiMsg.id == LOG_MSG_IDENT) {
            print('$LOG_MSG_IDENT= ${apiMsg.value}');
          } else if (apiMsg.id == API_READY_MSG_IDENT) {
            jsApiLoaded.future.then((ctrl) => jsApiReady.complete(ctrl));
          } else if (apiMsg.id == TX_SIGNATURE_CONFIRMATION_MSG_IDENT) {
            jsTxSignatureConfirmationMessageSubj.add(apiMsg);
          } else if (int.tryParse(apiMsg.id) == null) {
            jsMessageUnknownSubj.add(apiMsg);
          } else {
            jsMessageSubj.add(apiMsg);
          }
        },
      ),
    };
  }
}

class JsApiMessage {
  late String id;
  late dynamic value;

  JsApiMessage(this.id, this.value);

  JsApiMessage.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        value = json['value'];
}
