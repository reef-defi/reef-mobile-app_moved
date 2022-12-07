import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/model/feedback-data-model/FeedbackDataModel.dart';
import 'package:reef_mobile_app/model/tokens/Token.dart';
import 'package:reef_mobile_app/model/tokens/TokenActivity.dart';
import 'package:reef_mobile_app/model/tokens/TokenNFT.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';


part 'token_model.g.dart';

class TokenModel = _TokenModel with _$TokenModel;

abstract class _TokenModel with Store {
  @observable
  FeedbackDataModel<List<FeedbackDataModel<TokenWithAmount>>> selectedErc20s = FeedbackDataModel([], [FeedbackStatus(StatusCode.loading, 'Setting up token list.')]);

  @action
  void setSelectedErc20s(FeedbackDataModel<List<FeedbackDataModel<TokenWithAmount>>> tknsFdm) {
    selectedErc20s = tknsFdm;
  }

  @computed
  List<TokenWithAmount> get selectedErc20List => selectedErc20s.data.map((fdm) => fdm.data).toList();

  @computed
  List<TokenNFT> get selectedNFTList => selectedNFTs.data.map((fdm) => fdm.data).toList();

  @observable
  FeedbackDataModel<List<FeedbackDataModel<TokenNFT>>> selectedNFTs = FeedbackDataModel([], [FeedbackStatus(StatusCode.loading, 'Setting up token list.')]);

  @action
  void setSelectedNFTs(FeedbackDataModel<List<FeedbackDataModel<TokenNFT>>> tknsFdm) {
    selectedNFTs = tknsFdm;
  }

  @observable
  FeedbackDataModel<List<TokenActivity>> txHistory = FeedbackDataModel([], [FeedbackStatus(StatusCode.loading, 'Setting up transaction history.')]);

  @action
  void setTxHistory(FeedbackDataModel<List<TokenActivity>> historyFdm) {
    txHistory = historyFdm;
  }

  @observable
  double? reefPrice=0.0;

  @action
  void setReefPrice(double value) {
    reefPrice = value;
  }

  // @computed
  // TokenWithAmount get reefToken => selectedAccountTokenList.firstWhere((tkn) => tkn.address == Constants.REEF_TOKEN_ADDRESS);
  }
