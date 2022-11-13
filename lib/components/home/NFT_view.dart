import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
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
  Widget nftCard(String name, String iconURL, int balance) {
    return ViewBoxContainer(
        imageUrl: iconURL,
        child:  Column(
           mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    color: Colors.white,
                    child: Row(children: [
                      const Gap(24),
                      Text(
                        // TODO allow conversionRate to be null for no data
                        "${balance}x",
                        style: TextStyle(
                            color: Styles.textLightColor, fontSize: 16),
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
                    ])),
                const Gap(8),
              ],
            )
    );
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
                  runSpacing: 24,
                  children: ReefAppState
                      .instance.model.tokens.selectedSignerNFTs
                      .map((TokenNFT tkn) {
                    return Column(
                      children: [
                        nftCard(tkn.name, tkn.iconUrl ?? '',
                            tkn.balance.toInt() ?? 0),
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
