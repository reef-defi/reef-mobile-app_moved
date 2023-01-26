import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/top_bar.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/pages/accounts_page.dart';
import 'package:reef_mobile_app/pages/home_page.dart';
import 'package:reef_mobile_app/pages/send_page.dart';
import 'package:reef_mobile_app/pages/settings_page.dart';
import 'package:reef_mobile_app/pages/swap_page.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/liquid_edge/liquid_carousel.dart';
import "package:reef_mobile_app/utils/styles.dart";

import 'SignatureContentToggle.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final _liquidCarouselKey = GlobalKey<LiquidCarouselState>();
  bool _swiping = false;

  @override
  void initState() {
    ReefAppState.instance.navigationCtrl.carouselKey = _liquidCarouselKey;
    super.initState();
  }

  Widget _getWidget(NavigationPage page) {
    print(ReefAppState.instance.navigationCtrl);
    switch (page) {
      case NavigationPage.home:
        return const HomePage();
      case NavigationPage.send:
        return SendPage(
            ReefAppState.instance.navigationCtrl.navigationModel.data ??
                Constants.REEF_TOKEN_ADDRESS);

      case NavigationPage.accounts:
        return AccountsPage();
      case NavigationPage.settings:
        return const SettingsPage();
      case NavigationPage.swap:
        return const SwapPage();
      default:
        return const HomePage();
    }
  }

  void _onItemTapped(int index) async {
    ReefAppState.instance.navigationCtrl
        .navigate(bottomNavigationBarItems[index].page);
  }

  List<BarItemNavigationPage> bottomNavigationBarItems = const [
    BarItemNavigationPage(
      icon: Icon(Icons.home_outlined),
      page: NavigationPage.home,
      label: 'Home',
    ),
    // BottomNavigationBarItem(
    //   icon: Icon(CupertinoIcons.arrow_right_arrow_left_square),
    //   label: 'Swap',
    // ),
    // BottomNavigationBarItem(
    //   icon: Icon(CupertinoIcons.money_dollar_circle),
    //   label: 'Buy',
    // ),
    BarItemNavigationPage(
      icon: Icon(Icons.account_balance_wallet_outlined),
      page: NavigationPage.accounts,
      //  SvgIcon(
      //   'assets/images/reef_icon.svg',
      //   height: 20,
      // ),
      label: 'Accounts',
    ),
    BarItemNavigationPage(
      icon: Icon(Icons.settings_outlined),
      page: NavigationPage.settings,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Center(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Material(
            color: Colors.white,
            elevation: 0,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: Styles.primaryBackgroundColor,
                ),
                Column(
                  // physics: const NeverScrollableScrollPhysics(),
                  // padding: const EdgeInsets.symmetric(vertical: 0),
                  children: <Widget>[
                    Material(
                      elevation: 3,
                      shadowColor: Colors.black45,
                      child: Container(
                          // color: Styles.whiteColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage("assets/images/reef-header.png"),
                                fit: BoxFit.cover,
                                alignment: Alignment(-0.82, 1.0)),
                          ),
                          child: topBar(context)),
                    ),
                    Expanded(
                        child: LiquidCarousel(
                      key: _liquidCarouselKey,
                      cyclic: true,
                      onSwipe: (int index) {
                        ReefAppState.instance.navigationCtrl.navigationModel
                            .navigate(bottomNavigationBarItems[index].page);
                      },
                      children: [
                        const HomePage(key: PageStorageKey("homepage")),
                        AccountsPage(key: const PageStorageKey("accountPage")),
                        const SettingsPage(key: PageStorageKey("settingsPage")),
                      ],
                    )),
                    // Expanded(
                    //   child: Container(
                    //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    //     width: double.infinity,
                    //     child: Observer(builder: (_) {
                    //       print(
                    //           'DISPLAY PAGE =${ReefAppState.instance.navigation.currentPage}');
                    //       return _getWidget(
                    //           ReefAppState.instance.navigation.currentPage);
                    //     }),
                    //   ),
                    // )
                  ],
                ),
              ],
            ),
          ),
        )),
        bottomNavigationBar: Observer(builder: (_) {
          int currIndex = bottomNavigationBarItems.indexWhere((barItem) =>
              barItem.page ==
              ReefAppState.instance.navigationCtrl.navigationModel.currentPage);
          if (currIndex < 0) {
            currIndex = 0;
          }
          var itemColor = bottomNavigationBarItems.firstWhereOrNull((barItem) =>
                      barItem.page ==
                      ReefAppState.instance.navigationCtrl.navigationModel
                          .currentPage) !=
                  null
              ? Styles.purpleColor
              : Colors.black38;

          return BottomNavigationBar(
            backgroundColor: Styles.whiteColor,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedLabelStyle:
                TextStyle(fontSize: 20, color: Styles.primaryColor),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: itemColor,
            unselectedItemColor: Colors.black38,
            items: bottomNavigationBarItems,
            currentIndex: currIndex,
            onTap: _onItemTapped,
          );
        }),
      ),
    ));
  }
}

class BarItemNavigationPage extends BottomNavigationBarItem {
  final NavigationPage page;

  const BarItemNavigationPage({
    required icon,
    required this.page,
    label,
    Widget? activeIcon,
    backgroundColor,
    tooltip,
  }) : super(
            icon: icon,
            label: label,
            activeIcon: activeIcon,
            backgroundColor: backgroundColor,
            tooltip: tooltip);
}
