import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/dapp_browser/browser_tab.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';

class TabsDisplay extends StatefulWidget {
  const TabsDisplay({super.key});

  @override
  State<TabsDisplay> createState() => _TabsDisplayState();
}

class _TabsDisplayState extends State<TabsDisplay> {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisSpacing: 8, crossAxisSpacing: 8, maxCrossAxisExtent: 200),
        itemBuilder: (context, index) => BrowserTab(index: index),
        itemCount: ReefAppState.instance.browserCtrl.browserModel.tabs.length,
      );
    });
  }
}
