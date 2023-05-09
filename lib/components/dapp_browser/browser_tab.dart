// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/animations.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/dapp_browser/reef_search_delegate.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/service/DAppRequestService.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

const double _fabDimension = 56.0;

/// The demo page for [OpenContainerTransform].
class BrowserTab extends StatefulWidget {
  final int index;

  /// Creates the demo page for [OpenContainerTransform].
  const BrowserTab({super.key, required this.index});

  @override
  State<BrowserTab> createState() {
    return _BrowserTabState();
  }
}

class _BrowserTabState extends State<BrowserTab> {
  ContainerTransitionType _transitionType = ContainerTransitionType.fadeThrough;

  @override
  Widget build(BuildContext context) {
    return _OpenContainerWrapper(
      index: widget.index,
      transitionType: _transitionType,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return _SmallerCard(
          index: widget.index,
          openContainer: openContainer,
          subtitle: "tab",
        );
      },
      onClosed: (data) {},
    );
  }
}

class _OpenContainerWrapper extends StatefulWidget {
  const _OpenContainerWrapper({
    required this.closedBuilder,
    required this.transitionType,
    required this.onClosed,
    required this.index,
  });

  final int index;
  final CloseContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;
  final ClosedCallback<bool?> onClosed;

  @override
  State<_OpenContainerWrapper> createState() => __OpenContainerWrapperState();
}

class __OpenContainerWrapperState extends State<_OpenContainerWrapper> {
  final dAppRequestService = const DAppRequestService();

  NavigationDelegate _getNavigationDelegate(String tabHash) =>
      (navigation) async {
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

  Future<String> _getHtml(String url) async {
    return http.read(Uri.parse(url));
  }

  Future<void> setup([String? url]) async {
    final tabData =
        ReefAppState.instance.browserCtrl.browserModel.tabs[widget.index];
    final html = await _getHtml(url ?? tabData.currentUrl);

    final dappJsApi = JsApiService.dAppInjectedHtml(html,
        url ?? tabData.currentUrl, _getNavigationDelegate(tabData.tabHash));
    dappJsApi.jsDAppMsgSubj.listen((value) {
      dAppRequestService.handleDAppMsgRequest(
          value, dappJsApi.sendDappMsgResponse);
    });

    ReefAppState.instance.browserCtrl.removeWebView(tabHash: tabData.tabHash);

    ReefAppState.instance.browserCtrl.addWebView(
        url: url ?? tabData.currentUrl,
        tabHash: tabData.tabHash,
        webView: dappJsApi.widget,
        jsApiService: dappJsApi,
        webViewController: null);

    setState(() {
      print("CALLED");
    });
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      transitionType: widget.transitionType,
      openBuilder: (BuildContext context, VoidCallback _) {
        //setup();
        return _DetailsPage(index: widget.index);
      },
      onClosed: (data) async {
        await setup();
      },
      tappable: false,
      closedBuilder: widget.closedBuilder,
    );
  }
}

class _SmallerCard extends StatelessWidget {
  const _SmallerCard({
    required this.openContainer,
    required this.subtitle,
    required this.index,
  });

  final int index;
  final VoidCallback openContainer;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _InkWellOverlay(
      openContainer: openContainer,
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                    child: Text(
                  Uri.parse(ReefAppState.instance.browserCtrl.browserModel
                          .tabs[index].currentUrl)
                      .host,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                )),
                InkWell(
                    onTap: () {
                      ReefAppState.instance.browserCtrl.removeWebView(
                          tabHash: ReefAppState.instance.browserCtrl
                              .browserModel.tabs[index].tabHash);
                    },
                    child: const Icon(
                      Icons.close,
                      size: 20,
                    ))
              ],
            ),
          ),
          Expanded(
            child: Observer(
                builder: (_) => Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(
                        Icons.web,
                        size: 80,
                      ),
                    ))),
          ),
        ],
      ),
    );
  }
}

class _InkWellOverlay extends StatelessWidget {
  const _InkWellOverlay({
    this.openContainer,
    this.height,
    this.child,
  });

  final VoidCallback? openContainer;
  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: InkWell(
        onTap: openContainer,
        child: child,
      ),
    );
  }
}

class _DetailsPage extends StatelessWidget {
  final int index;
  const _DetailsPage(
      {this.includeMarkAsDoneButton = true, required this.index});

  final bool includeMarkAsDoneButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        Flex(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          direction: Axis.horizontal,
          children: [
            IconButton(
                onPressed: () {
                  ReefAppState.instance.browserCtrl.browserModel.tabs[index]
                      .webViewController
                      ?.goBack();
                },
                icon: const Icon(Icons.arrow_back)),
            IconButton(
                onPressed: () {
                  ReefAppState.instance.browserCtrl.browserModel.tabs[index]
                      .webViewController
                      ?.goForward();
                },
                icon: const Icon(Icons.arrow_forward)),
            IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: ReefSearchDelegate());
                },
                icon: const Icon(Icons.search)),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.tab)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
          ],
        )
      ],
      appBar: AppBar(
        backgroundColor: Styles.darkBackgroundColor,
        title: Observer(
            builder: (_) => Text(Uri.parse(ReefAppState
                    .instance.browserCtrl.browserModel.tabs[index].currentUrl)
                .host)),
        actions: <Widget>[
          if (includeMarkAsDoneButton)
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () => Navigator.pop(context, true),
              tooltip: 'Mark as done',
            )
        ],
      ),
      body: Observer(builder: (context) {
        print("REFRESHING");
        return ReefAppState.instance.browserCtrl.browserModel.tabs[index]
                .jsApiService?.widget ??
            const Center(
              child: Text("noooooo !!!"),
            );
      }),
    );
  }

  String getURL(String currentUrl) {
    final url = Uri.parse(currentUrl);
    final currentUri = Uri.https(url.authority, url.path);
    return currentUri.toString();
  }
}
