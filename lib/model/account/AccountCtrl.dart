import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

import 'account.dart';

class AccountCtrl {
  final AccountsModel accountsModel = AccountsModel();
  final JsApiService _jsApi;
  final StorageService _storage;

  AccountCtrl(this._jsApi, this._storage) {
    _initSavedDeviceAccountAddress(_jsApi, _storage);
    _initJsObservables(_jsApi, _storage);
    _initWasm(_jsApi);
  }

  void _initJsObservables(JsApiService jsApi, StorageService storage) {
    jsApi.jsObservable('account.selectedSigner\$').listen((signer) async {
      if(signer==null){
        return;
      }
      LinkedHashMap s = signer;
      await storage.setValue(StorageKey.selected_address.name, s['address']);
      accountsModel.setSelectedSigner(toReefSigner(s));
    });

    accountsModel.setLoadingSigners(true);
    jsApi.jsObservable('account.availableSigners\$').listen((signers) async {
      accountsModel.setLoadingSigners(false);
      var reefSigners =
          List<ReefSigner>.from(signers.map((s) => toReefSigner(s)));
      accountsModel.setSigners(reefSigners);
      print('AVAILABLE Signers ${signers.length}');
      reefSigners.forEach((signer) {
        print('  ${signer.name} - ${signer.address}');
      });
    });
  }

  ReefSigner toReefSigner(LinkedHashMap<dynamic, dynamic> s) =>
      ReefSigner(s["address"], s["name"], s["balance"]);

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
    return await _jsApi.jsPromise('keyring.generate()');
  }

  Future<String> checkMnemonicValid(String mnemonic) async {
    return await _jsApi.jsPromise('keyring.checkMnemonicValid("$mnemonic")');
  }

  Future<String> accountFromMnemonic(String mnemonic) async {
    return await _jsApi.jsPromise('keyring.accountFromMnemonic("$mnemonic")');
  }

  Future<void> updateAccounts() async {
    var accounts = [];
    (await _storage.getAllAccounts())
        .forEach(((account) => {accounts.add(account.toJsonSkinny())}));
    _jsApi.jsPromise('account.updateAccounts(${jsonEncode(accounts)})');
  }

  getAllAccounts() {

  }
}
