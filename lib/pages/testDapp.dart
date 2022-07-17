import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

import '../model/ReefState.dart';

class DappPage extends StatefulWidget {
  final ReefAppState reefState;

  DappPage(this.reefState);

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
          print('DAPPMSG ${value.msgType}');
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dapp'),
      ),
      body: Center(
          child: dappJsApi != null
              ? dappJsApi!.widget
              : CircularProgressIndicator()),
    );
  }
}
