import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

class MetadataCtrl {
  final JsApiService jsApi;
  final StorageService storage;

  MetadataCtrl(this.jsApi, this.storage);

  Future<dynamic> getMetadata() => jsApi.jsPromise('window.metadata.getMetadata();');
}
