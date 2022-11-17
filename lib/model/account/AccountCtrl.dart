import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/utils/constants.dart';

import 'account_model.dart';

class AccountCtrl {
  final AccountModel _accountModel;

  // TODO check/make these props are private in other Ctrl classes
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

  Future getAccount(String address) async {
    return await _storage.getAccount(address);
  }

  void setSelectedAddress(String address) {
    // TODO check if in signers
    _jsApi.jsCall('window.appState.setCurrentAddress("$address")');
  }

  Future<String> generateAccount() async {
    return await _jsApi.jsPromise('window.keyring.generate()');
  }

  Future<bool> checkMnemonicValid(String mnemonic) async {
    var isValid = await _jsApi
        .jsPromise('window.keyring.checkMnemonicValid("$mnemonic")');
    return isValid == 'true';
  }

  Future<String> accountFromMnemonic(String mnemonic) async {
    return await _jsApi
        .jsPromise('window.keyring.accountFromMnemonic("$mnemonic")');
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
    if (address == _accountModel.selectedAddress) {
      await _storage.getAllAccounts().then((accounts) {
        if (accounts.isNotEmpty) {
          setSelectedAddress(accounts[0].address);
        } else {
          setSelectedAddress(Constants.ZERO_ADDRESS);
        }
      });
      _accountModel.selectedAddress = null;
    }
    await updateAccounts();
  }

  Future<void> updateAccounts() async {
    var accounts = [];
    (await _storage.getAllAccounts())
        .forEach(((account) => {accounts.add(account.toJsonSkinny())}));
    return _jsApi
        .jsPromise('window.account.updateAccounts(${jsonEncode(accounts)})');
  }

  Future<dynamic> bindEvmAccount(String address) async {
    return _jsApi.jsPromise('window.account.claimEvmAccount("$address")');
  }

  Future<bool> isValidEvmAddress(String address) async {
    var res = await _jsApi.jsCall('window.utils.isValidEvmAddress("$address")');
    return res == 'true';
  }

  Stream availableSignersStream() {
    return _jsApi.jsObservable('window.account.availableSigners\$');
  }

  void _initJsObservables(JsApiService jsApi, StorageService storage) {
    jsApi
        .jsObservable('window.appState.currentAddress\$')
        .listen((address) async {
      if (address == null || address == '') {
        return;
      }
      print('SELECTED addr=${address}');
      await storage.setValue(StorageKey.selected_address.name, address);
      _accountModel.setSelectedAddress(address);
    });

    _accountModel.setLoadingSigners(true);
    jsApi
        .jsObservable('window.account.availableSigners\$')
        .listen((signers) async {
      _accountModel.setLoadingSigners(false);

      var accounts = [];

      (await _storage.getAllAccounts()).forEach(((account) => {
            accounts.add({"address": account.address, "svg": account.svg})
          }));

      var reefSigners = List<ReefSigner>.from(signers.map((s) {
        dynamic list =
            accounts.where((item) => item["address"] == s["address"]).toList();
        if (list.length > 0) s["iconSVG"] = list[0]["svg"];
        return ReefSigner.fromJson(s);
      }));

      _accountModel.setSigners(reefSigners);
      print('AVAILABLE Signers ${signers.length}');
      reefSigners.forEach((signer) {
        print('  ${signer.name} - ${signer.address} - ${signer.isEvmClaimed}');
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
    await _jsApi.jsPromise('window.keyring.initWasm()');
  }

  toReefEVMAddressWithNotificationString(String evmAddress) async {
    return await _jsApi.jsCall('window.account.toReefEVMAddressWithNotification("$evmAddress")');
  }
}
