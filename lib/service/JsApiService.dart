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

  final NavigationDelegate? navigationDelegate;

  // when web page loads
  final jsApiReady = Completer<WebViewController>();

  final jsMessageSubj = BehaviorSubject<JsApiMessage>();
  final jsTxSignatureConfirmationMessageSubj = BehaviorSubject<JsApiMessage>();
  final jsDAppMsgSubj = BehaviorSubject<JsApiMessage>();
  final jsMessageUnknownSubj = BehaviorSubject<JsApiMessage>();

  late Widget _wdg;

  WebViewFlutterJS get widget {
    print('JS API SERVICE GET WIDGET $flutterJsFilePath');
    return WebViewFlutterJS(
      hidden: hiddenWidget,
      controller: controllerInit,
      loaded: jsApiLoaded,
      navigationDelegate: navigationDelegate,
      jsChannels: _createJavascriptChannels(),
    );
  }

  Future<WebViewController> get _controller => jsApiReady.future;

  JsApiService._(this.hiddenWidget, this.flutterJsFilePath,
      {String? url, String? html, this.navigationDelegate}) {
    // print('JS API SERVICE CREATE $flutterJsFilePath');
    renderWithFlutterJS(flutterJsFilePath, html, url);
  }

  JsApiService.reefAppJsApi()
      : this._(true, 'lib/js/packages/reef-mobile-js/dist/index.js',
            url: 'https://app.reef.io');

  JsApiService.dAppInjectedHtml(String html, String? baseUrl,
      [NavigationDelegate? navigationDelegate])
      : this._(false, 'lib/js/packages/dApp-js/dist/index.js',
            html: html, url: baseUrl, navigationDelegate: navigationDelegate);

  void renderWithFlutterJS(
      String fJsFilePath, String? htmlString, String? baseUrl) {
    print("got here");
    if (controllerInit.isCompleted) return;
    print("got there");
    htmlString ??= "<html><head></head><body></body></html>";
    controllerInit.future.then((ctrl) {
      print("and there");
      return _getFlutterJsHeaderTags(fJsFilePath).then((headerTags) {
        print("and also there");
        return _insertHeaderTags(htmlString!, headerTags);
      }).then((htmlString) {
        print("and finally here");
        return _renderHtml(ctrl, htmlString, baseUrl);
      });
    });
  }

  // for js methods with no return value
  Future<void> jsCallVoidReturn(String executeJs) {
    return _controller.then((ctrl) => ctrl.runJavascript(executeJs));
  }

  Future<String> jsCall(String executeJs) {
    return _controller
        .then((ctrl) => ctrl.runJavascriptReturningResult(executeJs));
  }

  Future jsPromise(String jsObsRefName) {
    return jsObservable(jsObsRefName).first;
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
        .then((_) => ctrl)
        .catchError((err) {
      print('Error loading HTML=$err');
    });
  }

  Set<JavascriptChannel> _createJavascriptChannels() {
    return {
      JavascriptChannel(
        name: REEF_MOBILE_CHANNEL_NAME,
        onMessageReceived: (message) {
          print("------------received message here");
          JsApiMessage apiMsg =
              JsApiMessage.fromJson(jsonDecode(message.message));
          if (apiMsg.streamId == LOG_STREAM_ID) {
            print('$LOG_STREAM_ID= ${apiMsg.value}');
          } else if (apiMsg.streamId == API_READY_STREAM_ID) {
            if (!jsApiLoaded.isCompleted) {
              jsApiLoaded.future.then((ctrl) => jsApiReady.complete(ctrl));
            }
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
