import 'dart:collection';

import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

import 'account.dart';

class AccountCtrl {

  final Account account = Account();

  AccountCtrl(JsApiService jsApi, StorageService storage){
    initSavedDeviceAccountAddress(jsApi, storage);
    initJsObservables(jsApi, storage);
  }

  void initJsObservables(JsApiService jsApi, StorageService storage) {
    jsApi.jsObservableStream('account.selectedSigner\$').listen(( signer) async {
      print('SEL Signer=$signer');
      LinkedHashMap s=signer;
      await storage.setValue(StorageKey.selected_address.name, s['address']);
      account.setSelectedSigner(ReefSigner(s["address"], s["name"]));
    });
  }

  void initSavedDeviceAccountAddress(JsApiService jsApi,StorageService storage) async {
    // TODO check if this address also exists in keystore
    var savedAddress = await storage.getValue(StorageKey.selected_address.name);
    print('SET SAVED ADDRESS=${savedAddress}');
    if(savedAddress!=null) {
      jsApi.jsCall('appState.setCurrentAddress("$savedAddress")');
    }
  }

}
