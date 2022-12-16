import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/model/feedback-data-model/FeedbackDataModel.dart';
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
                    decoration: const BoxDecoration(
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
                        style: const TextStyle(
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
        );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {

      String? message = getFdmListMessage(ReefAppState.instance.model.tokens.selectedNFTs, 'NFT');

      return Flex(direction: Axis.vertical, children: [
        if (message!=null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: ViewBoxContainer(
                child: Center(
                    child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                message,
                style: TextStyle(
                    color: Styles.textLightColor, fontWeight: FontWeight.w500),
              ),
            ))),
          )
        else
          Expanded(
            child: GridView.builder(
                controller: ScrollController(),
                scrollDirection: Axis.vertical,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    mainAxisExtent: 125,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    maxCrossAxisExtent: 200),
                itemBuilder: (context, index) => Builder(
                  builder: (context) {
                    final tkn = ReefAppState
                        .instance.model.tokens.selectedNFTs.data[index];
                    return nftCard(tkn.data.name, tkn.data.iconUrl ?? '',
                          tkn.data.balance.toInt(),
                    );
                  },
                ),
                itemCount:
                    ReefAppState.instance.model.tokens.selectedNFTs.data.length,
              )
          )
      ]);
    });
  }

}
