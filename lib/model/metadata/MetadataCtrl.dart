import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reef_mobile_app/model/metadata/ws-conn-state.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

class MetadataCtrl {
  final JsApiService jsApi;
  final StorageService storage;
  final StreamController<dynamic> apolloState = StreamController();


  MetadataCtrl(this.jsApi, this.storage) {
    // need to listen here so other subscriptions immediately receive last value
    getApolloConnLogs().listen((event) {print('GQL CONN=$event');});
    getProviderConnLogs().listen((event) {print('PROV CONN=$event');});
  }

  Future<dynamic> getMetadata() =>
      jsApi.jsPromise('window.metadata.getMetadata();');

  Future<dynamic> getJsVersions() => jsApi.jsCall('window.getReefJsVer();');

  Stream<WsConnState?> getApolloConnLogs()=> jsApi.jsObservable('window.utils.apolloClientWsConnState\$').map((event) => WsConnState.fromJson(event));
  Stream<WsConnState?> getProviderConnLogs()=> jsApi.jsObservable('window.utils.providerConnState\$').map((event) => WsConnState.fromJson(event));
}
