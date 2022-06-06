import 'dart:async';

import 'package:flutter/services.dart';
import 'package:reef_mobile_app/components/WebViewStack.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JsApi {
  final controllerInit = Completer<WebViewController>();
  final jsApiLoaded = Completer<WebViewController>();

  JsApi(){
    controller.then((value) =>getReefVals(value)).then((v)
    {
      print('LLLLL ${v}');
          controller.then((value) => getReefVals(value)).then((value) => print('LLLASTTT $value'));
    });
    controllerInit.future.then(( ctrl) =>loadJs(ctrl, 'lib/js_api/dist.js'));
  }

  Future<WebViewController> get  controller {
    print('api lll-${jsApiLoaded.isCompleted}');
    return jsApiLoaded.future;
  }

  getWebView(){
    return WebViewOffstage(controller: this.controllerInit, loaded: jsApiLoaded, );
  }

  Future<String> getReefVals(WebViewController controller) {
     return controller.runJavascriptReturningResult('window.reef');
  }

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  loadJs(WebViewController ctrl, String assetsFilePath) async {
    var jsScript = await rootBundle.loadString(assetsFilePath, cache: true);
    var htmlString = "<html><head><script>${jsScript}</script></head></html>";
    ctrl.loadHtmlString(htmlString).then((value) => ctrl);
  }
}
