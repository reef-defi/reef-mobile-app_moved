import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/account.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

class AccountPage extends StatefulWidget {
  AccountPage(this.jsApiService, this.storageService);
  final JsApiService jsApiService;
  final StorageService storageService;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accounts'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
                onPressed: _callAccountFromMnemonic,
                child: const Text('Account from mnemonic')),
            TextButton(
                onPressed: generateAccount,
                child: const Text('Generate Account')),
            TextButton(
                onPressed: generateAndSaveAccount,
                child: const Text('Generate and Save Account')),
            TextButton(
                onPressed: _callSaveAccount, child: const Text('Add Account')),
            TextButton(onPressed: getAccount, child: const Text('Get Account')),
            TextButton(
                onPressed: deleteAccount, child: const Text('Delete Account')),
          ],
        ),
      ),
    );
  }

  void _callAccountFromMnemonic() async {
    const mnemonic =
        'debris pink stairs furnace rescue toddler face finger vast trash repair bone';
    accountFromMnemonic(mnemonic);
  }

  void generateAccount() async {
    var account = await widget.jsApiService.jsPromise('keyring.gen()');
    print("account created: ${account}");
  }

  void generateAndSaveAccount() async {
    var account = await widget.jsApiService.jsPromise('keyring.gen()');
    print("account created: ${account}");

    // TODO
  }

  void checkMnemonicValid(String mnemonic) async {
    var valid = await widget.jsApiService
        .jsPromise('keyring.checkMnemonicValid("${mnemonic}")');
    print("is valid: ${valid}");
  }

  /// Returns the address of the account with the given mnemonic
  void accountFromMnemonic(String mnemonic) async {
    var address = await widget.jsApiService
        .jsPromise('keyring.addressFromMnemonic("${mnemonic}")');
    print("account from mnemonic: ${address}");
  }

  void _callSaveAccount() {
    saveAccount(
        "debris pink stairs furnace rescue toddler face finger vast trash repair bone",
        "5HgkDz5N1L1PvwSZVDkdZ2fgBAWu6kAHYruH1QvCL3DvwRQj",
        "<svg></svg>");
  }

  /// Save account to storage
  Future saveAccount(String mnemonic, String address, String svg) async {
    final account = StoredAccount()
      ..mnemonic = mnemonic
      ..address = address
      ..svg = svg;

    await widget.storageService.setValue(StorageKey.account.name, account);
    print("Saved account ${account.address}.");
  }

  /// Get all account from storage
  Future<StoredAccount?> getAccount() async {
    var account = await widget.storageService.getValue(StorageKey.account.name);
    if (account == null) {
      print("No account found.");
      return null;
    }
    print("Fetched account ${account.address}.");
    return account;
  }

  /// Delete account from storage
  void deleteAccount() async {
    var account = await getAccount();
    if (account != null) {
      account.delete();
      print("Deleted accont ${account.address}.");
    }
  }
}
