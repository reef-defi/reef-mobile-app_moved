import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:reef_mobile_app/components/WebViewStack.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JsApiService {
  final LOG_MSG_IDENT = 'console.log';
  final REEF_MOBILE_CHANNEL_NAME = 'reefMobileChannel';
  final FLUTTER_SUBSCRIBE_METHOD_NAME = 'flutterSubscribe';

  final controllerInit = Completer<WebViewController>();
  final jsApiLoaded = Completer<WebViewController>();
  final jsReefMobileSubj = BehaviorSubject<ReefApiMessage>();

  get widget {
    return WebViewOffstage(
      controller: this.controllerInit,
      loaded: jsApiLoaded,
      jsChannels: _createJavascriptChannels(),
    );
  }

  Future<WebViewController> get _controller => jsApiLoaded.future;

  JsApiService() {
    controllerInit.future.then((ctrl) => _loadJs(ctrl, 'lib/js_api/dist/index.js'));
    //jsCall('testApi("hellooo")').then((value) => print('JS RES=${value}'));
    Future.delayed(Duration(seconds: 10), () {
      jsCall('Object.keys(window).length').then((value) => print('JS RES=${value}'));
      print('FFFF');
    });
    jsCall('Object.keys(window).length').then((value) => print('JS RES=${value}'));
    // jsCall('Object.keys(window.testApi)').then((value) => print('JS RES=${value}'));
    // jsObservableStream('testObs').listen((event) =>print('STR= ${event}'));
  }

  Future<String> jsCall(String executeJs) {
    return _controller
        .then((ctrl) => ctrl.runJavascriptReturningResult(executeJs));
  }

  Stream jsObservableStream(String jsObsRefName) {
    String ident = Random(DateTime.now().millisecondsSinceEpoch)
        .nextInt(9999999)
        .toString();

    jsCall(
        "window['$FLUTTER_SUBSCRIBE_METHOD_NAME']('$jsObsRefName', '$ident')");
    return jsReefMobileSubj.stream
        .where((event) => event.id == ident)
        .map((event) => event.value);
  }

  void _loadJs(WebViewController ctrl, String assetsFilePath) async {
    var jsScript = await rootBundle.loadString(assetsFilePath, cache: true);
    var htmlString = """<html><head>
    <script>${jsScript}</script>
    <script>window.flutterJS.init( '$REEF_MOBILE_CHANNEL_NAME', '$LOG_MSG_IDENT', '$FLUTTER_SUBSCRIBE_METHOD_NAME')</script>
    </head></html>""";
    ctrl.loadHtmlString(htmlString).then((value) => ctrl);
  }

  Set<JavascriptChannel> _createJavascriptChannels() {
    return {
      JavascriptChannel(
        name: REEF_MOBILE_CHANNEL_NAME,
        onMessageReceived: (message) {
          ReefApiMessage apiMsg =
              ReefApiMessage.fromJson(jsonDecode(message.message));
          if (apiMsg.id == LOG_MSG_IDENT) {
            print('$LOG_MSG_IDENT= ${apiMsg.value}');
          } else {
            jsReefMobileSubj.add(apiMsg);
          }
        },
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
