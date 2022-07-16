import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

import 'account.dart';

class AccountCtrl {
  final Account account = Account();
  final JsApiService jsApi;

  AccountCtrl(this.jsApi, StorageService storage) {
    _initSavedDeviceAccountAddress(jsApi, storage);
    _initJsObservables(jsApi, storage);
    _initWasm(jsApi);
  }

  void _initJsObservables(JsApiService jsApi, StorageService storage) {
    jsApi.jsObservable('account.selectedSigner\$').listen((signer) async {
      LinkedHashMap s = signer;
      await storage.setValue(StorageKey.selected_address.name, s['address']);
      account.setSelectedSigner(toReefSigner(s));
    });

    account.setLoadingSigners(true);
    jsApi.jsObservable('account.availableSigners\$').listen(( signers) async {
      account.setLoadingSigners(false);
      var reefSigners = List<ReefSigner>.from(signers.map((s)=>toReefSigner(s)));
      account.setSigners(reefSigners);
      reefSigners.forEach((element) {
        print('AVAILABLE Signer=${element.address} bal=${element.balance}');
      });
    });
  }

  ReefSigner toReefSigner(LinkedHashMap<dynamic, dynamic> s) => ReefSigner(s["address"], s["name"], s["balance"]);

  void _initSavedDeviceAccountAddress(
      JsApiService jsApi, StorageService storage) async {
    // TODO check if this address also exists in keystore
    var savedAddress = await storage.getValue(StorageKey.selected_address.name);
    if (kDebugMode) {
      print('SET SAVED ADDRESS=$savedAddress');
    }
    // TODO check if selected is in accounts
    if (savedAddress != null) {
      jsApi.jsCall('appState.setCurrentAddress("$savedAddress")');
    }
  }

  void _initWasm(JsApiService jsApi) async {
    await jsApi.jsPromise('keyring.initWasm()');
  }

  Future<String> generateAccount() async {
    return await jsApi.jsPromise('keyring.generate()');
  }

  Future<String> checkMnemonicValid(String mnemonic) async {
    return await jsApi.jsPromise('keyring.checkMnemonicValid("$mnemonic")');
  }

  Future<String> accountFromMnemonic(String mnemonic) async {
    return await jsApi.jsPromise('keyring.accountFromMnemonic("$mnemonic")');
  }
}
