import 'package:mobx/mobx.dart';

part 'tokenlist.g.dart';

class Token = TokenBase with _$Token;

abstract class TokenBase with Store {
  TokenBase(this.symbol);

  @observable
  String symbol = '';

}
