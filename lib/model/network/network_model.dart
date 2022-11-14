import 'package:mobx/mobx.dart';

part 'network_model.g.dart';

class NetworkModel = _NetworkModel with _$NetworkModel;

abstract class _NetworkModel with Store {
  @observable
  bool selectedNetworkSwitching = true;

  @observable
  String? selectedNetworkName;

  @action
  void setSelectedNetworkSwitching(bool val) {
    selectedNetworkSwitching = val;
  }
  @action
  void setSelectedNetworkName(String network) {
    selectedNetworkName = network;
  }
}
