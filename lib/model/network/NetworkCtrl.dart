import 'dart:convert';

import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

enum Network { mainnet, testnet }

class NetworkCtrl {
  final StorageService storage;
  final JsApiService jsApi;
  Network currentNetwork;

  NetworkCtrl(this.storage, this.jsApi, this.currentNetwork);

  Future<void> setNetwork(Network network) async {
    currentNetwork = network;
    await storage.setValue(StorageKey.network.name, network.name);
    jsApi.jsPromise('utils.setCurrentNetwork(`${network.name}`)');
  }
}
