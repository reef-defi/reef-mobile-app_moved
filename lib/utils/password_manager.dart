import 'dart:convert';

import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class PasswordManager{
  static Future<bool> checkIfPassword()async{
    try {
    final password = await ReefAppState.instance.storageCtrl.getValue(StorageKey.password.name);
    if(password==null)return false;
    return true;
    } catch (e) {
    return false;
    }
  }

  static void updateAccountPassword(StoredAccount account,String newPass)async{
    final accountElems = account.mnemonic.split("+");
    String oldPass = accountElems[1];
    Map<String,dynamic> updatedAccountObj = {
        'name':account.name,
        'svg':account.svg,
        'address':account.address,
        'mnemonic':"${account.address}+$newPass"
       };
       final updatedAccount = StoredAccount.fromString(jsonEncode(updatedAccountObj).toString());
         ReefAppState.instance.storage.deleteAccount(account.address);
       ReefAppState.instance.accountCtrl.saveAccount(updatedAccount);
       final accountPassChanged =await ReefAppState.instance.accountCtrl.changeAccountPassword(account.address, newPass, oldPass);
       print("CHANGING ACCOUNT PASSWORD FOR ${account.address} - CHANGED PASSWORD :  $accountPassChanged");
  }

  static void changePasswordForAll(String newPass)async{
    final allAccounts = await ReefAppState.instance.storage.getAllAccounts();
    for(StoredAccount account in allAccounts){
      if(account.mnemonic.contains("+")){ 
       updateAccountPassword(account, newPass);
      }
    }
  }
}