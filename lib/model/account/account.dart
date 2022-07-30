import 'package:mobx/mobx.dart';

import '../StorageKey.dart';
import 'ReefSigner.dart';

part 'account.g.dart';

class AccountsModel = _Account with _$Account;

abstract class _Account with Store {

  @observable
  ReefSigner? selectedSigner;

  @observable
  ObservableList<ReefSigner> signers = ObservableList<ReefSigner>();

  @observable
  bool loadingSigners = true;

  @action
  void setLoadingSigners(bool val) {
    loadingSigners = val;
  }

  @action
  void setSelectedSigner(ReefSigner signer) {
    // TODO get and attach keystore values
    // TODO set address not whole object
    this.selectedSigner = signer;
  }

  @action
  void setSigners(List<ReefSigner> signers) {
    this.signers.clear();
    this.signers.addAll(signers);
  }

}
