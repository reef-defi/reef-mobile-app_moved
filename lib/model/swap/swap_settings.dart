import 'package:mobx/mobx.dart';

part 'swap_settings.g.dart';

class SwapSettings = _SwapSettings with _$SwapSettings;

abstract class _SwapSettings with Store {
  _SwapSettings(this.deadline, this.slippageTolerance);

  @observable
  int deadline = 1;

  @observable
  double slippageTolerance = 0.8;

   Map toJson() => {
    'deadline': deadline,
    'slippageTolerance': slippageTolerance,
  };
}
