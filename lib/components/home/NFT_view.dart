import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:reef_mobile_app/components/NFT_videoplayer.dart';
import 'package:reef_mobile_app/components/home/NFT_zoom_viewer.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

import '../../model/ReefAppState.dart';
import '../BlurContent.dart';

class ZoomedNFTsVIdeoPlayer extends StatefulWidget {
  final String url;
  ZoomedNFTsVIdeoPlayer(this.url);

  @override
  State<ZoomedNFTsVIdeoPlayer> createState() => _ZoomedNFTsVIdeoPlayerState();
}

class _ZoomedNFTsVIdeoPlayerState extends State<ZoomedNFTsVIdeoPlayer> {
  late VideoPlayerController _controller;
  bool _isVideoLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _controller.addListener(() {
      if (_controller.value.isInitialized && !_isVideoLoaded) {
        setState(() {
          _isVideoLoaded = true;
        });
      }
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double videoAspectRatio = _controller.value.aspectRatio;
    Widget videoPlayerWidget;
    if (_isVideoLoaded) {
      videoPlayerWidget = VideoPlayer(_controller);
    } else {
      videoPlayerWidget = Container(
        color: Styles.primaryAccentColorDark,
        child: Center(
            child: CircularProgressIndicator(
          color: Styles.whiteColor,
        )),
      );
    }

    return AspectRatio(
      aspectRatio: videoAspectRatio,
      child: Container(
        width: size.width,
        height: size.width / videoAspectRatio,
        child: videoPlayerWidget,
      ),
    );
  }
}

class NFTView extends StatefulWidget {
  const NFTView({Key? key}) : super(key: key);

  @override
  State<NFTView> createState() => _NFTViewState();
}

class _NFTViewState extends State<NFTView> {
  OverlayEntry? _popupDialog;
  bool _remountNFTsVideoPlayer = false;

  Widget _createGridTileCard(
      String name, String mimetype, String url, int balance) {
    final dialogKey = GlobalKey<AnimatedDialogState>();
    return Builder(
      builder: (context) => GestureDetector(
        onLongPress: () {
          setState(() {
            _remountNFTsVideoPlayer = !_remountNFTsVideoPlayer;
          });
          _popupDialog =
              _createPopupDialog(dialogKey, name, mimetype, url, balance);
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
            child: nftCard(name, mimetype, url, balance)),
      ),
    );
  }

  OverlayEntry _createPopupDialog(
      Key key, String name, String mimetype, String url, int balance) {
    return OverlayEntry(
      builder: (context) => AnimatedDialog(
        key: key,
        child: _createPopupContent(name, mimetype, url, balance),
      ),
    );
  }

  Widget _createPopupContent(
      String name, String mimetype, String url, int balance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Styles.whiteColor,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _createNFTHeader(balance, name),
              mimetype == "video/mp4"
                  ? ZoomedNFTsVIdeoPlayer(url)
                  : Image.network(url, fit: BoxFit.fitWidth),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget nftCard(String name, String mimetype, String iconURL, int balance) {
    Widget child = Column(
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
                          ReefAppState.instance.model.appConfig.displayBalance);
                    }),
                    const Gap(8),
                  ],
                ))
          ],
        ),
      ],
    );
    return mimetype == "video/mp4"
        ? Container(
            key: Key(_remountNFTsVideoPlayer.toString()),
            child: NFTsVideoPlayer(iconURL, child))
        : ImageBoxContainer(imageUrl: iconURL, child: child);
  }

  void forceStop() {
    setState(() {});
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
                    child: Column(
                      children: [
                        Text(
                          message,
                          style: TextStyle(
                              color: Styles.textLightColor,
                              fontWeight: FontWeight.w500),
                        ),
                        if (selectedNFTs.hasStatus(StatusCode.error))
                          ElevatedButton(
                              onPressed: () =>
                                  ReefAppState.instance.tokensCtrl.reload(true),
                              child: Text(AppLocalizations.of(context)!.reload))
                      ],
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
                    tkn.data.mimetype ?? '',
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
