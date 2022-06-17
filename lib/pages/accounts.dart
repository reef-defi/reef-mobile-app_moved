import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/ReefState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final storage = StorageService();
  final jsApiService = JsApiService();
  late ReefState reefState;

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
            TextButton(onPressed: initWasm, child: const Text('Init WASM')),
            TextButton(onPressed: test, child: const Text('Test')),
            TextButton(
                onPressed: generateAccount,
                child: const Text('Generate Account')),
            TextButton(
                onPressed: _getAccounts, child: const Text('Get Accounts')),
            TextButton(
                onPressed: _addAccount, child: const Text('Add Account')),
            TextButton(
                onPressed: _deleteAccount, child: const Text('Delete Account')),
          ],
        ),
      ),
    );
  }

  void initWasm() async {
    var res = await jsApiService.jsPromise('keyring.callCryptoWaitReady()');
    print("res: ${res}");
  }

  void test() async {
    const mnemonic =
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
    checkMnemonicValid(mnemonic);
    addressFromMnemonic(mnemonic);
  }

  void generateAccount() async {
    var res = await jsApiService.jsPromise('keyring.gen()');
    print("res: ${res}");
  }

  void checkMnemonicValid(String mnemonic) async {
    var res =
        await jsApiService.jsCall('keyring.checkMnemonicValid(${mnemonic})');
    print("res: ${res}");
  }

  void addressFromMnemonic(String mnemonic) async {
    var res =
        await jsApiService.jsCall('keyring.addressFromMnemonic(${mnemonic})');
    print("res: ${res}");
  }

  void _getAccounts() async {
    final accounts = await getAccounts();
    print("accounts number: ${accounts.length}");
    if (accounts.isNotEmpty) {
      print("account 1: ${accounts[0].address}");
    }
  }

  void _addAccount() {
    addAccount(
        "debris pink stairs furnace rescue toddler face finger vast trash repair bone",
        "5HgkDz5N1L1PvwSZVDkdZ2fgBAWu6kAHYruH1QvCL3DvwRQj",
        "<svg></svg>");
  }

  void _deleteAccount() async {
    final accounts = await getAccounts();
    deleteAccount(accounts[0]);
  }

  Future addAccount(String mnemonic, String address, String svg) async {
    final account = StoredAccount()
      ..mnemonic = mnemonic
      ..address = address
      ..svg = svg;

    print(account);
    var res = await storage.setValue(StorageKey.stored_accounts.name, account);
    print("res: ${res}");
  }

  void deleteAccount(StoredAccount account) {
    account.delete();
  }

  Future<List<StoredAccount>> getAccounts() async {
    // final box = Hive.box<StoredAccount>('accounts');
    // return box.values.toList().cast<StoredAccount>();
    print("getAccounts");
    var accounts = await storage.getValue(StorageKey.stored_accounts.name);
    print(accounts);
    var acc = accounts.toList().cast<StoredAccount>();
    print(acc);
    return acc;
  }
}
