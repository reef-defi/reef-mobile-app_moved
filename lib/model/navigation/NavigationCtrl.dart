import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/pages/send_page.dart';
import 'package:reef_mobile_app/pages/swap_page.dart';
import 'package:reef_mobile_app/utils/liquid_edge/liquid_carousel.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class NavigationCtrl {
  final NavigationModel _navigationModel;
  GlobalKey<LiquidCarouselState>? carouselKey;
  bool _swiping = false;

  NavigationCtrl(this._navigationModel);

  void navigate(NavigationPage navigationPage) async {
    if (_swiping) return;
    _swiping = true;
    if (_navigationModel.currentPage == navigationPage) {
      _swiping = false;
      return;
    }
    final swiped = await _computeSwipeAnimation(
        currentPage: _navigationModel.currentPage, page: navigationPage);
    if (swiped) {
      HapticFeedback.selectionClick();
      _navigationModel.navigate(navigationPage);
    }
    _swiping = false;
  }

  void navigateToSendPage(
      {required BuildContext context, required String preselected}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
            appBar: AppBar(
              title:  Text("Send Tokens",
                  style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w500,
                          fontSize: 24,)
                          ),
              backgroundColor: Colors.deepPurple.shade700,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: SendPage(preselected),
            ),
          backgroundColor: Styles.greyColor,
        )));
  }

  void navigateToSwapPage({required BuildContext context}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text("Swap Tokens"),
              backgroundColor: Colors.deepPurple.shade700,
            ),
            body: const Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: SwapPage(),
            ))));
  }

  void navigateToPage({required BuildContext context, required Widget child}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => child));
  }

  Future<bool> _computeSwipeAnimation(
      {required NavigationPage currentPage,
      required NavigationPage page}) async {
    if ((currentPage == NavigationPage.home &&
            page == NavigationPage.settings) ||
        (currentPage == NavigationPage.accounts &&
            page == NavigationPage.home) ||
        (currentPage == NavigationPage.settings &&
            page == NavigationPage.accounts)) {
      return await carouselKey!.currentState!.swipeToPrevious();
    } else if ((currentPage == NavigationPage.home &&
            page == NavigationPage.accounts) ||
        (currentPage == NavigationPage.accounts &&
            page == NavigationPage.settings) ||
        (currentPage == NavigationPage.settings &&
            page == NavigationPage.home)) {
      return await carouselKey!.currentState!.swipeToNext();
    }
    return false;
  }
}
