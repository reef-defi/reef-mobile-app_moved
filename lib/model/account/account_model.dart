import 'package:mobx/mobx.dart';

import '../StorageKey.dart';
import 'ReefSigner.dart';

part 'account_model.g.dart';

class AccountModel = _AccountModel with _$AccountModel;

abstract class _AccountModel with Store {

  @observable
  String? selectedAddress;

  @observable
  ObservableList<ReefSigner> signers = ObservableList<ReefSigner>();

  @observable
  bool loadingSigners = true;

  @action
  void setLoadingSigners(bool val) {
    loadingSigners = val;
  }

  @action
  void setSelectedAddress(String addr) {
    selectedAddress = addr;
  }

  @action
  void setSigners(List<ReefSigner> signers) {
    this.signers.clear();
    this.signers.addAll(signers);
  }

}
