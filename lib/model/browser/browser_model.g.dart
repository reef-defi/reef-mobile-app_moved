// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BrowserModel on _BrowserModel, Store {
  late final _$tabsAtom = Atom(name: '_BrowserModel.tabs', context: context);

  @override
  List<TabData> get tabs {
    _$tabsAtom.reportRead();
    return super.tabs;
  }

  @override
  set tabs(List<TabData> value) {
    _$tabsAtom.reportWrite(value, super.tabs, () {
      super.tabs = value;
    });
  }

  late final _$_BrowserModelActionController =
      ActionController(name: '_BrowserModel', context: context);

  @override
  void addWebView(
      {required String url,
      required String tabHash,
      required Widget webView,
      required JsApiService? jsApiService,
      required WebViewController? webViewController}) {
    final _$actionInfo = _$_BrowserModelActionController.startAction(
        name: '_BrowserModel.addWebView');
    try {
      return super.addWebView(
          url: url,
          tabHash: tabHash,
          webView: webView,
          jsApiService: jsApiService,
          webViewController: webViewController);
    } finally {
      _$_BrowserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateWebViewUrl({required String tabHash, required String newUrl}) {
    final _$actionInfo = _$_BrowserModelActionController.startAction(
        name: '_BrowserModel.updateWebViewUrl');
    try {
      return super.updateWebViewUrl(tabHash: tabHash, newUrl: newUrl);
    } finally {
      _$_BrowserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateWebViewCtrl(
      {required String tabHash, required WebViewController webViewController}) {
    final _$actionInfo = _$_BrowserModelActionController.startAction(
        name: '_BrowserModel.updateWebViewCtrl');
    try {
      return super.updateWebViewCtrl(
          tabHash: tabHash, webViewController: webViewController);
    } finally {
      _$_BrowserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeWebView({required String tabHash}) {
    final _$actionInfo = _$_BrowserModelActionController.startAction(
        name: '_BrowserModel.removeWebView');
    try {
      return super.removeWebView(tabHash: tabHash);
    } finally {
      _$_BrowserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
tabs: ${tabs}
    ''';
  }
}
