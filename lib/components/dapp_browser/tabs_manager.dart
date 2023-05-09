import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reef_mobile_app/components/dapp_browser/tabs_display.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/service/DAppRequestService.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class TabsManager extends StatefulWidget {
  const TabsManager({super.key});

  @override
  State<TabsManager> createState() => _TabsManagerState();
}

class _TabsManagerState extends State<TabsManager> {
  List<String> tabs = [];
  final dAppRequestService = const DAppRequestService();

  Future<String> _getHtml(String url) async {
    return http.read(Uri.parse(url));
  }

  NavigationDelegate _getNavigationDelegate(String tabHash) => (navigation) {
        if (navigation.isForMainFrame) {
          try {
            Uri.parse(navigation.url);
            ReefAppState.instance.browserCtrl
                .updateWebViewUrl(tabHash: tabHash, newUrl: navigation.url);
          } catch (e) {
            return NavigationDecision.navigate;
          }
        }

        return NavigationDecision.navigate;
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Styles.darkBackgroundColor,
        child: const Icon(Icons.add),
        onPressed: () async {
          final tabHash = getRandString(20);
          JsApiService? dappJsApi;
          final html = await _getHtml("https://google.com");

          dappJsApi = JsApiService.dAppInjectedHtml(
              html, "https://google.com", _getNavigationDelegate(tabHash));
          dappJsApi.jsDAppMsgSubj.listen((value) {
            dAppRequestService.handleDAppMsgRequest(
                value, dappJsApi!.sendDappMsgResponse);
          });

          ReefAppState.instance.browserCtrl.addWebView(
              url: "https://google.com",
              tabHash: tabHash,
              webView: dappJsApi.widget,
              jsApiService: dappJsApi,
              webViewController: null);
        },
      ),
      appBar: AppBar(
        backgroundColor: Styles.darkBackgroundColor,
        title: const Text("Reef Browser"),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: const [
          Expanded(child: TabsDisplay()),
          Divider(
            height: 0.4,
            thickness: 0.4,
          ),
        ],
      ),
    );
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}
