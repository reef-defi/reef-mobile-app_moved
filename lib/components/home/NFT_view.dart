import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../model/ReefAppState.dart';
import '../BlurContent.dart';

class NFTView extends StatefulWidget {
  const NFTView({Key? key}) : super(key: key);

  @override
  State<NFTView> createState() => _NFTViewState();
}

class _NFTViewState extends State<NFTView> {
  Widget nftCard(String name, String iconURL, int balance) {
    return ImageBoxContainer(
        imageUrl: iconURL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              //mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    name,
                    style: const TextStyle(
                        color: Styles.textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                  ),
                )),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Row(
                      children: [
                        const Gap(8),
                        Observer(builder: (context) {
                          return BlurableContent(
                              Text(
                                NumberFormat.compact().format(balance),
                                style: const TextStyle(color: Colors.white),
                              ),
                              ReefAppState
                                  .instance.model.appConfig.displayBalance);
                        }),
                        const Gap(8),
                      ],
                    ))
              ],
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      final selectedNFTs = ReefAppState.instance.model.tokens.selectedNFTs;

      String? message = getFdmListMessage(
          ReefAppState.instance.model.tokens.selectedNFTs, 'NFT');

      return MultiSliver(children: [
        if (message != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
              child: ViewBoxContainer(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24.0, horizontal: 16),
                    child: Text(
                      message,
                      style: TextStyle(
                          color: Styles.textLightColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ),
          )
        else if (selectedNFTs.data.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tkn = selectedNFTs.data[index];
                  return nftCard(
                    tkn.data.name,
                    tkn.data.iconUrl ?? '',
                    tkn.data.balance.toInt(),
                  );
                },
                childCount: selectedNFTs.data.length,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: 200,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  maxCrossAxisExtent: 200),
            ),
          ),
      ]);
    });
  }
}
