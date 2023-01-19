import 'package:mobx/mobx.dart';

part 'app_config_model.g.dart';

class AppConfigModel = _AppConfigModel with _$AppConfigModel;

abstract class _AppConfigModel with Store {

  @observable
  bool displayBalance = true;

  @action
  void setDisplayBalance(bool val) {
    displayBalance=val;
  }

}