import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/browser/browser_model.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserCtrl {
  final BrowserModel browserModel;

  BrowserCtrl() : browserModel = BrowserModel();

  void addWebView(
      {required String url,
      required String tabHash,
      required Widget webView,
      required JsApiService? jsApiService,
      required WebViewController? webViewController}) {
    browserModel.addWebView(
        url: url,
        tabHash: tabHash,
        webView: webView,
        webViewController: webViewController,
        jsApiService: jsApiService);
  }

  void updateWebViewUrl({required String tabHash, required String newUrl}) {
    browserModel.updateWebViewUrl(tabHash: tabHash, newUrl: newUrl);
  }

  void updateWebViewCtrl(
      {required String tabHash, required WebViewController webViewController}) {
    browserModel.updateWebViewCtrl(
        tabHash: tabHash, webViewController: webViewController);
  }

  String? getTabCurrentUrl({required String tabHash}) {
    final tabIndex =
        browserModel.tabs.indexWhere((tabData) => tabData.tabHash == tabHash);
    if (tabIndex == -1) {
      return null;
    }
    return browserModel.tabs[tabIndex].currentUrl;
  }

  void removeWebView({required String tabHash}) {
    browserModel.removeWebView(tabHash: tabHash);
  }
}
