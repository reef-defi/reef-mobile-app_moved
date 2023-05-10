import 'dart:convert';

import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/network/network_model.dart';
import 'package:reef_mobile_app/model/network/ws-conn-state.dart';
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

    // need to listen here so other subscriptions immediately receive last value
    getGqlConnLogs().listen((event) {print('GQL CONN=$event');});
    getProviderConnLogs().listen((event) {print('PROV CONN=$event');});
  }

  Future<void> setNetwork(Network network) async {
    networkModel.setSelectedNetworkSwitching(true);
    jsApi.jsCallVoidReturn('window.utils.setSelectedNetwork(`${network.name}`)');
  }

  Stream<WsConnState?> getGqlConnLogs()=> jsApi.jsObservable('window.utils.apolloClientWsConnState\$').map((event) => WsConnState.fromJson(event));
  Stream<WsConnState?> getProviderConnLogs()=> jsApi.jsObservable('window.utils.providerConnState\$').map((event) => WsConnState.fromJson(event));

}
