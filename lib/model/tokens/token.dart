import 'package:mobx/mobx.dart';

part 'token.g.dart';

class Token = _Token with _$Token;

abstract class _Token with Store {
  _Token(this.symbol);

  @observable
  String symbol = '';

}
