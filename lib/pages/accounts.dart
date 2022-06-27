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
            TextButton(onPressed: sign, child: const Text('Sign')),
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
                onPressed: _callSaveAccount, child: const Text('Save Account')),
            TextButton(
                onPressed: _callGetAccount, child: const Text('Get Account')),
            TextButton(
                onPressed: getAllAccounts,
                child: const Text('Get All Accounts')),
            TextButton(
                onPressed: _callDeleteAccount,
                child: const Text('Delete Account')),
          ],
        ),
      ),
    );
  }

  void sign() async {
    const mnemonic =
        'control employ home citizen film salmon divorce cousin illegal episode certain olympic';
    const address = "0x7Ca7886e0b851e6458770BC1d85Feb6A5307b9a2";
    
    var response = await widget.jsApiService.jsPromise(
        'accountManager.Signer.signAndSend("${mnemonic}", {method: "signExtrinsic", params: ["${address}", { method: "balances.transferKeepAlive(dest, value)", module: "balances", call: "transferKeepAlive", params: ["5FX42URyoa9mfFTwoLiWrprxvgCsaA81AssRLw2dDj4HizST", "1000000000000000000"], tip: "0x00000000000000000000000000000000"}]})');
    print("response: ${response}");

    // var response = await widget.jsApiService.jsPromise(
    //     'accountManager.Signer.sign("${mnemonic}", {method: "signExtrinsic", params: ["${address}", { method: "evm.call(target, input, value, gasLimit, storageLimit)", module: "evm", call: "call", params: ["0xd3202ee6077c7cc25eaea3ae11bec2cd731d19fc", "0x3d53e5f4000000000000000000000000000000000000000000000000000000000000003c00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000de0b6b3a7640000", "0", "3,335,299", "2,000"], tip: "0x00000000000000000000000000000000"}]})');
    // print("response: ${response}");
  }

  void getNetwork() async {
    var response = await widget.jsApiService
        .jsCall('accountManager.Network.currentNetwork');
    print("response: ${response}");
  }

  void selectNetwork() async {
    var response = await widget.jsApiService
        .jsCall('accountManager.Network.selectNetwork("testnet")');
    print("response: ${response}");
  }

  void _callAccountFromMnemonic() async {
    const mnemonic =
        'debris pink stairs furnace rescue toddler face finger vast trash repair bone';
    accountFromMnemonic(mnemonic);
  }

  void generateAccount() async {
    var response = await widget.jsApiService
        .jsPromise('accountManager.Keyring.generate()');
    print("response: ${response}");

    var account = StoredAccount.fromString(response);
    print("account generated: ${account.address}");
  }

  void generateAndSaveAccount() async {
    var response = (await widget.jsApiService
        .jsPromise('accountManager.Keyring.generate()'));
    print("account created: ${response}");

    var account = StoredAccount.fromString(response);
    saveAccount(account);
  }

  void checkMnemonicValid(String mnemonic) async {
    var valid = await widget.jsApiService.jsPromise(
        'accountManager.Keyring.checkMnemonicValid("${mnemonic}")');
    print("is valid: ${valid}");
  }

  /// Returns the address of the account with the given mnemonic
  void accountFromMnemonic(String mnemonic) async {
    var response = await widget.jsApiService.jsPromise(
        'accountManager.Keyring.accountFromMnemonic("${mnemonic}")');

    var account = StoredAccount.fromString(response);
    print("account from mnemonic: ${account.address}");
  }

  void _callSaveAccount() {
    final account = StoredAccount()
      ..mnemonic =
          "debris pink stairs furnace rescue toddler face finger vast trash repair bone"
      ..address = "5HgkDz5N1L1PvwSZVDkdZ2fgBAWu6kAHYruH1QvCL3DvwRQj"
      ..svg = "<svg></svg>";

    saveAccount(account);
  }

  void _callGetAccount() {
    const address = "5HgkDz5N1L1PvwSZVDkdZ2fgBAWu6kAHYruH1QvCL3DvwRQj";
    getAccount(address);
  }

  void _callDeleteAccount() {
    const address = "5HgkDz5N1L1PvwSZVDkdZ2fgBAWu6kAHYruH1QvCL3DvwRQj";
    deleteAccount(address);
  }

  /// Save account to storage
  Future saveAccount(StoredAccount account) async {
    await widget.storageService.saveAccount(account);
    print("Saved account ${account.address}.");
  }

  /// Get all accounts from storage
  Future<List<StoredAccount>?> getAllAccounts() async {
    var accounts = await widget.storageService.getAllAccounts();
    if (accounts.isEmpty) {
      print("No accounts found.");
      return null;
    }
    print("Found ${accounts.length} accounts:");
    accounts.forEach((account) {
      print("  ${account.address}");
    });
    return accounts;
  }

  /// Get account from storage
  Future<StoredAccount?> getAccount(String address) async {
    var account = await widget.storageService.getAccount(address);
    if (account == null) {
      print("Account not found.");
      return null;
    }
    print("Fetched account ${account.address}.");
    return account;
  }

  /// Delete account from storage
  void deleteAccount(String address) async {
    var account = await getAccount(address);
    if (account != null) {
      account.delete();
      print("Deleted accont ${account.address}.");
    }
  }
}
