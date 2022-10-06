import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/SignatureContentToggle.dart';
import 'package:reef_mobile_app/components/home/NFT_view.dart';
import 'package:reef_mobile_app/components/home/activity_view.dart';
import 'package:reef_mobile_app/components/home/staking_view.dart';
import 'package:reef_mobile_app/components/home/token_view.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/size_config.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import 'DAppPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateTestDApp(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DAppPage(ReefAppState.instance, url)),
    );
  }

  List _viewsMap = [
    {"key": 0, "name": "Token", "active": true, "component": const TokenView()},
    {
      "key": 1,
      "name": "Stakings",
      "active": false,
      "component": const StakingView()
    },
    {"key": 2, "name": "NFTs", "active": false, "component": const NFTView()},
    {
      "key": 3,
      "name": "Activity",
      "active": false,
      "component": const ActivityView()
    }
  ];

  Widget balanceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Balance",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Styles.textColor)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Observer(builder: (_) {
                  return GradientText(
                    "\$${sumTokenBalances(ReefAppState.instance.model.tokens.selectedSignerTokens.toList()).toStringAsFixed(0)}",
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 54, fontWeight: FontWeight.w700),
                    gradient: textGradient(),
                  );
                }),
              ),
            ),
          ]),
    );
  }

  Widget rowMember(Map member) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        List temp = _viewsMap;
        for (var element in temp) {
          element["active"] = (element["name"] == member["name"]);
        }
        setState(() {
          _viewsMap = temp;
        });
      },
      child: (AnimatedContainer(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: member["active"] ? Styles.whiteColor : Styles.navColor,
            boxShadow: member["active"]
                ? [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 2),
                    )
                  ]
                : [],
          ),
          duration: const Duration(milliseconds: 150),
          child: Opacity(
            opacity: member["active"] ? 1 : 0.5,
            child: Text(
              member["name"],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Styles.textColor,
              ),
            ),
          ))),
    );
  }

  Widget navSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Styles.navColor,
        border: Border.all(
          color: const Color(0x88dcd7ea),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _viewsMap.map<Widget>((e) => rowMember(e)).toList()),
      ),
    );
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0) {
      return;
    } // user have just tapped on screen (no dragging)

    if (details.primaryVelocity?.compareTo(0) == -1) {
      // dragged towards left
      List temp = _viewsMap;
      int currentIndex =
          temp.where((element) => element["active"] == true).toList()[0]["key"];
      if (currentIndex < _viewsMap.length - 1) {
        for (var element in temp) {
          element["active"] = (element["key"] == currentIndex + 1);
        }
        setState(() {
          _viewsMap = temp;
        });
      }
    } else {
      List temp = _viewsMap;
      int currentIndex =
          temp.where((element) => element["active"] == true).toList()[0]["key"];
      if (currentIndex > 0) {
        for (var element in temp) {
          element["active"] = (element["key"] == currentIndex - 1);
        }
        setState(() {
          _viewsMap = temp;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return SignatureContentToggle(AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Column(
        children: [
          Row(children: [
            ElevatedButton(
              child: const Text('test dApp 1'),
              onPressed: () =>
                  _navigateTestDApp("https://mobile-dapp-test.web.app/testnet"),
              // https://min-dapp.web.app
              // https://app.reef.io
            ),
            ElevatedButton(
              child: const Text('test dApp 2'),
              onPressed: () => _navigateTestDApp(
                  "https://console.reefscan.com/#/settings/metadata"),
            ),
          ]),
          balanceSection(),
          navSection(),
          Expanded(
            // height: ((size.height + 64) / 2),
            // width: double.infinity,
            child: GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) =>
                    _onHorizontalDrag(details),
                child: _viewsMap.where((option) => option["active"]).toList()[0]
                    ["component"]),
          ),
          // TODO: ADD ALERT SYSTEM FOR ERRORS HERE
          // test()
        ],
      ),
    ));
  }

  double sumTokenBalances(List<TokenWithAmount> list) {
    var sum = 0.0;
    list.forEach((token) {
      double balValue =
          getBalanceValue(decimalsToDouble(token.balance), token.price);
      if (balValue > 0) {
        sum = sum + balValue;
      }
    });
    return sum;
  }
}
