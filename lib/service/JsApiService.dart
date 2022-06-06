import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:reef_mobile_app/components/WebViewStack.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JsApiService {
  final controllerInit = Completer<WebViewController>();
  final jsApiLoaded = Completer<WebViewController>();
  final jsReefMobileSubj = BehaviorSubject<ReefApiMessage>();

  get widget {
    return WebViewOffstage(controller: this.controllerInit, loaded: jsApiLoaded, jsChannels: _createJavascriptChannels(),);
  }

  Future<WebViewController> get _controller => jsApiLoaded.future;

  JsApiService(){
    controllerInit.future.then(( ctrl) =>_loadJs(ctrl, 'lib/js_api/dist.js'));
    jsCall('testApi("hellooo")').then((value) => print('JS RES=${value}'));
    jsObservableStream('testObs').listen((event) =>print('STR= ${event}'));
  }

  Future<String> jsCall(String executeJs) {
     return _controller.then((ctrl)=>ctrl.runJavascriptReturningResult(executeJs));
  }

  Stream jsObservableStream(String jsObsRefName){
    String ident = Random(DateTime.now().millisecondsSinceEpoch).nextInt(9999999).toString();

    jsCall("window.reefMobileObservables.subscribeTo('$jsObsRefName', '$ident')");
    return jsReefMobileSubj.stream.where((event) => event.id==ident).map((event) => event.value);
  }

  void _loadJs(WebViewController ctrl, String assetsFilePath) async {
    var jsScript = await rootBundle.loadString(assetsFilePath, cache: true);
    var htmlString = "<html><head><script>${jsScript}</script></head></html>";
    ctrl.loadHtmlString(htmlString).then((value) => ctrl);
  }

  Set<JavascriptChannel> _createJavascriptChannels() {
    return {
      JavascriptChannel(
        name: 'flutterLog',
        onMessageReceived: (message) {
          print('js log=${message.message}');
        },
      ),
      JavascriptChannel(
        name: 'reefMobile',
        onMessageReceived: (message) =>jsReefMobileSubj.add(ReefApiMessage.fromJson(jsonDecode(message.message))),
      ),
    };
  }
}

class ReefApiMessage {
  late String id;
  late dynamic value;
  ReefApiMessage(this.id, this.value);

  ReefApiMessage.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        value = json['value'];
}
