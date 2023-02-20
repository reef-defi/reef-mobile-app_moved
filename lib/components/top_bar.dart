import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/utils/size_config.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import '../model/network/NetworkCtrl.dart';

Widget topBar(BuildContext context) {
  SizeConfig.init(context);

  return Container(
    color: Colors.transparent,
    child: Column(
      children: <Widget>[
        Gap(getProportionateScreenHeight(50)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SvgPicture.asset(
                'assets/images/reef-logo-light.svg',
                semanticsLabel: "Reef Logo",
                height: 46,
              ),
              Observer(builder: (_) {
                if (ReefAppState.instance.model.network.selectedNetworkName ==
                    Network.testnet.name) {
                  return const Text(
                      style: TextStyle(color: Colors.lightBlue, fontSize: 10),
                      'testnet');
                }
                return const SizedBox.shrink();
              })
            ]),
            Expanded(child: Observer(builder: (_) {
              var selAddr =
                  ReefAppState.instance.model.accounts.selectedAddress;

              var selSignerList = ReefAppState
                  .instance.model.accounts.accountsList
                  .where((element) => element.address == selAddr);

              return selSignerList.length > 0
                  ? Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: accountPill(context, selSignerList.first.name),
                    )
                  : const SizedBox.shrink();
            }))
          ],
        ),
        const Gap(16),
      ],
    ),
  );
}

Widget accountPill(BuildContext context, String title) {
  SizeConfig.init(context);

  // return Row(
  //   mainAxisAlignment: MainAxisAlignment.end,
  //   children: [Container(color: Colors.white, child: Text('hello'))],
  // );

  return GestureDetector(
      onTap: () {
        ReefAppState.instance.navigationCtrl.navigate(NavigationPage.accounts);
      },
      child: Expanded(
          child: Container(
              decoration: BoxDecoration(
                  // border: Border.all(color: Styles.blueColor, width: 2),
                  borderRadius: BorderRadius.circular(20),
                  /*boxShadow: [
                BoxShadow(color: Colors.white30, blurRadius: 2, spreadRadius: 1)
              ],*/
                  color: Colors.white),
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        color: Styles.purpleColor), Expanded(
                      // padding: EdgeInsets.only(left: 10),
                      child: Text(
                        title, // + 'flasdjfls fdsajflasjf fdsa fasf',
                        style: GoogleFonts.spaceGrotesk(
                            color: Styles.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),

                  ])))));
}
