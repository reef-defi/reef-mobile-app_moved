import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modals/signing_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/size_config.dart';
import 'package:reef_mobile_app/utils/styles.dart';

Widget topBar(BuildContext context) {
  SizeConfig.init(context);

  _handleTap() async {
    if (kDebugMode) {
      print("Notification icon clicked");
      HapticFeedback.selectionClick();
      // showSigningModal(context, variant: "Sign message");

      var signerAddress = await ReefAppState.instance.storage
          .getValue(StorageKey.selected_address.name);
      TokenWithAmount tokenToTranfer = TokenWithAmount(
          name: 'REEF',
          address: Constants.REEF_TOKEN_ADDRESS,
          iconUrl:
              'https://s2.coinmarketcap.com/static/img/coins/64x64/6951.png',
          symbol: 'REEF',
          balance: BigInt.parse('1542087625938626180855'),
          decimals: 18,
          amount: BigInt.zero,
          price: 0.0841);
      await ReefAppState.instance.transferCtrl.transferTokens(signerAddress,
          "5FX42URyoa9mfFTwoLiWrprxvgCsaA81AssRLw2dDj4HizST", tokenToTranfer);
    }
  }

  return Container(
    color: Colors.transparent,
    // padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: <Widget>[
        Gap(getProportionateScreenHeight(50)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(
              'assets/images/reef.svg',
              semanticsLabel: "Reef Logo",
              height: 32,
            ),
            // Text('Hi $username',
            //     style: GoogleFonts.spaceGrotesk(
            //         color: Colors.black87,
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold)),
            MaterialButton(
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
            )
          ],
        ),
        const Gap(16),
      ],
    ),
  );
}
