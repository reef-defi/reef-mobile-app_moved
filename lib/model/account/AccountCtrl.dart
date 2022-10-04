import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

import 'account_model.dart';

class AccountCtrl {
  final AccountModel _accountModel;

  final JsApiService _jsApi;
  final StorageService _storage;

  AccountCtrl(this._jsApi, this._storage, this._accountModel) {
    _initSavedDeviceAccountAddress(_storage);
    _initJsObservables(_jsApi, _storage);
    _initWasm(_jsApi);
  }

  Future getAccountsList() async {
    var accounts = [];
    (await _storage.getAllAccounts())
        .forEach(((account) => {accounts.add(account.toJsonSkinny())}));
    return accounts;
  }

  void setSelectedAddress(String address) {
    // TODO check if in signers
    _jsApi.jsCall('appState.setCurrentAddress("$address")');
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

  Future saveAccount(StoredAccount account) async {
    await _storage.saveAccount(account);
    await updateAccounts();
    setSelectedAddress(account.address);
  }

  void deleteAccount(String address) async {
    var account = await _storage.getAccount(address);
    if (account != null) {
      await account.delete();
    }
    //TODO if selected select index 0
    await updateAccounts();
  }

  Future<void> updateAccounts() async {
    var accounts = [];
    (await _storage.getAllAccounts())
        .forEach(((account) => {accounts.add(account.toJsonSkinny())}));
    return _jsApi.jsPromise('account.updateAccounts(${jsonEncode(accounts)})');
  }

  Future<bool> isValidEvmAddress(String address) async {
    var res = await _jsApi.jsCall('utils.isValidEvmAddress("$address")');
    return res == 'true';
  }

  Stream availableSignersStream() {
    return _jsApi.jsObservable('account.availableSigners\$');
  }

  void _initJsObservables(JsApiService _jsApi, StorageService storage) {
    _jsApi.jsObservable('appState.currentAddress\$').listen((address) async {
      if (address == null || address == '') {
        return;
      }
      print('SELECTED addr=${address}');
      await storage.setValue(StorageKey.selected_address.name, address);
      _accountModel.setSelectedAddress(address);
    });

    _accountModel.setLoadingSigners(true);
    _jsApi.jsObservable('account.availableSigners\$').listen((signers) async {
      _accountModel.setLoadingSigners(false);

      var accounts = [];

      (await _storage.getAllAccounts()).forEach(((account) => {
            accounts.add({"address": account.address, "svg": account.svg})
          }));

      var reefSigners = List<ReefSigner>.from(signers.map((s) {
        s["iconSVG"] = accounts
            .where((item) => item["address"] == s["address"])
            .toList()[0]["svg"];
        return ReefSigner.fromJson(s);
      }));

      _accountModel.setSigners(reefSigners);
      print('AVAILABLE Signers ${signers.length}');
      reefSigners.forEach((signer) {
        print('  ${signer.name} - ${signer.address}');
      });
    });
  }

  void _initSavedDeviceAccountAddress(StorageService storage) async {
    // TODO check if this address also exists in keystore
    var savedAddress = await storage.getValue(StorageKey.selected_address.name);
    if (kDebugMode) {
      print('SET SAVED ADDRESS=$savedAddress');
    }
    // TODO check if selected is in accounts
    if (savedAddress != null) {
      setSelectedAddress(savedAddress);
    }
  }

  void _initWasm(JsApiService _jsApi) async {
    await _jsApi.jsPromise('keyring.initWasm()');
  }

  void createTestAccount() {
    final account = StoredAccount()
      ..mnemonic =
          "control employ home citizen film salmon divorce cousin illegal episode certain olympic"
      ..address = "5EnY9eFwEDcEJ62dJWrTXhTucJ4pzGym4WZ2xcDKiT3eJecP"
      ..svg = "<svg></svg>"
      ..name = "Test account";
    print('create test account ${account.address}');
    saveAccount(account);
  }
}
