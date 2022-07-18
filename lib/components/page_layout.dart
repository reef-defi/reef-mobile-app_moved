import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reef_mobile_app/components/top_bar.dart';
import 'package:reef_mobile_app/pages/home_page.dart';
import 'package:reef_mobile_app/pages/send_page.dart';
import 'package:reef_mobile_app/pages/swap_page.dart';
import 'package:reef_mobile_app/pages/user_page.dart';
import "package:reef_mobile_app/utils/styles.dart";
import 'package:reef_mobile_app/utils/svg_icon.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const SendPage(),
    const SwapPage(),
    UserPage(),
  ];

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    //
    // Removed navbar since it takes you to a new route
    //
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => _widgetOptions.elementAt(index)),
    // );
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Center(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
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
                      shadowColor: Colors.black26,
                      child: Container(
                          color: Styles.whiteColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: topBar(context)),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 16, vertical: 18),
                    //   child: _widgetOptions.elementAt(_selectedIndex),
                    // )
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                        width: double.infinity,
                        child: _widgetOptions.elementAt(_selectedIndex),
                      ),
                    )
                    // Text(
                    //   'tokens:${reefState.tokenList.tokens.length}',
                    // ),
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
              icon: Icon(CupertinoIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.paperplane),
              label: 'Send',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.arrow_right_arrow_left_square),
              label: 'Swap',
            ),
            BottomNavigationBarItem(
              icon: SvgIcon(
                'assets/images/reef_icon.svg',
                height: 20,
              ),
              label: 'Buy',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
