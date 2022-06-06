import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/service/tokens/Token.dart';

part 'tokenlist.g.dart';

class TokenList = TokenListBase with _$TokenList;

abstract class TokenListBase with Store {
  @observable
  ObservableList<Token> tokens = ObservableList<Token>();

  @action
  void setTokens(List<Token> tkns) {
    this.tokens.clear();
    this.tokens.setAll(0, tkns);
  }
}
