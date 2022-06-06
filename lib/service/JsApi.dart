import 'dart:async';

import 'package:flutter/services.dart';
import 'package:reef_mobile_app/components/WebViewStack.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JsApiService {
  final controllerInit = Completer<WebViewController>();
  final jsApiLoaded = Completer<WebViewController>();

  get widget {
    return WebViewOffstage(controller: this.controllerInit, loaded: jsApiLoaded, jsChannels: _createJavascriptChannels(),);
  }

  Future<WebViewController> get  _controller => jsApiLoaded.future;

  JsApiService(){
    // _controller.then((value) =>getReefVals(value)).then((v)=>print('LLLLL ${v}'));
    // _controller.then((value) => getApiCall(value)).then((value) => print('LLLASTTT $value'));
    controllerInit.future.then(( ctrl) =>_loadJs(ctrl, 'lib/js_api/dist.js'));
  }

  Future<String> getReefVals(WebViewController controller) {
     return controller.runJavascriptReturningResult('window.reef');
  }

  Future<String> getApiCall(WebViewController controller) {
     return controller.runJavascriptReturningResult('window.getErr("wrks")');
  }

  _loadJs(WebViewController ctrl, String assetsFilePath) async {
    var jsScript = await rootBundle.loadString(assetsFilePath, cache: true);
    var htmlString = "<html><head><script>${jsScript}</script></head></html>";
    ctrl.loadHtmlString(htmlString).then((value) => ctrl);
  }

  Set<JavascriptChannel> _createJavascriptChannels() {
    return {
      JavascriptChannel(
        name: 'flutterLog',
        onMessageReceived: (message) {
          print('js channel=${message.message}');
        },
      ),
    };
  }
}
