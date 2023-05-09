import 'dart:convert';

import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class PasswordManager {
  static Future<bool> checkIfPassword() async {
    try {
      final password = await ReefAppState.instance.storageCtrl
          .getValue(StorageKey.password.name);
      if (password == null) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  static String getOldPass(StoredAccount account){
    // to only split from the first occurence considering that password might contain '+' in it    
    int delimiterIdx = account.mnemonic.indexOf("+");
    List<String> accountElems = [
      account.mnemonic.substring(0, delimiterIdx),
      account.mnemonic.substring(delimiterIdx + 1),
    ];
    return accountElems[1];
  }

  // updates password for json imported account
  static void updateAccountPassword(
      StoredAccount account, String newPass) async {
    final oldPass =getOldPass(account);
    Map<String, dynamic> updatedAccountObj = {
      'name': account.name,
      'svg': account.svg,
      'address': account.address,
      'mnemonic': "${account.address}+$newPass"
    };
    final updatedAccount =
        StoredAccount.fromString(jsonEncode(updatedAccountObj).toString());
    ReefAppState.instance.accountCtrl.deleteAccount(account.address);
    ReefAppState.instance.accountCtrl.saveAccount(updatedAccount);
    final accountPassChanged = await ReefAppState.instance.accountCtrl
        .changeAccountPassword(account.address, newPass, oldPass);
    print(
        "CHANGING ACCOUNT PASSWORD FOR ${account.address} - CHANGED PASSWORD :  $accountPassChanged");
  }

  // changes password for all json imported accounts
  static void changePasswordForAll(String newPass) async {
    final allAccounts = await ReefAppState.instance.storage.getAllAccounts();
    for (StoredAccount account in allAccounts) {
      if (isJsonImportedAccount(account.mnemonic)) {
        updateAccountPassword(account, newPass);
      }
    }
  }

  // checks if account is generated from mnemonic or json
  static bool isJsonImportedAccount(String accountMnemonic){
    if(accountMnemonic.contains("+"))return true;
    return false;
  }
}
