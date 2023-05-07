import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:reef_mobile_app/components/WebViewFlutterJS.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JsApiService {
  final flutterJsFilePath;
  final bool hiddenWidget;
  final LOG_STREAM_ID = '_console.log';
  final API_READY_STREAM_ID = '_windowApisReady';
  final TX_SIGNATURE_CONFIRMATION_STREAM_ID = '_txSignStreamId';
  final DAPP_MSG_CONFIRMATION_STREAM_ID = '_dAppMsgIdent';
  final TX_SIGN_CONFIRMATION_JS_FN_NAME = '_txSignConfirmationJsFnName';
  final DAPP_MSG_CONFIRMATION_JS_FN_NAME = '_dAppMsgConfirmationJsFnName';
  final REEF_MOBILE_CHANNEL_NAME = 'reefMobileChannel';
  final FLUTTER_SUBSCRIBE_METHOD_NAME = 'flutterSubscribe';

  final controllerInit = Completer<WebViewController>();
  final jsApiLoaded = Completer<WebViewController>();

  // when web page loads
  final jsApiReady = Completer<WebViewController>();

  final jsMessageSubj = BehaviorSubject<JsApiMessage>();
  final jsTxSignatureConfirmationMessageSubj = BehaviorSubject<JsApiMessage>();
  final jsDAppMsgSubj = BehaviorSubject<JsApiMessage>();
  final jsMessageUnknownSubj = BehaviorSubject<JsApiMessage>();

  late Widget _wdg;

  get widget {
    // print('JS API SERVICE GET WIDGET $flutterJsFilePath');
    return WebViewFlutterJS(
      hidden: hiddenWidget,
      controller: controllerInit,
      loaded: jsApiLoaded,
      jsChannels: _createJavascriptChannels(),
    );
  }

  Future<WebViewController> get _controller => jsApiReady.future;

  JsApiService._(bool this.hiddenWidget, String this.flutterJsFilePath,
      {String? url, String? html}) {
    // print('JS API SERVICE CREATE $flutterJsFilePath');
    _renderWithFlutterJS(flutterJsFilePath, html, url);
  }

  JsApiService.reefAppJsApi()
      : this._(true, 'lib/js/packages/reef-mobile-js/dist/index.js',
            url: 'https://app.reef.io');

  JsApiService.dAppInjectedHtml(String html, String? baseUrl)
      : this._(false, 'lib/js/packages/dApp-js/dist/index.js',
            html: html, url: baseUrl);

  void _renderWithFlutterJS(
      String fJsFilePath, String? htmlString, String? baseUrl) {
    htmlString ??= "<html><head></head><body></body></html>";
    controllerInit.future.then((ctrl) {
      return _getFlutterJsHeaderTags(fJsFilePath).then((headerTags) {
        return _insertHeaderTags(htmlString!, headerTags);
      }).then((htmlString) {
        return _renderHtml(ctrl, htmlString, baseUrl);
      });
    });
  }

  // for js methods with no return value
  Future<void> jsCallVoidReturn(String executeJs) {
    return _controller.then((ctrl) => ctrl.runJavascript(executeJs));
  }

  Future<dynamic> jsCall<T>(String executeJs) async {
    dynamic res = await _controller
        .then((ctrl) => ctrl.runJavascriptReturningResult(executeJs));
    return T == bool?_resolveBooleanValue(res) : res;
  }

  Future jsPromise<T>(String jsObsRefName) async {
    dynamic res = await jsObservable(jsObsRefName).first;
    return T == bool?_resolveBooleanValue(res) : res;
  }

  Stream jsObservable(String jsObsRefName) {
    String ident = Random().nextInt(9999999).toString();

    jsCall(
        "window['$FLUTTER_SUBSCRIBE_METHOD_NAME']('$jsObsRefName', '$ident')");
    return jsMessageSubj.stream
        .where((event) => event.streamId == ident)
        .map((event) => event.value);
  }

  void confirmTxSignature(String reqId, String? mnemonic) {
    jsCall('${TX_SIGN_CONFIRMATION_JS_FN_NAME}("$reqId", "${mnemonic ?? ''}")');
  }

  void sendDappMsgResponse(String reqId, dynamic value) {
    jsCall('${DAPP_MSG_CONFIRMATION_JS_FN_NAME}(`$reqId`, `$value`)');
  }

  dynamic _resolveBooleanValue(dynamic res){
      print(' CALL $res');
      return res == true ||
          res == 'true' ||
          res == 1 ||
          res == '1' ||
          res == '"true"';
  }

  Future<String> _getFlutterJsHeaderTags(String assetsFilePath) async {
    var jsScript = await rootBundle.loadString(assetsFilePath, cache: true);
    return """
    <script>
    // polyfills
    window.global = window;
    </script>
    <script>${jsScript}</script>
    <script>window.flutterJS.init( 
    '$REEF_MOBILE_CHANNEL_NAME', 
    '$LOG_STREAM_ID', 
    '$FLUTTER_SUBSCRIBE_METHOD_NAME', 
    '$API_READY_STREAM_ID', 
    '$TX_SIGNATURE_CONFIRMATION_STREAM_ID', 
    '$TX_SIGN_CONFIRMATION_JS_FN_NAME',
    '$DAPP_MSG_CONFIRMATION_STREAM_ID', 
    '$DAPP_MSG_CONFIRMATION_JS_FN_NAME',
    )</script>
    """;
  }

  String _insertHeaderTags(String htmlString, String headerTags) {
    var insertAfterStr = '<head>';
    var insertAt = htmlString.indexOf(insertAfterStr) + insertAfterStr.length;
    if (insertAt == insertAfterStr.length) {
      print('ERROR inserting flutter JS script tags');
      return '';
    }
    return htmlString.substring(0, insertAt) +
        headerTags +
        htmlString.substring(insertAt);
  }

  void _renderHtml(
      WebViewController ctrl, String htmlString, String? baseUrl) async {
    ctrl
        .loadHtmlString(htmlString, baseUrl: baseUrl)
        .then((value) => ctrl)
        .catchError((err) {
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
          if (apiMsg.streamId == LOG_STREAM_ID) {
            print('$LOG_STREAM_ID= ${apiMsg.value}');
          } else if (apiMsg.streamId == API_READY_STREAM_ID) {
            jsApiLoaded.future.then((ctrl) => jsApiReady.complete(ctrl));
          } else if (apiMsg.streamId == TX_SIGNATURE_CONFIRMATION_STREAM_ID) {
            jsTxSignatureConfirmationMessageSubj.add(apiMsg);
          } else if (apiMsg.streamId == DAPP_MSG_CONFIRMATION_STREAM_ID) {
            jsDAppMsgSubj.add(apiMsg);
          } else if (int.tryParse(apiMsg.streamId) == null) {
            jsMessageUnknownSubj.add(apiMsg);
          } else {
            jsMessageSubj.add(apiMsg);
          }
        },
      ),
    };
  }

  void rejectTxSignature(String signatureIdent) {
    confirmTxSignature(signatureIdent, '_canceled');
  }
}

class JsApiMessage {
  late String streamId;
  late String msgType;
  late String reqId;
  late dynamic value;
  late String? url;

  JsApiMessage(this.streamId, this.value, this.msgType, this.reqId, this.url);

  JsApiMessage.fromJson(Map<String, dynamic> json)
      : streamId = json['streamId'],
        reqId = json['reqId'],
        value = json['value'],
        url = json['url'],
        msgType = json['msgType'];
}
