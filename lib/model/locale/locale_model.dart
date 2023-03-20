import 'package:mobx/mobx.dart';

part 'locale_model.g.dart';

class LocaleModel = _LocaleModel with _$LocaleModel;

abstract class _LocaleModel with Store {

  @observable
  String selectedLanguage = 'en';

  @action
  void setSelectedLanguage(String lang) {
    selectedLanguage=lang;
  }

}