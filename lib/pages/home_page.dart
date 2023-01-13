import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/SignatureContentToggle.dart';
import 'package:reef_mobile_app/components/home/NFT_view.dart';
import 'package:reef_mobile_app/components/home/activity_view.dart';
import 'package:reef_mobile_app/components/home/hero_video.dart';
import 'package:reef_mobile_app/components/home/token_view.dart';
import 'package:reef_mobile_app/components/modals/account_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/pages/test_page.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/size_config.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../components/modals/add_account_modal.dart';
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

  void _navigateTestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TestPage()),
    );
  }

  double _textSize = 120.0;
  bool _isScrolling = false;

  List _viewsMap = [
    {
      "key": 0,
      "name": "Tokens",
      "active": true,
      "component": const TokenView()
    },
    /*{
      "key": 1,
      "name": "Stakings",
      "active": false,
      "component": const StakingView()
    },*/
    {"key": 1, "name": "NFTs", "active": false, "component": const NFTView()},
    {
      "key": 2,
      "name": "Activity",
      "active": false,
      "component": const ActivityView()
    }
  ];

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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: member["active"]
                ? Styles.whiteColor
                : Styles.primaryBackgroundColor,
            boxShadow: member["active"]
                ? [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2.5),
                    )
                  ]
                : [],
          ),
          duration: const Duration(milliseconds: 200),
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
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Styles.primaryBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: const HSLColor.fromAHSL(
                      1, 256.3636363636, 0.379310344828, 0.843137254902)
                  .toColor(),
              offset: const Offset(10, 10),
              blurRadius: 20,
              spreadRadius: -5,
            ),
            BoxShadow(
              color:
                  const HSLColor.fromAHSL(1, 256.3636363636, 0.379310344828, 1)
                      .toColor(),
              offset: const Offset(-10, -10),
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ]),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _viewsMap.map<Widget>((e) => rowMember(e)).toList()),
      ),
    );
  }

  // todo: remove useless method
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

    void openModal(String modalName) {
      switch (modalName) {
        case 'addAccount':
          showCreateAccountModal(context);
          break;
        case 'importAccount':
          showCreateAccountModal(context, fromMnemonic: true);
          break;
        default:
          break;
      }
    }

    final bool isAccountsEmpty =
        ReefAppState.instance.model.accounts.accountsFDM.data.isEmpty;
    // final bool isAccountsEmpty = true;

    debugPrint(
        "Home Page account length: ${ReefAppState.instance.model.accounts.accountsFDM.data.length.toString()}");

    return SignatureContentToggle(AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: (!isAccountsEmpty)
            ? CustomScrollView(
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                slivers: [
                  /*Row(children: [
                ElevatedButton(
                  child: const Text('test dApp 1'),
                  onPressed: () => _navigateTestDApp(
                      "https://mobile-dapp-test.web.app/testnet"),
                  // https://min-dapp.web.app
                  // https://app.reef.io
                ),
                ElevatedButton(
                  child: const Text('test dApp 2'),
                  onPressed: () => _navigateTestDApp(
                      "https://console.reefscan.com/#/settings/metadata"),
                ),
                ElevatedButton(
                    child: const Text('test'), onPressed: _navigateTestPage),
              ]),*/
                  SliverPersistentHeader(delegate: _BalanceHeaderDelegate()),
                  SliverPinnedHeader(
                    child: navSection(),
                  ),
                  // SliverToBoxAdapter(
                  //   child: AnimatedContainer(
                  //       duration: const Duration(milliseconds: 200),
                  //       height: _isScrolling ? 16 : 0),
                  // ),
                  SliverClip(
                    child: _viewsMap
                        .where((option) => option["active"])
                        .toList()[0]["component"],
                  )

                  // height: ((size.height + 64) / 2),
                  // width: double.infinity,

                  // TODO: ADD ALERT SYSTEM FOR ERRORS HERE
                  // test()
                ],
              )
            : Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Center(child: VideoPlayerScreen()),
                          Column(
                            children: [
                              SvgPicture.asset(
                                'assets/images/reef-logo-light.svg',
                                semanticsLabel: "Reef Logo",
                                height: 64,
                              ),
                              Text(
                                "Mobile App",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 36),
                      Center(
                          child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        runSpacing: 16,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                                color: Colors.black87,
                                gradient: textGradient(),
                                borderRadius: BorderRadius.circular(48)),
                            child: TextButton.icon(
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  showAddAccountModal(
                                      'Add account menu', openModal,
                                      context: context);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black12,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(48)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  minimumSize: const Size(82, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: Icon(Icons.person_add_rounded,
                                    color: Styles.primaryBackgroundColor,
                                    size: 16),
                                label: Text(
                                  "Add an account",
                                  style: TextStyle(
                                      color: Styles.whiteColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "Looks like no accounts are added yet. Click on the button above to add an account!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Styles.textLightColor, fontSize: 12),
                            ),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
              )));
  }
}

class _BalanceHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Opacity(
      opacity: _calculateOpacity(shrinkOffset),
      child: balanceSection(30),
    );
  }

  @override
  double get maxExtent => 200;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  Widget balanceSection(double size) {
    //bool _isBigText = size > 42;
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCirc,
        width: size,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Balance",
                      style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: Styles.textColor)),
                  Center(
                    child: Observer(builder: (_) {
                      return GradientText(
                        "\$${_sumTokenBalances(ReefAppState.instance.model.tokens.selectedErc20List.toList()).toStringAsFixed(0)}",
                        gradient: textGradient(),
                        style: GoogleFonts.poppins(
                            color: Styles.textColor,
                            fontSize: 68,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3),
                      );
                    }),
                  ),
                ]),
          ),
        ));
  }

  double _sumTokenBalances(List<TokenWithAmount> list) {
    var sum = 0.0;
    for (final token in list) {
      double balValue =
          getBalanceValue(decimalsToDouble(token.balance), token.price);
      if (balValue > 0) {
        sum = sum + balValue;
      }
    }
    return sum;
  }

  double _calculateOpacity(double shrinkOffset) =>
      ((shrinkOffset - 200) / 200).abs();
}
