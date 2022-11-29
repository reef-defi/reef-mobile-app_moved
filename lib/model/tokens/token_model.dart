import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/model/feedback-data-model/FeedbackDataModel.dart';
import 'package:reef_mobile_app/model/tokens/Token.dart';
import 'package:reef_mobile_app/model/tokens/TokenActivity.dart';
import 'package:reef_mobile_app/model/tokens/TokenNFT.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';

import '../../utils/constants.dart';

part 'token_model.g.dart';

class TokenModel = _TokenModel with _$TokenModel;

abstract class _TokenModel with Store {
  @observable
  FeedbackDataModel<List<FeedbackDataModel<TokenWithAmount>>> selectedAccountTokens = FeedbackDataModel([], [FeedbackStatus(StatusCode.loading, 'Setting up token list.')]);

  @action
  void setSelectedAccountTokens(FeedbackDataModel<List<FeedbackDataModel<TokenWithAmount>>> tknsFdm) {
    selectedAccountTokens = tknsFdm;
  }
...TODO replace selectedSignerTokens
  @observable
  ObservableList<TokenWithAmount> selectedSignerTokens =
      ObservableList<TokenWithAmount>();

  @action
  void setSelectedSignerTokens(List<TokenWithAmount> tkns) {
    this.selectedSignerTokens.clear();
    this.selectedSignerTokens.addAll(tkns);
  }

  /*@observable
  ObservableList<TokenWithAmount> tokenList = ObservableList<TokenWithAmount>();

  @action
  void setTokenList(List<TokenWithAmount> tkns) {
    this.tokenList.clear();
    this.tokenList.addAll(tkns);
  }*/

  @observable
  ObservableList<TokenNFT> selectedSignerNFTs = ObservableList<TokenNFT>();

  @action
  void setSelectedSignerNFTs(List<TokenNFT> tkns) {
    this.selectedSignerNFTs.clear();
    this.selectedSignerNFTs.addAll(tkns);
  }

  @observable
  ObservableList<TokenActivity> activity = ObservableList<TokenActivity>();

  @action
  void setTokenActivity(List<TokenActivity> items) {
    this.activity.clear();
    this.activity.addAll(items);
  }

  @observable
  double? reefPrice=0;

  @action
  void setReefPrice(double value) {
    reefPrice = value;
  }

  @computed
  FeedbackDataModel<TokenWithAmount> get reefToken => selectedAccountTokens.data.firstWhere((tkn) => tkn.data.address == Constants.REEF_TOKEN_ADDRESS);
}
