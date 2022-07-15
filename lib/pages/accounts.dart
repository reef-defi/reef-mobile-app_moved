import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

import '../model/ReefState.dart';

class AccountPage extends StatefulWidget {
  const AccountPage(this.reefState, this.storageService);
  final ReefAppState reefState;
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
                onPressed: _callSaveAccount, child: const Text('Save Account')),
            TextButton(
                onPressed: _callGetAccount, child: const Text('Get Account')),
            TextButton(
                onPressed: getAllAccounts,
                child: const Text('Get All Accounts')),
            TextButton(
                onPressed: _callDeleteAccount,
                child: const Text('Delete Account')),
            TextButton(
                onPressed: deleteAllAccounts,
                child: const Text('Delete All Accounts')),
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
    var response = await widget.reefState.accountCtrl.generateAccount();
    print("response: $response");

    var account = StoredAccount.fromString(response);
    print("account generated: ${account.address}");
  }

  void generateAndSaveAccount() async {
    var response = (await widget.reefState.accountCtrl.generateAccount());
    print("account created: $response");

    var account = StoredAccount.fromString(response);
    account.name = "Generated Account";
    saveAccount(account);
  }

  void checkMnemonicValid(String mnemonic) async {
    var valid = await widget.reefState.accountCtrl.checkMnemonicValid(mnemonic);
    print("is valid: $valid");
  }

  /// Returns the address of the account with the given mnemonic
  void accountFromMnemonic(String mnemonic) async {
    var response = await widget.reefState.accountCtrl.accountFromMnemonic(mnemonic);

    var account = StoredAccount.fromString(response);
    print("account from mnemonic: ${account.address}");
  }

  void _callSaveAccount() {
    final account = StoredAccount()
      ..mnemonic =
          "control employ home citizen film salmon divorce cousin illegal episode certain olympic"
      ..address = "5EnY9eFwEDcEJ62dJWrTXhTucJ4pzGym4WZ2xcDKiT3eJecP"
      ..svg = "<svg></svg>"
      ..name = "Test account";

    saveAccount(account);
  }

  void _callGetAccount() {
    const address = "5EnY9eFwEDcEJ62dJWrTXhTucJ4pzGym4WZ2xcDKiT3eJecP";
    getAccount(address);
  }

  void _callDeleteAccount() {
    const address = "5EnY9eFwEDcEJ62dJWrTXhTucJ4pzGym4WZ2xcDKiT3eJecP";
    deleteAccount(address);
  }

  /// Save account to storage
  Future saveAccount(StoredAccount account) async {
    await widget.storageService.saveAccount(account);
    print("Saved account ${account.address}");
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
    print("Fetched account ${account.address}");
    return account;
  }

  /// Delete account from storage
  void deleteAccount(String address) async {
    var account = await getAccount(address);
    if (account != null) {
      account.delete();
      print("Deleted accont ${account.address}");
    }
  }

  /// Delete all accounts from storage
  void deleteAllAccounts() async {
    getAllAccounts().then((accounts) {
      if (accounts != null) {
        accounts.forEach((account) {
          account.delete();
        });
      }
    });
  }
}
