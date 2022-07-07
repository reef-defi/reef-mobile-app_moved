import 'package:mobx/mobx.dart';

import '../StorageKey.dart';
import 'ReefSigner.dart';

part 'account.g.dart';

class Account = _Account with _$Account;

abstract class _Account with Store {

  @observable
  ReefSigner? selectedSigner;

  @action
  void setSelectedSigner(ReefSigner signer) {
    // TODO get and attach keystore values
    this.selectedSigner=signer;
  }

}
