import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewFlutterJS extends StatefulWidget {
  final Completer<WebViewController> controller;
  final Completer<void> loaded;
  final Set<JavascriptChannel> jsChannels;
  final bool hidden;

  WebViewFlutterJS({required this.hidden, required this.controller, required this.loaded, required this.jsChannels, Key? key, }) : super(key: key); // Modify

  @override
  State<WebViewFlutterJS> createState() => _WebViewFlutterJSState();
}

class _WebViewFlutterJSState extends State<WebViewFlutterJS> {
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: widget.hidden,
      child:
        WebView(
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: widget.jsChannels,
          onWebViewCreated: (webViewController) {
            _controller = webViewController;
            widget.controller.complete(_controller);
          },
          onPageFinished: (url) {
            widget.loaded.complete(_controller);
          },
        ),
    );
  }
}
