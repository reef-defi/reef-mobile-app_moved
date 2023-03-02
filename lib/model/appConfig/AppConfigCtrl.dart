import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/model/appConfig/app_config_model.dart';

class AppConfigCtrl {
  final StorageService storage;
  AppConfigModel appConfigModel;

  AppConfigCtrl(this.storage, this.appConfigModel) {
    Future<dynamic> storedValueResult = storage.getValue("displayBalance");
    storedValueResult.then((storedValue) {
      // if no value in storage - when app is newly installed - set to true
      var setVal = storedValue??true;
      appConfigModel.setDisplayBalance(setVal);
      if(storedValue==null) {
        storage.setValue("displayBalance", setVal);
      }
    });
  }

  toggleDisplayBalance() {
    var newValue = !appConfigModel.displayBalance;
    storage.setValue("displayBalance", newValue);
    appConfigModel.setDisplayBalance(newValue);
  }
}
