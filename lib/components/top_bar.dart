import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/utils/size_config.dart';

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
            Observer(builder: (_) {
              var selAddr =
                  ReefAppState.instance.model.accounts.selectedAddress;

              var selSignerList = ReefAppState.instance.model.accounts.signers
                  .where((element) => element.address == selAddr);

              return selSignerList.length > 0
                  ? accountPill(context, selSignerList.first.name)
                  : const SizedBox.shrink();
            })
          ],
        ),
        const Gap(16),
      ],
    ),
  );
}

Widget accountPill(BuildContext context, String title) {
  SizeConfig.init(context);

  return GestureDetector(
      onTap: () {
        ReefAppState.instance.navigation.navigate(NavigationPage.accounts);
      },
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white30, width: 2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.white30, blurRadius: 2, spreadRadius: 1)
              ],
              color: Colors.purple),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(children: [
                Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text((title ?? ''),
                      style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                )
              ]))));
}
