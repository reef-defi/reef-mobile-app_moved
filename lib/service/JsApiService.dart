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

  late Widget _wdg;

  get widget {
    return WebViewFlutterJS(
      hidden: hiddenWidget,
      controller: controllerInit,
      loaded: jsApiLoaded,
      jsChannels: _createJavascriptChannels(),
    );
  }

  Future<WebViewController> get _controller => jsApiReady.future;

  JsApiService._(bool this.hiddenWidget, String this.flutterJsFilePath,
      String? htmlString) {
    _renderHtmlWithFlutterJS(flutterJsFilePath,
        htmlString ?? "<html><head></head><body></body></html>");
  }

  JsApiService.reefAppJsApi()
      : this._(true, 'lib/js/packages/reef-mobile-js/dist/index.js', null);

  JsApiService.dAppInjectedHtml(String html)
      : this._(false, 'lib/js/packages/dApp-js/dist/index.js', html);

  void _renderHtmlWithFlutterJS(String fJsFilePath, String htmlString) {
    controllerInit.future.then((ctrl) {
      return _getFlutterJsHeaderTags(fJsFilePath).then((headerTags) {
        return _insertHeaderTags(htmlString, headerTags);
      }).then((htmlString) {
        return _renderHtml(ctrl, htmlString);
      });
    });
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
        .where((event) => event.id == ident)
        .map((event) => event.value);
  }

  void confirmTxSignature(String signatureIdent, String mnemonic) {
    jsCall(
        '${TX_SIGN_CONFIRMATION_JS_FN_NAME}("$signatureIdent", "$mnemonic")');
  }

  Future<String> _getFlutterJsHeaderTags(String assetsFilePath) async {
    var jsScript = await rootBundle.loadString(assetsFilePath, cache: true);
    return """
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

  void _renderHtml(WebViewController ctrl, String htmlString) async {
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
