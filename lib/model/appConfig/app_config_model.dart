import 'package:mobx/mobx.dart';

part 'app_config_model.g.dart';

class AppConfigModel = _AppConfigModel with _$AppConfigModel;

abstract class _AppConfigModel with Store {

  @observable 
  bool displayBalance = false;

  @observable
  bool navigateOnAccountSwitch = true;
  
  @observable
  bool isBiometricAuthEnabled = false;

  @action
  void setDisplayBalance(bool val) {
    displayBalance = val;
  }

  @action
  void setNavigateOnAccountSwitch(bool val) {
    navigateOnAccountSwitch = val;
  }

  @action
  void setBiometricAuthentication(bool val) {
    isBiometricAuthEnabled = val;
  }

}
