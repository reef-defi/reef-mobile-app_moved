import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/model/tokens/TokenActivity.dart';
import 'package:reef_mobile_app/model/tokens/TokenNFT.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';

part 'token_model.g.dart';

class TokenModel = _TokenModel with _$TokenModel;

abstract class _TokenModel with Store {
  @observable
  StatusDataObject<List<StatusDataObject<TokenWithAmount>>> selectedErc20s =
      StatusDataObject(
          [], [FeedbackStatus(StatusCode.loading, 'Setting up token list.')]);

  @action
  void setSelectedErc20s(
      StatusDataObject<List<StatusDataObject<TokenWithAmount>>> tknsFdm) {
    selectedErc20s = tknsFdm;
  }

  @computed
  List<TokenWithAmount> get selectedErc20List =>
      selectedErc20s.data.map((fdm) => fdm.data).toList();

  @computed
  List<TokenNFT> get selectedNFTList =>
      selectedNFTs.data.map((fdm) => fdm.data).toList();

  @observable
  StatusDataObject<List<StatusDataObject<TokenNFT>>> selectedNFTs =
      StatusDataObject(
          [], [FeedbackStatus(StatusCode.loading, 'Setting up token list.')]);

  @action
  void setSelectedNFTs(
      StatusDataObject<List<StatusDataObject<TokenNFT>>> tknsFdm) {
    selectedNFTs = tknsFdm;
  }

  @observable
  StatusDataObject<List<TokenActivity>> txHistory = StatusDataObject([],
      [FeedbackStatus(StatusCode.loading, 'Setting up transaction history.')]);

  @action
  void setTxHistory(StatusDataObject<List<TokenActivity>> historyFdm) {
    txHistory = historyFdm;
  }

  @observable
  double? reefPrice = 0.0;

  @action
  void setReefPrice(double value) {
    reefPrice = value;
  }

  // @computed
  // TokenWithAmount get reefToken => selectedAccountTokenList.firstWhere((tkn) => tkn.address == Constants.REEF_TOKEN_ADDRESS);
}
