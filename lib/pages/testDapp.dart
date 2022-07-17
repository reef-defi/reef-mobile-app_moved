import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

import '../model/ReefState.dart';

class DappPage extends StatefulWidget {
  DappPage(this.reefState);
  final ReefAppState reefState;
  final dappJsApi = JsApiService.dAppInjectedHtml("""<html><head><script>
     
      // const extensions = await web3Enable('hello dapp name');
      console.log('EXTTTTT112',window.injectedWeb3);
      </script></head><body><h1>hello DApp</h1></body>""");

  @override
  State<DappPage> createState() => _DappPageState();
}

class _DappPageState extends State<DappPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dapp'),
      ),
      body: Center(
        child: widget.dappJsApi.widget
      ),
    );
  }

}
