import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/model/tokens/TokenNFT.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import '../../model/ReefAppState.dart';

class NFTView extends StatefulWidget {
  const NFTView({Key? key}) : super(key: key);

  @override
  State<NFTView> createState() => _NFTViewState();
}


class _NFTViewState extends State<NFTView> {
  Widget tokenCard(String name,
      {String iconURL,
        double balance = 0.0}) {
    return ViewBoxContainer(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                SizedBox(
                    height: 48,
                    width: 48,
                    child: CachedNetworkImage(
                      imageUrl: iconURL,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[350]!,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: ShapeDecoration(
                            color: Colors.grey[350]!,
                            shape: const CircleBorder(),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        CupertinoIcons.exclamationmark_circle_fill,
                        color: Colors.black12,
                        size: 48,
                      ),
                    ),
                const Gap(8),
                Text(
                  name,
                  style: TextStyle(
                    color: Styles.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(2),
                Text(
                  // TODO allow conversionRate to be null for no data
                  "${balance != 0 ? balance : 0} ${tokenName != "" ? tokenName : name.toUpperCase()} - ${price != 0 ? price.toStringAsFixed(4) : 'No pool data'}",
                  style: TextStyle(color: Styles.textLightColor, fontSize: 16),
                ),
                const Gap(8),
                if (balance != 0)
                  GradientText(
                    "\$${getBalanceValue(balance, price).toStringAsFixed(2)}",
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 24, fontWeight: FontWeight.w700),
                    gradient: textGradient(),
                  ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(0),
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 32, horizontal: 48.0),
              child: Observer(builder: (_) {
                return Wrap(
                  spacing: 24,
                  children: ReefAppState
                      .instance.model.tokens.selectedSignerNFTs
                      .map((TokenNFT tkn) {
                    return Column(
                      children: [
                        tokenCard(tkn.name,
                            tokenName: tkn.symbol,
                            iconURL:  tkn.iconUrl,
                            price: tkn.price?.toDouble()??0,
                            balance: decimalsToDouble(tkn.balance)
                        ),
                      ],
                    );
                  }).toList(),
                );
              }),
            ),
          )
        ]);
  }
}
