import 'package:reef_mobile_app/model/navigation/navigation_model.dart';

mixin NavSwipeCompute {
  int computeSwipeAnimation(
      {required NavigationPage currentPage, required NavigationPage page}) {
    if (currentPage == NavigationPage.home && page == NavigationPage.settings) {
      return 2;
    } else if ((currentPage == NavigationPage.accounts &&
            page == NavigationPage.home) ||
        (currentPage == NavigationPage.settings &&
            page == NavigationPage.accounts)) {
      return -1;
    } else if (currentPage == NavigationPage.settings &&
        page == NavigationPage.home) {
      return -2;
    } else if ((currentPage == NavigationPage.home &&
            page == NavigationPage.accounts) ||
        (currentPage == NavigationPage.accounts &&
            page == NavigationPage.settings)) {
      return 1;
    }
    return 0;
  }
}
