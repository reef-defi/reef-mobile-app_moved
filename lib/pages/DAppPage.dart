import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reef_mobile_app/service/DAppRequestService.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:http/http.dart' as http;

import '../components/SignatureContentToggle.dart';
import '../model/ReefAppState.dart';

class DAppPage extends StatefulWidget {
  // final url = 'https://min-dapp.web.app';
  final url = 'https://app.reef.io';
  final ReefAppState reefState;
  final DAppRequestService dAppRequestService = const DAppRequestService();

  const DAppPage(this.reefState);

  Future<String> _getHtml(String url) async {
    return http.read(Uri.parse(url));
  }
/*
  Future<String> _getTestHtml() async {
    var assetsFilePath = 'lib/js/packages/dApp-test-html-js/public/js/index.js';
    String testScriptTags = await _getFlutterJsHeaderTags(assetsFilePath);
    return """<html><head>${testScriptTags}<style>body{font-size: 3em;}</style>
    <script>
    var request = new XMLHttpRequest();
    request.open('GET', '/pocket.png', true);
    request.send(null);
    request.onreadystatechange = function (e) {
    console.log('LOADDDD', e)
        // if (request.readyState === 4 && request.status === 200) {
        //     var type = request.getResponseHeader('Content-Type');
        //     if (type.indexOf("text") !== 1) {
        //         return request.responseText;
        //     }
        // }
    }
    </script>
     </head><body><h3>hello DApp</h3><br/>IMG=http://localhost:8080/reef-logo.png <img src='http://localhost:8080/reef-logo.png'/> </body></html>""";
  }
*/

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

      /*setState(() {
        dappJsApi = JsApiService.dAppInjectedUrl(widget.url);
        dappJsApi?.jsDAppMsgSubj.listen((value) {
          widget.dAppRequestService
              .handleDAppMsgRequest(value, dappJsApi!.sendDappMsgResponse);
        });
      });*/

    // widget._getTestHtml().then((html) {
    widget._getHtml(widget.url).then((html) {
      setState(() {
        dappJsApi = JsApiService.dAppInjectedHtml(html, widget.url);
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
