import 'dart:convert';

import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class PasswordManager{

  static void updateAccountPassword(StoredAccount account,String newPass)async{
    print("anuna ${account.mnemonic}");
    final _accountElems = account.mnemonic.split("+");
    String oldPass = _accountElems[1];
    Map<String,dynamic> updatedAccountObj = {
        'name':account.name,
        'svg':account.svg,
        'address':account.address,
        'mnemonic':"${account.address}+$newPass"
       };
       final updatedAccount = StoredAccount.fromString(jsonEncode(updatedAccountObj).toString());
         ReefAppState.instance.storage.deleteAccount(account.address);
       ReefAppState.instance.accountCtrl.saveAccount(updatedAccount);
       StoredAccount _temp = await ReefAppState.instance.accountCtrl.getStorageAccount(account.address);
       final accountPassChanged =await ReefAppState.instance.accountCtrl.changeAccountPassword(account.address, newPass, oldPass);
       print("anuna $accountPassChanged");
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