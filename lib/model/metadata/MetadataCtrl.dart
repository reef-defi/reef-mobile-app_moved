import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

class MetadataCtrl {
  final JsApiService jsApi;
  final StorageService storage;
  final StreamController<dynamic> apolloState = StreamController();


  MetadataCtrl(this.jsApi, this.storage) {
    // need to listen here so other subscriptions immediately receive last value
    getApolloConnLogs().listen((event) {print('GQL CONN=$event');});
  }

  Future<dynamic> getMetadata() =>
      jsApi.jsPromise('window.metadata.getMetadata();');

  Future<dynamic> getJsVersions() => jsApi.jsCall('window.getReefJsVer();');

  Stream<dynamic> getApolloConnLogs()=> jsApi.jsObservable('window.utils.apolloClientWsState\$');
}
