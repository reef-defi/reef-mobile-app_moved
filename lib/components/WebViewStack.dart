import 'dart:async';
import 'dart:ffi';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewOffstage extends StatefulWidget {
  WebViewOffstage({required this.controller, required this.loaded, Key? key, }) : super(key: key); // Modify

  final Completer<WebViewController> controller;
  final Completer<void> loaded;

  @override
  State<WebViewOffstage> createState() => _WebViewOffstageState();
}

class _WebViewOffstageState extends State<WebViewOffstage> {
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: true,
      child:
        WebView(
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (webViewController) {
            _controller = webViewController;
            widget.controller.complete(_controller);
          },
          onPageFinished: (url) {
            print('FINISHED PAGE=${url}');
            widget.loaded.complete(_controller);
          },
        ),
    );
  }
}
