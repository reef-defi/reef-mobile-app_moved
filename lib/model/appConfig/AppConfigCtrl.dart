import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/model/appConfig/app_config_model.dart';

class AppConfigCtrl {
    final StorageService storage;
    AppConfigModel appConfigModel;

    AppConfigCtrl(this.storage, this.appConfigModel){
      storage.setValue("displayBalance", appConfigModel.displayBalance);
    }

    toggle(){
        storage.setValue("displayBalance", !appConfigModel.displayBalance);
        appConfigModel.toggle();
    }
}