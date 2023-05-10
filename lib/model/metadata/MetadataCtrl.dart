import 'dart:async';

import 'package:reef_mobile_app/service/JsApiService.dart';

class MetadataCtrl {
  final JsApiService jsApi;

  MetadataCtrl(this.jsApi) {
  }

  Future<dynamic> getMetadata() =>
      jsApi.jsPromise('window.metadata.getMetadata();');

  Future<dynamic> getJsVersions() => jsApi.jsCall('window.getReefJsVer();');

 }
