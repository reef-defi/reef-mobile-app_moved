import 'package:mobx/mobx.dart';

part 'reef_app_state.g.dart';

class ReefAppState = _ReefAppState with _$ReefAppState;

abstract class _ReefAppState with Store {
  _ReefAppState();

  @observable
  String symbol = '';

}
