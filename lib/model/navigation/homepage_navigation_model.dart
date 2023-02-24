import 'package:mobx/mobx.dart';

part 'homepage_navigation_model.g.dart';

// Bottom navigation bar items should be placed in the same order as they appear

class HomePageNavigationModel = _HomePageNavigationModel
    with _$HomePageNavigationModel;

abstract class _HomePageNavigationModel with Store {
  @observable
  int currentIndex = 0;

  dynamic data;

  @action
  void navigate(int index, {dynamic data}) {
    currentIndex = index;
    this.data = data;
  }
}
