import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

class MetadataCtrl {
  final JsApiService jsApi;
  final StorageService storage;
  final StreamController<dynamic> apolloState = StreamController.broadcast();

  MetadataCtrl(this.jsApi, this.storage) {
    var aState = jsApi.jsObservable('window.utils.apolloClientWsState\$');

    aState.listen((event) {
      if (kDebugMode) {
        print('GOT GQL WS STATE $event');
      }
      apolloState.sink.add(event);
    });
  }

  Future<dynamic> getMetadata() =>
      jsApi.jsPromise('window.metadata.getMetadata();');

  Future<dynamic> getJsVersions() => jsApi.jsCall('window.getReefJsVer();');
}
