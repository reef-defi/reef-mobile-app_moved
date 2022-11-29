import 'dart:convert';

import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/network/network_model.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

enum Network { mainnet, testnet }

class NetworkCtrl {
  final StorageService storage;
  final JsApiService jsApi;
  NetworkModel networkModel;

  NetworkCtrl(this.storage, this.jsApi, this.networkModel) {
    jsApi
        .jsObservable('window.reefState.selectedNetwork\$')
        .listen((network) async {
      networkModel.setSelectedNetworkSwitching(false);
      if (network != null && network['name'] != null) {
        var nName = network['name'];
        await storage.setValue(StorageKey.network.name, nName);
        networkModel.setSelectedNetworkName(nName);
      }
    });
  }

  Future<void> setNetwork(Network network) async {
    networkModel.setSelectedNetworkSwitching(true);
    jsApi.jsCall('window.utils.setSelectedNetwork(`${network.name}`)');
  }
}
