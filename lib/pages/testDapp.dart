import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

import '../model/ReefState.dart';

class DappPage extends StatefulWidget {
  final ReefAppState reefState;

  const DappPage(this.reefState);

  Future<String> _getHtml() async {
    var assetsFilePath = 'lib/js/packages/dApp-test-html-js/dist/index.js';
    String testScriptTags = await _getFlutterJsHeaderTags(assetsFilePath);
    return """<html><head>${testScriptTags}</head><body><h1>hello DApp</h1></body>""";
  }

  @override
  State<DappPage> createState() => _DappPageState();

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

class _DappPageState extends State<DappPage> {
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
        title: const Text('Dapp'),
      ),
      body: Center(
          child: dappJsApi != null
              ? dappJsApi!.widget
              : const CircularProgressIndicator()),
    );
  }

  void _handleDAppMsgRequest(JsApiMessage message, void Function(String reqId, dynamic value) responseFn) {

    switch(message.msgType){
      case 'pub(authorize.tab)':
        // TODO display confirmation message.origin is the app name
        print('HHHNDLLL2 ${message.reqId} ');
        responseFn(message.reqId, true);
        break;
    }
  }

}
