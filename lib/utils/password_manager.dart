import 'dart:convert';

import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';

class PasswordManager{

  static void updateAccountPassword(StoredAccount account,String password){
    Map<String,dynamic> updatedAccountObj = {
        'name':account.name,
        'svg':account.svg,
        'address':account.address,
        'mnemonic':"${account.address}+$password"
       };
       final updatedAccount = StoredAccount.fromString(jsonEncode(updatedAccountObj).toString());
       ReefAppState.instance.storage.deleteAccount(account.address);
       ReefAppState.instance.accountCtrl.saveAccount(updatedAccount);
  }

  static void changePasswordForAll(String password)async{
    final allAccounts = await ReefAppState.instance.storage.getAllAccounts();
    for(StoredAccount account in allAccounts){
      if(account.mnemonic.contains("+")){ 
       updateAccountPassword(account, password);
      }
    }
  }
}