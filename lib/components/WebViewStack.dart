import 'dart:async';
import 'dart:ffi';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewStack extends StatefulWidget {
  WebViewStack({required this.controller, Key? key}) : super(key: key); // Modify

  final Completer<WebViewController> controller;   // Add this attribute
  final Completer<void> loaded = Completer();

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  var loadingPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebView(
          initialUrl: 'https://flutter.dev',
          // Add from here ...
          onWebViewCreated: (webViewController) {
            widget.controller.complete(webViewController);
          },
          // ... to here.
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            widget.loaded.complete();
            setState(() {
              loadingPercentage = 100;
            });
          },
        ),
        // if (loadingPercentage < 100)
        //   LinearProgressIndicator(
        //     value: loadingPercentage / 100.0,
        //   ),
      ],
    );
  }
}
