import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

import '../model/ReefAppState.dart';

class DAppPage extends StatefulWidget {
  final ReefAppState reefState;

  const DAppPage(this.reefState);

  Future<String> _getHtml() async {
    var assetsFilePath = 'lib/js/packages/dApp-test-html-js/dist/index.js';
    String testScriptTags = await _getFlutterJsHeaderTags(assetsFilePath);
    return """<html><head>${testScriptTags}</head><body><h1>hello DApp</h1></body>""";
  }

  @override
  State<DAppPage> createState() => _DAppPageState();

  Future<String> _getFlutterJsHeaderTags(String assetsFilePath) async {
    var jsScript = await rootBundle.loadString(assetsFilePath, cache: false);
    return """
    <script>
    // polyfills
    window.global = window;
    </script>
    <script>${jsScript}</script>
    """;
  }
}

class _DAppPageState extends State<DAppPage> {
  JsApiService? dappJsApi;

  @override
  void initState() {
    super.initState();

    widget._getHtml().then((html) {
      setState(() {
        dappJsApi = JsApiService.dAppInjectedHtml(html);
        dappJsApi?.jsDAppMsgSubj.listen((value) {
          _handleDAppMsgRequest(value, dappJsApi!.sendDappMsgResponse);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DApp'),
      ),
      body: Center(
          child: dappJsApi != null
              ? dappJsApi!.widget
              : const CircularProgressIndicator()),
    );
  }

  void _handleDAppMsgRequest(JsApiMessage message, void Function(String reqId, dynamic value) responseFn) {
    if (message.msgType == 'pub(phishing.redirectIfDenied)') {
      print('flutter DAPP req=${message.msgType} value= ${message.value}');
      responseFn(message.reqId, redirectIfPhishing(message.value['url']));
    }

    if (message.msgType != 'pub(authorize.tab)' && !ensureUrlAuthorized(message.value['url'])) {
      print('Domain not authorized= ${message.value['url']}');
      return;
    }

    switch(message.msgType){
      case 'pub(bytes.sign)':
        print("TODO handle request");
        break;
      case 'pub(extrinsic.sign)':
        print("TODO handle request");
        break;
      case 'pub(authorize.tab)':
        // TODO display confirmation - message.value.origin is the app name
        responseFn(message.reqId, true);
        break;

      case 'pub(accounts.list)':
        // TODO return this.accountsList(url, request as RequestAccountList);
        responseFn(message.reqId, []);
      break;
    }
  }

  bool redirectIfPhishing(String url) {
    // TODO check against list
    return false;
  }

  bool ensureUrlAuthorized(String url) {
    // TODO check against authorized domains
    return true;
  }

}
