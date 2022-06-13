import 'dart:convert';

import 'package:reef_mobile_app/model/tokens/TokensCtrl.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class ReefState{
  final JsApiService jsApi;
  late TokenCtrl tokensCtrl;

  ReefState(JsApiService this.jsApi) {
    _initAsync(jsApi);
    tokensCtrl = TokenCtrl(jsApi);
  }

  void _initAsync(JsApiService jsApi) async{
    await _initReefState(jsApi);
    await _initReefObservables(jsApi);
  }

  _initReefState(JsApiService jsApiService) async{
    var injectSigners = [{
      "name": 'test',
      "signer": '',
      "balance": '123000000000000000000',
      "address": '5EUWG6tCA9S8Vw6YpctbPHdSrj95d18uNhRqgDniW3g9ZoYc',
      "evmAddress": '',
      "isEvmClaimed": false,
      "source": 'mobileApp',
      "genesisHash": 'undefined'
    }];
    // var availableNetworks = jsonDecode(await jsApiService.jsCall('jsApi.availableNetworks'));
    await jsApiService.jsCall('jsApi.initReefState("testnet", ${jsonEncode(injectSigners)})');
    /* TODO set from last saved address*/
    // String cachedAddress = '5EUWG6tCA9S8Vw6YpctbPHdSrj95d18uNhRqgDniW3g9ZoYc';
    // jsApiService.jsCall('appState.setCurrentAddress("$cachedAddress")');

  }

  _initReefObservables(JsApiService jsApiService) async {
    jsApiService.jsMessageUnknownSubj.listen((JsApiMessage value) {
      if(value.id == 'appState.currentAddress'){
        print(" TODO save address to cache ${value.value}");
        return;
      }
      print('jsMSG not handled id=${value.id}');
    });

    jsApiService.jsObservableStream('account.selectedSigner\$').listen((signer) {
      print('SEL Signer=$signer');
    });

    /*jsApiService.jsObservableStream('appState.selectedSignerTokenBalances\$').listen((tokens) {
      var tkns = tokens.map(( t)=>t['symbol']);
      print('TKN2222S=${tkns}');
    });*/

  }
}
