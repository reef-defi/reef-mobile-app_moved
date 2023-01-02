import 'package:mobx/mobx.dart';

part 'display_balance.g.dart';

class BalanceModel = _BalanceModel with _$BalanceModel;

abstract class _BalanceModel with Store {

  @observable
  bool displayBalance = true;

  @action
  void toggle() {
    displayBalance=!displayBalance;
  }

}
