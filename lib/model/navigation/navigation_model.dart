import 'package:mobx/mobx.dart';

part 'navigation_model.g.dart';

// Bottom navigation bar items should be placed in the same order as they appear
enum NavigationPage { home, send, accounts, settings, swap }

class NavigationModel = _NavigationModel with _$NavigationModel;

abstract class _NavigationModel with Store {
  @observable
  NavigationPage currentPage = NavigationPage.home;

  dynamic data;

  @action
  void navigate(NavigationPage page, {dynamic data}) {
    currentPage = page;
    this.data = data;
  }
}
