import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

class JsApi {
  WebViewController? controller;
  WebView? webView;

  getWebView(){
    if(this.webView == null) {
      this.webView = WebView(javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (ctrl) => this.controller = ctrl,);
    }
    return this.webView;
  }

  Future<String> getReefVals() {
   if( this.controller!=null ){
     return this.controller!.runJavascriptReturningResult('window.reef');
   }
   return Future.delayed(Duration(), ()=>'noCTRL');
  }

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
