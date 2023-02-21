import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/model/locale/locale_model.dart';

class LocaleCtrl {
  final StorageService storage;
  LocaleModel localeModel;

  LocaleCtrl(this.storage, this.localeModel) {
    Future<dynamic> storedValueResult = storage.getValue("selectedLanguage");
    storedValueResult.then((storedValue) {
      // if no value in storage - when app is newly installed - set to english
      var setLang = 'hi';
      localeModel.setSelectedLanguage(setLang);
      if(storedValue==null) {
        storage.setValue("selectedLanguage", setLang);
      }
    });
  }

  changeSelectedLanguage(String newLang){
    storage.setValue("selectedLanguage", newLang);
    localeModel.setSelectedLanguage(newLang);
  }
}
