import 'package:flutter/src/widgets/framework.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/model/locale/locale_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCtrl {
  final StorageService storage;
  LocaleModel localeModel;

  LocaleCtrl(this.storage, this.localeModel) {
    Future<dynamic> storedValueResult = storage.getValue("selectedLanguage");
    storedValueResult.then((storedValue) {
      if (storedValue != 'en') {
        localeModel.setSelectedLanguage(storedValue ?? 'en');
      }
    });
  }

  changeSelectedLanguage(String newLang) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('languageCode', newLang);
    localeModel.setSelectedLanguage(newLang);
  }
}
