import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modals/token_selection_modals.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shimmer/shimmer.dart';

class SwapPage extends StatefulWidget {
  const SwapPage({Key? key}) : super(key: key);

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  TextEditingController amountController = TextEditingController();
  String amount = "";
  TextEditingController amountBottomController = TextEditingController();
  String amountBottom = "";

  Map selectedToken = {
    "name": "REEF",
    "address": "0x0000000000000000000000000000000001000000",
    "logo": "https://s2.coinmarketcap.com/static/img/coins/64x64/6951.png",
    "balance": 4200.00
  };

  Map selectedBottomToken = {
    "name": "FMT",
    "address": "0x4676199AdA480a2fCB4b2D4232b7142AF9fe9D87",
    "logo": "",
    "balance": 0.00
  };

  void _changeSelectedToken(Map token) {
    setState(() {
      selectedToken = token;
    });
  }

  void _changeSelectedBottomToken(Map token) {
    setState(() {
      selectedBottomToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
      child: Column(
        children: [
          Text(
            "Swap",
            style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w500,
                fontSize: 24,
                color: Colors.grey[800]),
          ),
          const Gap(24),
          Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffe1e2e8)),
                        borderRadius: BorderRadius.circular(12),
                        color: Styles.boxBackgroundColor,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              MaterialButton(
                                onPressed: () {
                                  showTokenSelectionModal(context,
                                      callback: _changeSelectedToken);
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                minWidth: 0,
                                height: 36,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                        color: Colors.black26)),
                                child: Row(
                                  children: [
                                    if (selectedToken["logo"].isNotEmpty)
                                      CachedNetworkImage(
                                        imageUrl: selectedToken["logo"],
                                        width: 24,
                                        height: 24,
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
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                          CupertinoIcons
                                              .exclamationmark_circle_fill,
                                          color: Colors.black12,
                                          size: 24,
                                        ),
                                      )
                                    else
                                      Icon(CupertinoIcons.question_circle,
                                          color: Colors.grey[600]!, size: 24),
                                    const Gap(4),
                                    Text(selectedToken["name"]),
                                    const Gap(4),
                                    Icon(CupertinoIcons.chevron_down,
                                        size: 16, color: Styles.textLightColor)
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[\.0-9]'))
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: amountController,
                                  onChanged: (text) {
                                    setState(() {
                                      //you can access nameController in its scope to get
                                      // the value of text entered as shown below
                                      amount = amountController.text;
                                    });
                                  },
                                  decoration: InputDecoration(
                                      constraints:
                                          const BoxConstraints(maxHeight: 32),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent),
                                      ),
                                      border: const OutlineInputBorder(),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      hintText: '0.0',
                                      hintStyle: TextStyle(
                                          color: Styles.textLightColor)),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const Gap(8),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Text(
                                  "Balance: ${selectedToken["balance"].toStringAsFixed(2)} ${selectedToken["name"].toString().toUpperCase()}",
                                  style: TextStyle(
                                      color: Styles.textLightColor,
                                      fontSize: 12),
                                ),
                                TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(30, 10),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap),
                                    child: Text(
                                      "(Max)",
                                      style: TextStyle(
                                          color: Styles.blueColor,
                                          fontSize: 12),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const Gap(4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffe1e2e8)),
                        borderRadius: BorderRadius.circular(12),
                        color: Styles.boxBackgroundColor,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              MaterialButton(
                                onPressed: () {
                                  showTokenSelectionModal(context,
                                      callback: _changeSelectedBottomToken);
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                minWidth: 0,
                                height: 36,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                        color: Colors.black26)),
                                child: Row(
                                  children: [
                                    if (selectedBottomToken["logo"].isNotEmpty)
                                      CachedNetworkImage(
                                        imageUrl: selectedBottomToken["logo"],
                                        width: 24,
                                        height: 24,
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
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                          CupertinoIcons
                                              .exclamationmark_circle_fill,
                                          color: Colors.black12,
                                          size: 24,
                                        ),
                                      )
                                    else
                                      Icon(CupertinoIcons.question_circle,
                                          color: Colors.grey[600]!, size: 24),
                                    const Gap(4),
                                    Text(selectedBottomToken["name"]),
                                    const Gap(4),
                                    Icon(CupertinoIcons.chevron_down,
                                        size: 16, color: Styles.textLightColor)
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[\.0-9]'))
                                    ],
                                    keyboardType: TextInputType.number,
                                    controller: amountBottomController,
                                    onChanged: (text) {
                                      setState(() {
                                        //you can access nameController in its scope to get
                                        // the value of text entered as shown below
                                        amountBottom =
                                            amountBottomController.text;
                                      });
                                    },
                                    decoration: InputDecoration(
                                        constraints:
                                            const BoxConstraints(maxHeight: 32),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        border: const OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        hintText: '0.0',
                                        hintStyle: TextStyle(
                                            color: Styles.textLightColor)),
                                    textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                          const Gap(8),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Text(
                                  "Balance: ${selectedBottomToken["balance"].toStringAsFixed(2)} ${selectedBottomToken["name"].toString().toUpperCase()}",
                                  style: TextStyle(
                                      color: Styles.textLightColor,
                                      fontSize: 12),
                                ),
                                TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(30, 10),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap),
                                    child: Text(
                                      "(Max)",
                                      style: TextStyle(
                                          color: Styles.blueColor,
                                          fontSize: 12),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const Gap(8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                          shadowColor: const Color(0x559d6cff),
                          elevation: 5,
                          primary: (amount.isEmpty || amountBottom.isEmpty)
                              ? const Color(0xff9d6cff)
                              : Styles.secondaryAccentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {},
                        child: Text(
                          (amount.isEmpty || amountBottom.isEmpty)
                              ? "Insert amount"
                              : "Confirm Send",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 96,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          width: 0.5, color: const Color(0xffe1e2e8)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x15000000),
                          blurRadius: 1,
                          offset: Offset(0, 1),
                        )
                      ],
                      color: Styles.boxBackgroundColor,
                    ),
                    height: 28,
                    width: 28,
                    child: Icon(CupertinoIcons.arrow_down,
                        size: 12, color: Styles.textLightColor),
                  ),
                ),
              ]),
        ],
      ),
    );
  }
}
