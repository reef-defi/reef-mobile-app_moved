import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reef_mobile_app/components/top_bar.dart';
import 'package:reef_mobile_app/pages/home_page.dart';
import 'package:reef_mobile_app/pages/settings_page.dart';
import 'package:reef_mobile_app/pages/user_page.dart';
import "package:reef_mobile_app/utils/styles.dart";

import 'SignatureContentToggle.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    // const SendPage(Constants.REEF_TOKEN_ADDRESS),
    // const SwapPage(),
    // const BuyPage(),
    UserPage(),
    const SettingsPage()
  ];

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

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
                          decoration: BoxDecoration(
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
                        child: _widgetOptions.elementAt(_selectedIndex),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Styles.whiteColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedLabelStyle:
              TextStyle(fontSize: 20, color: Styles.primaryColor),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Styles.purpleColor,
          unselectedItemColor: Colors.black38,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(CupertinoIcons.paperplane),
            //   label: 'Send',
            // ),
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
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    ));
  }
}
