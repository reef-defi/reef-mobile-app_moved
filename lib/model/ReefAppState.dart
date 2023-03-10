import 'dart:convert';

import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/ViewModel.dart';
import 'package:reef_mobile_app/model/appConfig/AppConfigCtrl.dart';
import 'package:reef_mobile_app/model/locale/LocaleCtrl.dart';
import 'package:reef_mobile_app/model/metadata/MetadataCtrl.dart';
import 'package:reef_mobile_app/model/navigation/NavigationCtrl.dart';
import 'package:reef_mobile_app/model/network/NetworkCtrl.dart';
import 'package:reef_mobile_app/model/signing/SigningCtrl.dart';
import 'package:reef_mobile_app/model/storage/StorageCtrl.dart';
import 'package:reef_mobile_app/model/swap/SwapCtrl.dart';
import 'package:reef_mobile_app/model/tokens/TokensCtrl.dart';
import 'package:reef_mobile_app/model/transfer/TransferCtrl.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

import 'account/AccountCtrl.dart';

class ReefAppState {
  static ReefAppState? _instance;

  final ViewModel model = ViewModel();

  late StorageService _storage;
  late TokenCtrl tokensCtrl;
  late AccountCtrl accountCtrl;
  late SigningCtrl signingCtrl;
  late TransferCtrl transferCtrl;
  late SwapCtrl swapCtrl;
  late MetadataCtrl metadataCtrl;
  late NetworkCtrl networkCtrl;
  late NavigationCtrl navigationCtrl;
  late LocaleCtrl localeCtrl;
  late AppConfigCtrl appConfigCtrl;
  late StorageCtrl storageCtrl;

  ReefAppState._();

  static ReefAppState get instance => _instance ??= ReefAppState._();

  init(JsApiService jsApi, StorageService storage) async {
    _storage = storage;
    await _initReefObservables(jsApi);
    tokensCtrl = TokenCtrl(jsApi, model.tokens);
    accountCtrl = AccountCtrl(jsApi, _storage, model.accounts);
    signingCtrl = SigningCtrl(jsApi, _storage, model.signatureRequests, model.accounts);
    transferCtrl = TransferCtrl(jsApi);
    swapCtrl = SwapCtrl(jsApi);
    metadataCtrl = MetadataCtrl(jsApi, _storage);
    navigationCtrl =
        NavigationCtrl(model.navigationModel, model.homeNavigationModel);
    Network currentNetwork =
        await _storage.getValue(StorageKey.network.name) == Network.testnet.name
            ? Network.testnet
            : Network.mainnet;
    networkCtrl = NetworkCtrl(_storage, jsApi, model.network);
    await _initReefState(jsApi, currentNetwork);
    appConfigCtrl = AppConfigCtrl(_storage, model.appConfig);
    localeCtrl = LocaleCtrl(_storage, model.locale);
    storageCtrl = StorageCtrl(_storage);
  }

  _initReefState(JsApiService jsApiService, Network currentNetwork) async {
    var accounts = await accountCtrl.getStorageAccountsList();
    await jsApiService.jsPromise(
        'window.jsApi.initReefState("${currentNetwork.name}", ${jsonEncode(accounts)})');
  }

  _initReefObservables(JsApiService reefAppJsApiService) async {
    reefAppJsApiService.jsMessageUnknownSubj.listen((JsApiMessage value) {
      print('jsMSG not handled id=${value.streamId}');
    });
  }
}
