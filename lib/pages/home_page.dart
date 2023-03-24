import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:reef_mobile_app/components/sign/SignatureContentToggle.dart';
import 'package:reef_mobile_app/components/home/NFT_view.dart';
import 'package:reef_mobile_app/components/home/activity_view.dart';
import 'package:reef_mobile_app/components/home/token_view.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/account_modals.dart';
import 'package:reef_mobile_app/components/modals/add_account_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/pages/test_page.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/size_config.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../components/BlurableContent.dart';
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

  final double _textSize = 120.0;
  final bool _isScrolling = false;

  final List _viewsMap = const [
    {"key": 0, "name": "Tokens", "component": TokenView()},
    /*{
      "key": 1,
      "name": "Stakings",
      "active": false,
      "component": const StakingView()
    },*/
    {"key": 1, "name": "NFTs", "component": NFTView()},
    {"key": 2, "name": "Activity", "component": ActivityView()}
  ];

  Widget rowMember(Map member) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        ReefAppState.instance.navigationCtrl
            .navigateHomePage(member["key"] as int);
        // List temp = _viewsMap;
        // for (var element in temp) {
        //   element["active"] = (element["name"] == member["name"]);
        // }
        // setState(() {
        //   _viewsMap = temp;
        // });
      },
      child: Observer(builder: (_) {
        final index =
            ReefAppState.instance.model.homeNavigationModel.currentIndex;
        return AnimatedContainer(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: member["key"] == index
                  ? Styles.whiteColor
                  : Styles.primaryBackgroundColor,
              boxShadow: member["key"] == index
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
              opacity: member["key"] == index ? 1 : 0.5,
              child: Text(
                member["name"] == "Tokens"
                    ? AppLocalizations.of(context)!.balance
                    : member["name"] == "Activity"
                        ? AppLocalizations.of(context)!.activity
                        : AppLocalizations.of(context)!.nfts,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Styles.textColor,
                ),
              ),
            ));
      }),
    );
  }

  Widget navSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
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

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return SignatureContentToggle(Container(
        color: Styles.primaryBackgroundColor,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
            child: CustomScrollView(
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
                Observer(builder: (_) {
                  final accsFeedbackDataModel =
                      ReefAppState.instance.model.accounts.accountsFDM;
                  if (accsFeedbackDataModel.data.isEmpty) {
                    return SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        sliver: SliverToBoxAdapter(
                          child: createAccountBox(context),
                        ));
                  }
                  // return Text('len=${accsFeedbackDataModel.data.length}');
                  final index = ReefAppState
                      .instance.model.homeNavigationModel.currentIndex;
                  return SliverClip(
                    child: _viewsMap[index]["component"],
                  );
                }),

                // height: ((size.height + 64) / 2),
                // width: double.infinity,

                // TODO: ADD ALERT SYSTEM FOR ERRORS HERE
                // test()
              ],
            ))));
  }

  Widget createAccountBox(BuildContext context) => Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.no_account_currently,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Builder(builder: (context) {
            return ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Styles.purpleColor)),
                onPressed: () {
                  showAddAccountModal(
                      AppLocalizations.of(context)!.add_account, openModal,
                      parentContext: context);
                },
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: Text(AppLocalizations.of(context)!.create_new_account));
          }),
        ],
      );

  void showAddAccountModal(String title, Function(String) callback,
      {BuildContext? parentContext}) {
    showModal(parentContext ?? context,
        child: AddAccount(callback: callback), headText: title);
  }

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

  void showCreateAccountModal(BuildContext context,
      {bool fromMnemonic = false}) {
    showModal(context,
        headText: fromMnemonic ? "Import Account" : "Create Account",
        dismissible: true,
        child: CurrentScreen(fromMnemonic: fromMnemonic));
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
                  Row(
                    children: [
                      Builder(builder: (context) {
                        return Text(AppLocalizations.of(context)!.balance,
                            style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w700,
                                color: Styles.primaryColor));
                      }),
                      IconButton(
                          onPressed: () {
                            ReefAppState.instance.appConfigCtrl
                                .toggleDisplayBalance();
                          },
                          icon: Icon(ReefAppState.instance.model.appConfig
                                      .displayBalance ==
                                  true
                              ? Icons.remove_red_eye_sharp
                              : Icons.visibility_off),
                          color: Styles.textLightColor),
                    ],
                  ),
                  Center(
                    child: Observer(builder: (_) {
                      return BlurableContent(
                          GradientText(
                            "\$${NumberFormat.compact().format(_sumTokenBalances(ReefAppState.instance.model.tokens.selectedErc20List.toList()))}",
                            gradient: textGradient(),
                            style: GoogleFonts.poppins(
                                color: Styles.textColor,
                                fontSize: 68,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3),
                          ),
                          ReefAppState.instance.model.appConfig.displayBalance);
                    }),
                  ),
                ]),
          ),
        ));
  }

  double _sumTokenBalances(List<TokenWithAmount> list) {
    var sum = 0.0;
    for (final token in list) {
      double balValue = getBalanceValueBI(token.balance, token.price);
      if (balValue > 0) {
        sum = sum + balValue;
      }
    }
    return sum;
  }

  double _calculateOpacity(double shrinkOffset) =>
      ((shrinkOffset - 200) / 200).abs();
}
