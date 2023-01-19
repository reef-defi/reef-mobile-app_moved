import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/model/appConfig/app_config_model.dart';

class AppConfigCtrl {
  final StorageService storage;
  AppConfigModel appConfigModel;

  AppConfigCtrl(this.storage, this.appConfigModel) {
    var storedValue = storage.getValue("displayBalance");
    storage.setValue("displayBalance", storedValue);
  }

  toggleDisplayBalance() {
    var newValue = !appConfigModel.displayBalance;
    storage.setValue("displayBalance", newValue);
    appConfigModel.setDisplayBalance(newValue);
  }
}
