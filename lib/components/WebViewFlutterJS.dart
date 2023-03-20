import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/auth_url/auth_url.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WebViewFlutterJS extends StatefulWidget {
  final Completer<WebViewController> controller;
  final Completer<void> loaded;
  final Set<JavascriptChannel> jsChannels;
  final bool hidden;

  WebViewFlutterJS({
    required this.hidden,
    required this.controller,
    required this.loaded,
    required this.jsChannels,
    Key? key,
  }) : super(key: key); // Modify

  @override
  State<WebViewFlutterJS> createState() => _WebViewFlutterJSState();
}

class _WebViewFlutterJSState extends State<WebViewFlutterJS> {
  WebViewController? _controller;
  bool urlDisallowed = false;
  String url = '';

  _setAuthUrl(bool _urlDisallowed, String _url) {
    setState(() {
      urlDisallowed = _urlDisallowed;
      url = _url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: widget.hidden,
      child: Column(children: [
        if (urlDisallowed)
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              color: Styles.primaryAccentColor,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  AppLocalizations.of(context)!.you_disabled_this_dapp_domain,
                  style: TextStyle(color: Colors.white),
                ),
                const Gap(4),
                TextButton(
                    onPressed: () async {
                      await ReefAppState.instance.storage
                          .saveAuthUrl(AuthUrl(url, true));
                      _setAuthUrl(false, url);
                      _controller!.reload();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(55, 20),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.enable,
                      style: TextStyle(
                          color: Styles.whiteColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    )),
              ])),
        Expanded(
            child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: widget.jsChannels,
          onWebViewCreated: (webViewController) {
            _controller = webViewController;
            if (!widget.controller.isCompleted) {
              widget.controller.complete(_controller);
            }
          },
          onPageFinished: (url) {
            var strippedUrl = stripUrl(url);
            if (strippedUrl.isNotEmpty) {
              ReefAppState.instance.storage
                  .getAuthUrl(strippedUrl)
                  .then((authUrl) {
                if (authUrl != null && !authUrl.isAllowed) {
                  _setAuthUrl(true, strippedUrl);
                }
              });
            }
            widget.loaded.complete(_controller);
          },
        )),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    print('WEBVIEW DISPOSEDDDDD');
  }
}
