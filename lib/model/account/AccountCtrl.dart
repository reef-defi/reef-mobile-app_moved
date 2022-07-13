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
    initSavedDeviceAccountAddress(jsApi, storage);
    initJsObservables(jsApi, storage);
    initWasm(jsApi);
  }

  void initJsObservables(JsApiService jsApi, StorageService storage) {
    jsApi.jsObservable('account.selectedSigner\$').listen((signer) async {
      LinkedHashMap s = signer;
      await storage.setValue(StorageKey.selected_address.name, s['address']);
      account.setSelectedSigner(ReefSigner(s["address"], s["name"]));
    });
  }

  void initSavedDeviceAccountAddress(
      JsApiService jsApi, StorageService storage) async {
    // TODO check if this address also exists in keystore
    var savedAddress = await storage.getValue(StorageKey.selected_address.name);
    if (kDebugMode) {
      print('SET SAVED ADDRESS=$savedAddress');
    }
    if (savedAddress != null) {
      jsApi.jsCall('appState.setCurrentAddress("$savedAddress")');
    }
  }

  void initWasm(JsApiService jsApi) async {
    await jsApi.jsPromise('accountManager.Keyring.initWasm()');
  }

  Future<String> generateAccount() async {
    return await jsApi.jsPromise('accountManager.Keyring.generate()');
  }

  Future<String> checkMnemonicValid(String mnemonic) async {
    return await jsApi.jsPromise('accountManager.Keyring.checkMnemonicValid("$mnemonic")');
  }

  Future<String> accountFromMnemonic(String mnemonic) async {
    return await jsApi.jsPromise('accountManager.Keyring.accountFromMnemonic("$mnemonic")');
  }

  signTest(String address, String mnemonic) async {
    return await jsApi.jsPromise(
        'accountManager.Signer.sign("$mnemonic", {'
            'address: "$address", '
            'blockHash: "0xe1b1dda72998846487e4d858909d4f9a6bbd6e338e4588e5d809de16b1317b80", '
            'blockNumber: "0x00000393", '
            'era: "0x3601", '
            'genesisHash: "0x242a54b35e1aad38f37b884eddeb71f6f9931b02fac27bf52dfb62ef754e5e62", '
            'method: "0x040105fa8eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a4882380100", '
            'nonce: "0x0000000000000000" , '
            'signedExtensions: ["CheckSpecVersion", "CheckTxVersion", "CheckGenesis", "CheckMortality", "CheckNonce", "CheckWeight", "ChargeTransactionPayment"], '
            'specVersion: "0x00000026", '
            'tip: null, '
            'transactionVersion: "0x00000005", '
            'version: 4, '
            '})');
  }
}
