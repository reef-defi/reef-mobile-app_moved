import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';

import 'ReefAccount.dart';

part 'account_model.g.dart';

class AccountModel = _AccountModel with _$AccountModel;

abstract class _AccountModel with Store {
  @observable
  String? selectedAddress;

  @observable
  StatusDataObject<List<StatusDataObject<ReefAccount>>> accountsFDM =
      StatusDataObject(
          [], [FeedbackStatus(StatusCode.loading, 'Initializing')]);

  @action
  void setSelectedAddress(String addr) {
    selectedAddress = addr;
  }

  @action
  void setAccountsFDM(
      StatusDataObject<List<StatusDataObject<ReefAccount>>> accounts) {
    accountsFDM = accounts;
  }

  @computed
  List<ReefAccount> get accountsList =>
      accountsFDM.data.map((accFdm) => accFdm.data).toList();
}
