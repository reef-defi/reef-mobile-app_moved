import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/model/appConfig/app_config_model.dart';

class AppConfigCtrl {
  final StorageService storage;
  AppConfigModel _appConfigModel;

  AppConfigCtrl(this.storage, this._appConfigModel) {
    Future<dynamic> storedValueResult = storage.getValue("displayBalance");
    storedValueResult.then((storedValue) {
      // if no value in storage - when app is newly installed - set to true
      var setVal = storedValue??true;
      _appConfigModel.setDisplayBalance(setVal);
      if(storedValue==null) {
        storage.setValue("displayBalance", setVal);
      }
    });

    Future<dynamic> storedBiometricAuth = storage.getValue("biometricAuth");
    storedBiometricAuth.then((storedValue) {
      var setVal = storedValue??false;
      _appConfigModel.setBiometricAuthentication(setVal);
      if(storedValue==null) {
        storage.setValue("biometricAuth", setVal);
      }
    });

    Future<dynamic> storedNavigateValueResult = storage.getValue("navigateOnAccountSwitch");
    storedNavigateValueResult.then((storedValue) {
      // if no value in storage - when app is newly installed - set to true
      var setVal = storedValue??true;
      _appConfigModel.setNavigateOnAccountSwitch(setVal);
      if(storedValue==null) {
        storage.setValue("navigateOnAccountSwitch", setVal);
      }
    });
  }

  toggleDisplayBalance() {
    var newValue = !_appConfigModel.displayBalance;
    storage.setValue("displayBalance", newValue);
    _appConfigModel.setDisplayBalance(newValue);
  }

  setNavigateOnAccountSwitch(bool value) {
    storage.setValue("navigateOnAccountSwitch", value);
    _appConfigModel.setNavigateOnAccountSwitch(value);
  }

  setBiometricAuth(bool value) {
    storage.setValue("biometricAuth", value);
    _appConfigModel.setBiometricAuthentication(value);
  }
}
