import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/model/appConfig/app_config_model.dart';

class AppConfigCtrl {
  final StorageService storage;
  AppConfigModel appConfigModel;

  AppConfigCtrl(this.storage, this.appConfigModel) {
    Future<dynamic> storedValueResult = storage.getValue("displayBalance");
    bool storedValue = false;
    storedValueResult.then((result) {
      storedValue = result ? true : false;
    });
    appConfigModel.setDisplayBalance(storedValue);
  }

  toggleDisplayBalance() {
    var newValue = !appConfigModel.displayBalance;
    storage.setValue("displayBalance", newValue);
    appConfigModel.setDisplayBalance(newValue);
  }
}
