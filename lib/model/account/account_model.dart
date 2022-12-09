import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/model/feedback-data-model/FeedbackDataModel.dart';

import '../StorageKey.dart';
import 'ReefAccount.dart';

part 'account_model.g.dart';

class AccountModel = _AccountModel with _$AccountModel;

abstract class _AccountModel with Store {

  @observable
  String? selectedAddress;

  @observable
  FeedbackDataModel<List<FeedbackDataModel<ReefAccount>>> accountsFDM=FeedbackDataModel([], [FeedbackStatus(StatusCode.loading,'Initializing')]);

  @action
  void setSelectedAddress(String addr) {
    selectedAddress = addr;
  }

  @action
  void setAccountsFDM(FeedbackDataModel<List<FeedbackDataModel<ReefAccount>>> accounts) {
    accountsFDM = accounts;
  }

  @computed
  List<ReefAccount> get accountsList => accountsFDM.data.map((accFdm) => accFdm.data).toList();

}
