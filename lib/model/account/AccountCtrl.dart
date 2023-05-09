import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
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
    _initJsObservables(_jsApi, _storage);
    _initSavedDeviceAccountAddress(_storage);
    _initWasm(_jsApi);
  }

  Future getStorageAccountsList() async {
    var accounts = [];
    (await _storage.getAllAccounts())
        .forEach(((account) => {accounts.add(account.toJsonSkinny())}));
    return accounts;
  }

  Future getStorageAccount(String address) async {
    return await _storage.getAccount(address);
  }

  Future<void> setSelectedAddress(String address) {
    return _jsApi
        .jsCallVoidReturn('window.reefState.setSelectedAddress("$address")');
  }

  Future<String> generateAccount() async {
    return await _jsApi.jsPromise('window.keyring.generate()');
  }

  Future<dynamic> restoreJson(
      Map<String, dynamic> file, String password) async {
    return await _jsApi.jsPromise(
        'window.keyring.restoreJson(${jsonEncode(file)},"$password")');
  }

  Future<dynamic> exportAccountQr(String address, String password) async {
    return await _jsApi
        .jsPromise('window.keyring.exportAccountQr("$address","$password")');
  }

  Future<dynamic> changeAccountPassword(
      String address, String newPass, String oldPass) async {
    return await _jsApi.jsPromise(
        'window.keyring.changeAccountPassword("$address","$newPass","$oldPass")');
  }

  Future<dynamic> accountsCreateSuri(String mnemonic, String password) async {
    return await _jsApi.jsPromise(
        'window.keyring.accountsCreateSuri("$mnemonic","$password")');
  }

  Future<bool> checkMnemonicValid(String mnemonic) async {
    var isValid = await _jsApi
        .jsPromise('window.keyring.checkMnemonicValid("$mnemonic")');
    return isValid == 'true';
  }

  Future<dynamic> resolveEvmAddress(String nativeAddress) async {
    return await _jsApi
        .jsPromise('window.account.resolveEvmAddress("$nativeAddress")');
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
    return await _jsApi
            .jsCall<bool>('window.account.isValidEvmAddress("$address")');
  }

  Future<bool> isValidSubstrateAddress(String address) async {
    return await _jsApi.jsCall<bool>(
            'window.account.isValidSubstrateAddress("$address")');
  }

  Future<String?> resolveToNativeAddress(String evmAddress) async {
    return await _jsApi
        .jsPromise('window.account.resolveFromEvmAddress("$evmAddress")');
  }

  Future<bool> isEvmAddressExist(String address) async {
    var res = await this.resolveToNativeAddress(address);
    return res != null;
  }

  Stream availableSignersStream() {
    return _jsApi.jsObservable('window.reefState.accounts\$');
  }

  void _initJsObservables(JsApiService jsApi, StorageService storage) {
    jsApi
        .jsObservable('window.reefState.selectedAddress\$')
        .listen((address) async {
      if (address == null || address == '') {
        return;
      }
      print('SELECTED addr=${address}');
      await storage.setValue(StorageKey.selected_address.name, address);
      _accountModel.setSelectedAddress(address);
    });

    jsApi
        .jsObservable('window.reefState.accounts_status\$')
        .listen((accs) async {
      ParseListFn<StatusDataObject<ReefAccount>> parsableListFn =
          getParsableListFn(ReefAccount.fromJson);
      var accsListFdm = StatusDataObject.fromJsonList(accs, parsableListFn);

      print(
          'GOT ACCOUNTS ${accsListFdm.hasStatus(StatusCode.completeData)} ${accsListFdm.statusList[0].message} len =${accsListFdm.data.length}');

      _setAccountIconsFromStorage(accsListFdm);

      _accountModel.setAccountsFDM(accsListFdm);
    });
  }

  void _initSavedDeviceAccountAddress(StorageService storage) async {
    var savedAddress = await storage.getValue(StorageKey.selected_address.name);

    if (savedAddress != null) {
      // check if the saved address exists in the allAccounts list
      var allAccounts = await storage.getAllAccounts();
      for (var account in allAccounts) {
        if (account.address == savedAddress) {
          await setSelectedAddress(account.address);
          return; //return from here after saving the selected address
        }
      }

      //if the saved address is not found then set first address as saved
      if (allAccounts.length > 0) {
        await setSelectedAddress(allAccounts[0].address);
      }
    }
  }

  void _initWasm(JsApiService _jsApi) async {
    await _jsApi.jsPromise('window.keyring.initWasm()');
  }

  toReefEVMAddressWithNotificationString(String evmAddress) async {
    return await _jsApi.jsCall(
        'window.account.toReefEVMAddressWithNotification("$evmAddress")');
  }

  toReefEVMAddressNoNotificationString(String evmAddress) async {
    return await _jsApi
        .jsCall('window.account.toReefEVMAddressNoNotification("$evmAddress")');
  }

  void _setAccountIconsFromStorage(
      StatusDataObject<List<StatusDataObject<ReefAccount>>> accsListFdm) async {
    var accIcons = [];

    (await _storage.getAllAccounts()).forEach(((account) {
      accIcons.add({"address": account.address, "svg": account.svg});
    }));

    accsListFdm.data.forEach((accFdm) {
      var accIcon = accIcons.firstWhere(
          (accIcon) => accIcon['address'] == accFdm.data.address,
          orElse: () => null);
      accFdm.data.iconSVG = accIcon?['svg'];
    });
  }
}
