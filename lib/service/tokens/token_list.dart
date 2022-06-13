import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/service/tokens/token.dart';

part 'token_list.g.dart';

class TokenList = _TokenList with _$TokenList;

abstract class _TokenList with Store {
  @observable
  ObservableList<Token> tokens = ObservableList<Token>();

  @action
  void setTokens(List<Token> tkns) {
    this.tokens.clear();
    this.tokens.addAll(tkns);
  }
}
