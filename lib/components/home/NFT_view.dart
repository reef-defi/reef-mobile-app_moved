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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(children: [
                      const Gap(12),
                      Text(
                        // TODO allow conversionRate to be null for no data
                        "${balance}x",
                        style: TextStyle(
                            color: Styles.textLightColor,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const Gap(8),
                      Text(
                        name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const Gap(12),
                    ]))
              ],
            ),
            const Gap(12)
          ],
        )
        /*Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(children: [
                      const Gap(24),
                      Text(
                        // TODO allow conversionRate to be null for no data
                        "${balance}x",
                        style: TextStyle(
                            color: Styles.textLightColor,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const Gap(8),
                      Text(
                        name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ])),
                const Gap(8),
              ],
            )*/
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
            child:
                ReefAppState.instance.model.tokens.selectedSignerNFTs.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 32, horizontal: 48.0),
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
                        }))
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: ViewBoxContainer(
                            child: Center(
                                child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Text(
                            "No NFTs on this account",
                            style: TextStyle(
                                color: Styles.textLightColor,
                                fontWeight: FontWeight.w500),
                          ),
                        ))),
                      ),
          )
        ]);
  }
}
