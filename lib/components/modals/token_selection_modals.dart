import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shimmer/shimmer.dart';

class TokenSelection extends StatefulWidget {
  const TokenSelection({Key? key, required this.callback}) : super(key: key);

  final Function(Map token) callback;

  @override
  State<TokenSelection> createState() => TokenSelectionState();
}

class TokenSelectionState extends State<TokenSelection> {
  bool value = false;
  bool _isInputEmpty = true;

  TextEditingController valueContainer = TextEditingController();

  final List initialTokens = [
    {
      "name": "REEF",
      "address": "0x0000000000000000000000000000000001000000",
      "logo": "https://s2.coinmarketcap.com/static/img/coins/64x64/6951.png",
      "balance": 4200.00
    },
    {
      "name": "FMT",
      "address": "0x4676199AdA480a2fCB4b2D4232b7142AF9fe9D87",
      "logo": "",
      "balance": 0.00
    },
    {
      "name": "CHT",
      "address": "0xA6471d3a932be75DF9935A21549e6a40F20e5dFf",
      "logo": "",
      "balance": 0.00
    }
  ];

  late List tokens;

  _changeState() {
    setState(() {
      _isInputEmpty = valueContainer.text.isEmpty;
      if (!_isInputEmpty) {
        setState(() {
          tokens = tokens
              .where((e) =>
                  e["name"]
                      .toString()
                      .toLowerCase()
                      .contains(valueContainer.text.toLowerCase()) ||
                  e["address"]
                      .toString()
                      .toLowerCase()
                      .contains(valueContainer.text.toLowerCase()))
              .toList();
        });
        print(tokens);
      } else {
        setState(() {
          tokens = initialTokens;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      tokens = initialTokens;
    });
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
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: tokens
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
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 12, 12, 10),
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
                                        if (e["logo"].isNotEmpty)
                                          CachedNetworkImage(
                                            imageUrl: e["logo"],
                                            height: 24,
                                            width: 24,
                                            placeholder: (context, url) =>
                                                Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[350]!,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: ShapeDecoration(
                                                  color: Colors.grey[350]!,
                                                  shape: const CircleBorder(),
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                              CupertinoIcons
                                                  .exclamationmark_circle_fill,
                                              color: Colors.black12,
                                              size: 24,
                                            ),
                                          )
                                        else
                                          Icon(CupertinoIcons.question_circle,
                                              color: Colors.grey[600]!,
                                              size: 24),
                                        const Gap(12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(e["name"],
                                                style: const TextStyle(
                                                    fontSize: 16)),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  e["address"]
                                                      .toString()
                                                      .shorten(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600]!),
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
                                                              text: e[
                                                                  "address"]));
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
                                      Text(e["balance"].toString())
                                    ],
                                  )),
                            ),
                            if (e["address"] !=
                                tokens[tokens.length - 1]["address"])
                              const Gap(4),
                          ],
                        ))
                    .toList(),
              ),
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
