import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reef_mobile_app/service/DAppRequestService.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

import '../components/SignatureContentToggle.dart';
import '../model/ReefAppState.dart';

class DAppPage extends StatefulWidget {
  final ReefAppState reefState;
  final DAppRequestService dAppRequestService = const DAppRequestService();

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
          widget.dAppRequestService
              .handleDAppMsgRequest(value, dappJsApi!.sendDappMsgResponse);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Scaffold(
      appBar: AppBar(
        title: const Text('DApp'),
      ),
      body: Center(
          child: dappJsApi != null
              ? dappJsApi!.widget
              : const CircularProgressIndicator()),
    ));
  }
}
