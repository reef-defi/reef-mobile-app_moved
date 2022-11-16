import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/tokens/Token.dart';

class TokenSelection extends StatefulWidget {
  const TokenSelection({Key? key, required this.callback}) : super(key: key);

  final Function(TokenWithAmount token) callback;

  @override
  State<TokenSelection> createState() => TokenSelectionState();
}

class TokenSelectionState extends State<TokenSelection> {
  // bool value = false;

  TextEditingController valueContainer = TextEditingController();

  // late List<TokenWithAmount> displayTokens;
  String filterTokensBy = '';

  _changeState() {
    setState(() {
      bool isInputEmpty = valueContainer.text.isEmpty;
      if (!isInputEmpty) {
        filterTokensBy = valueContainer.text.toLowerCase();
        /*displayTokens = displayTokens
              .where((tkn) =>
                  tkn.name
                      .toLowerCase()
                      .contains(valueContainer.text.toLowerCase()) ||
                  tkn.address
                      .toLowerCase()
                      .contains(valueContainer.text.toLowerCase()))
              .toList();*/
      } else {
        filterTokensBy = '';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    /*setState(() {
      displayTokens = widget.tokens;
    });*/
    // Start listening to changes.
    valueContainer.addListener(_changeState);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
      child: Column(
        children: [
          //BoxContent
          ViewBoxContainer(
            color: Colors.white,
            child: TextField(
              controller: valueContainer,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  borderSide:
                      BorderSide(color: Styles.secondaryAccentColor, width: 2),
                ),
                hintText: 'Search token name or address',
              ),
            ),
          ),
          //Information Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxHeight: 256, minWidth: double.infinity),
              child: Observer(builder: (_) {
                var displayTokens = ReefAppState
                    .instance.model.tokens.selectedSignerTokens
                    .toList();
                if (filterTokensBy.isNotEmpty) {
                  displayTokens = displayTokens
                      .where((tkn) =>
                          tkn.name
                              .toLowerCase()
                              .contains(valueContainer.text.toLowerCase()) ||
                          tkn.address
                              .toLowerCase()
                              .contains(valueContainer.text.toLowerCase()))
                      .toList();
                  if (displayTokens.isEmpty &&
                      isEvmAddress(valueContainer.text)) {
                    ReefAppState.instance.tokensCtrl
                        .findToken(valueContainer.text)
                        .then((token) => {
                              if (token != null)
                                {
                                  // TODO show token with option of adding to list
                                  widget
                                      .callback(TokenWithAmount.fromJSON(token))
                                }
                            });
                  }
                }
                return ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: displayTokens
                      .map((e) => Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0x20000000),
                                      width: 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x16000000),
                                        blurRadius: 24,
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8)),
                                child: MaterialButton(
                                    splashColor: const Color(0x555531a9),
                                    color: Colors.white,
                                    padding: const EdgeInsets.fromLTRB(
                                        12, 12, 12, 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                    onPressed: () {
                                      widget.callback(e);
                                      Navigator.of(context).pop();
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(children: [
                                          IconFromUrl(e.iconUrl),
                                          const Gap(12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(e.name,
                                                  style: const TextStyle(
                                                      fontSize: 16)),
                                              Wrap(spacing: 8.0, children: [
                                                Text(toAmountDisplayBigInt(
                                                    e.balance,
                                                    decimals: e.decimals)),
                                                Text(e.symbol)
                                              ]),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    e.address
                                                        .toString()
                                                        .shorten(),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.grey[600]!),
                                                  ),
                                                  TextButton(
                                                      style: TextButton.styleFrom(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 6),
                                                          minimumSize:
                                                              const Size(0, 0),
                                                          tapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap),
                                                      onPressed: () {
                                                        Clipboard.setData(
                                                            ClipboardData(
                                                                text:
                                                                    e.address));
                                                      },
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.copy,
                                                            size: 12,
                                                            color: Styles
                                                                .textLightColor,
                                                          ),
                                                          const Gap(2),
                                                          Text(
                                                            "Copy Address",
                                                            style: TextStyle(
                                                                color: Styles
                                                                    .textColor,
                                                                fontSize: 12),
                                                          ),
                                                        ],
                                                      )),
                                                ],
                                              )
                                            ],
                                          ),
                                        ]),
                                      ],
                                    )),
                              ),
                              if (e.address !=
                                  displayTokens[displayTokens.length - 1]
                                      .address)
                                const Gap(4),
                            ],
                          ))
                      .toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

void showTokenSelectionModal(context, {required callback}) {
  showModal(context,
      child: TokenSelection(callback: callback), headText: "Select Token");
}
