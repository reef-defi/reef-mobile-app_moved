import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';

part 'token_model.g.dart';

class TokenModel = _TokenModel with _$TokenModel;

abstract class _TokenModel with Store {
  @observable
  ObservableList<TokenWithAmount> selectedSignerTokens = ObservableList<TokenWithAmount>();

  @action
  void setSelectedSignerTokens(List<TokenWithAmount> tkns) {
    this.selectedSignerTokens.clear();
    this.selectedSignerTokens.addAll(tkns);
  }
}
