import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:reef_mobile_app/components/home/NFT_zoom_viewer.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/ReefAppState.dart';
import '../BlurContent.dart';

class NFTView extends StatefulWidget {
  const NFTView({Key? key}) : super(key: key);

  @override
  State<NFTView> createState() => _NFTViewState();
}

class _NFTViewState extends State<NFTView> {
  OverlayEntry? _popupDialog;

  Widget _createGridTileCard(String name, String url, int balance) {
    final dialogKey = GlobalKey<AnimatedDialogState>();
    return Builder(
      builder: (context) => GestureDetector(
        onLongPress: () {
          _popupDialog = _createPopupDialog(dialogKey, name, url, balance);
          HapticFeedback.lightImpact();
          Overlay.of(context).insert(_popupDialog!);
        },
        onLongPressEnd: (details) async {
          await dialogKey.currentState?.controller
              .animateBack(0, duration: const Duration(milliseconds: 300));
          _popupDialog?.remove();
        },
        child: PhysicalModel(
            elevation: 4,
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(0.5),
            child: nftCard(name, url, balance)),
      ),
    );
  }

  OverlayEntry _createPopupDialog(
      Key key, String name, String url, int balance) {
    return OverlayEntry(
      builder: (context) => AnimatedDialog(
        key: key,
        child: _createPopupContent(name, url, balance),
      ),
    );
  }

  Widget _createPopupContent(String name, String url, int balance) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _createNFTHeader(balance, name),
              Image.network(url, fit: BoxFit.fitWidth),
            ],
          ),
        ),
      );

  Widget _createNFTHeader(int balance, String name) => Container(
        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
        width: double.infinity,
        color: Colors.grey.shade800,
        child: Flex(
          direction: Axis.horizontal,
          children: [
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
                          ReefAppState.instance.model.appConfig.displayBalance);
                    }),
                    const Gap(8),
                  ],
                )),
            Text(name, style: const TextStyle(color: Colors.white))
          ],
        ),
      );

  Widget nftCard(String name, String iconURL, int balance) {
    return ImageBoxContainer(
        imageUrl: iconURL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 8),
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
          ReefAppState.instance.model.tokens.selectedNFTs,
          AppLocalizations.of(context)!.nfts,
          AppLocalizations.of(context)!.loading);

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
                      style: const TextStyle(
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
                  return _createGridTileCard(
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
