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
import "package:reef_mobile_app/utils/styles.dart";

import 'SignatureContentToggle.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  Widget _getWidget(NavigationPage page) {
    print(ReefAppState.instance.navigation);
    switch (page) {
      case NavigationPage.home:
        return const HomePage();
      case NavigationPage.send:
        return SendPage(ReefAppState.instance.navigation.data ??
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

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    ReefAppState.instance.navigation.navigate(NavigationPage.values[index]);
  }

  List<BottomNavigationBarItem> bottomNavigationBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
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
    BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet_outlined),
      //  SvgIcon(
      //   'assets/images/reef_icon.svg',
      //   height: 20,
      // ),
      label: 'Accounts',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
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
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                        width: double.infinity,
                        child: Observer(builder: (_) {
                          print(
                              'DISPLAY PAGE =${ReefAppState.instance.navigation.currentPage}');
                          return _getWidget(
                              ReefAppState.instance.navigation.currentPage);
                        }),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )),
        bottomNavigationBar: Observer(
            builder: (_) => BottomNavigationBar(
                  backgroundColor: Styles.whiteColor,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  selectedLabelStyle:
                      TextStyle(fontSize: 20, color: Styles.primaryColor),
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor:
                      ReefAppState.instance.navigation.currentPage.index <
                              bottomNavigationBarItems.length
                          ? Styles.purpleColor
                          : Colors.black38,
                  unselectedItemColor: Colors.black38,
                  items: bottomNavigationBarItems,
                  currentIndex:
                      ReefAppState.instance.navigation.currentPage.index <
                              bottomNavigationBarItems.length
                          ? ReefAppState.instance.navigation.currentPage.index
                          : 0,
                  onTap: _onItemTapped,
                )),
      ),
    ));
  }
}
