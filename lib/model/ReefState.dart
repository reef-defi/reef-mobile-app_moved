import 'dart:convert';

import 'package:reef_mobile_app/model/signing/SigningCtrl.dart';
import 'package:reef_mobile_app/model/tokens/TokensCtrl.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

import 'account/AccountCtrl.dart';

class ReefAppState {
  static ReefAppState? _instance;

  late StorageService storage;
  late TokenCtrl tokensCtrl;
  late AccountCtrl accountCtrl;
  late SigningCtrl signingCtrl;

  ReefAppState._();

  static ReefAppState get instance => _instance ??= ReefAppState._();

  init(JsApiService jsApi, StorageService storage) async {
    this.storage = storage;
    await _initReefState(jsApi);
    await _initReefObservables(jsApi);
    await _initKeyring(jsApi);
    tokensCtrl = TokenCtrl(jsApi);
    accountCtrl = AccountCtrl(jsApi, storage);
    signingCtrl = SigningCtrl(jsApi, storage);
  }

  _initReefState(JsApiService jsApiService) async {
    var accounts = [];
    (await storage.getAllAccounts())
        .forEach(((account) => {accounts.add(account.toJsonSkinny())}));

    await jsApiService
        .jsCall('jsApi.initReefState("testnet", ${jsonEncode(accounts)})');
  }

  _initReefObservables(JsApiService jsApiService) async {
    jsApiService.jsMessageUnknownSubj.listen((JsApiMessage value) {
      print('jsMSG not handled id=${value.id}');
    });
  }

  _initKeyring(JsApiService jsApiService) async {
     await jsApiService.jsCall('keyring.initWasm()');
  }
}
