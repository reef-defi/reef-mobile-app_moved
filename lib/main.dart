import 'package:flutter/material.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/components/page_layout.dart';
import './model/display_balance/display_balance.dart';


void main() async {
  runApp(
    SplashApp(
      key: UniqueKey(),
      displayOnInit: () {
        return const BottomNav();
      },
    ),
  );
}
