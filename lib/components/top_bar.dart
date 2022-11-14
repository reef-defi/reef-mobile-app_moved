import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:google_fonts/google_fonts.dart';
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
                //TODO put network to model
                if (ReefAppState.instance.model.network.selectedNetworkName ==
                    Network.testnet.name) {
                  return const Text(
                      style: TextStyle(color: Colors.lightBlue, fontSize: 12),
                      'testnet');
                }
                return const SizedBox.shrink();
              })
            ]),

            Observer(builder: (_) {
              var selAddr =
                  ReefAppState.instance.model.accounts.selectedAddress;
              if (selAddr == null ||
                  ReefAppState.instance.model.accounts.signers == null ||
                  ReefAppState.instance.model.accounts.signers.length < 1) {
                return SizedBox.shrink();
              }
              var selSigner = ReefAppState.instance.model.accounts.signers
                  .firstWhere((element) => element.address == selAddr);

              return accountBar(context, selSigner.name);
            })

            // Text('Hi $username',
            //     style: GoogleFonts.spaceGrotesk(
            //         color: Colors.black87,
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold)),
            /*MaterialButton(
              minWidth: 0,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: _handleTap,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(0.0),
              child: Ink(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black87,
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Styles.primaryAccentColor,
                      Styles.secondaryAccentColor,
                    ],
                  ),
                ),
                child: Icon(CupertinoIcons.bell_fill,
                    size: 16, color: Styles.whiteColor),
              ),
            )*/
          ],
        ),
        const Gap(16),
      ],
    ),
  );
}

Widget accountBar(BuildContext context, String title) {
  SizeConfig.init(context);

  return Container(
      // color: Colors.purple,
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
          ])));
}
