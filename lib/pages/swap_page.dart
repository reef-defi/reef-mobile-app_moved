import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modals/token_selection_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/swap/swap_settings.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shimmer/shimmer.dart';

import '../components/SignatureContentToggle.dart';

class SwapPage extends StatefulWidget {
  const SwapPage({Key? key}) : super(key: key);

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  // TODO: use tokenList instead of selectedSignerTokens
  var tokens = ReefAppState.instance.model.tokens.selectedSignerTokens;

  TokenWithAmount? selectedTopToken = ReefAppState
      .instance.model.tokens.selectedSignerTokens
      .firstWhere((token) => token.address == Constants.REEF_TOKEN_ADDRESS);

  TokenWithAmount? selectedBottomToken;

  SwapSettings settings = SwapSettings(1, 0.8);

  TextEditingController amountTopController = TextEditingController();
  String reserveTop = "";
  TextEditingController amountBottomController = TextEditingController();
  String reserveBottom = "";

  void _changeSelectedTopToken(TokenWithAmount token) {
    setState(() {
      selectedTopToken = token;
      _getPoolReserves();
    });
  }

  void _changeSelectedBottomToken(TokenWithAmount token) {
    setState(() {
      selectedBottomToken = token;
      _getPoolReserves();
    });
  }

  void _switchTokens() {
    setState(() {
      var temp = selectedTopToken;
      selectedTopToken = selectedBottomToken;
      selectedBottomToken = temp;
      _getPoolReserves();
    });
  }

  void _getPoolReserves() async {
    if (selectedTopToken == null || selectedBottomToken == null) {
      return;
    }

    selectedTopToken = selectedTopToken!.setAmount("0");
    amountTopController.clear();
    selectedBottomToken = selectedBottomToken!.setAmount("0");
    amountBottomController.clear();

    var res = await ReefAppState.instance.swapCtrl.getPoolReserves(
        selectedTopToken!.address, selectedBottomToken!.address);
    if (res is bool && res == false) {
      print("ERROR: Pool does not exist");
      reserveTop = "";
      reserveBottom = "";
      return;
    }

    reserveTop = res["reserve1"];
    reserveBottom = res["reserve2"];
    print("Pool reserves: ${res['reserve1']}, ${res['reserve1']}");
  }

  Future<void> _amountTopUpdated(String value) async {
    if (selectedTopToken == null) {
      return;
    }

    var formattedValue =
        toStringWithoutDecimals(value, selectedTopToken!.decimals);

    if (value.isEmpty ||
        formattedValue.replaceAll(".", "").replaceAll("0", "").isEmpty) {
      print("ERROR: Invalid value");
      if (selectedBottomToken != null) {
        selectedBottomToken = selectedBottomToken!.setAmount("0");
        amountBottomController.clear();
      }
      return;
    }

    selectedTopToken = selectedTopToken!.setAmount(formattedValue);

    if (BigInt.parse(formattedValue) > selectedTopToken!.balance) {
      print("WARN: Insufficient ${selectedTopToken!.symbol} balance");
    }

    if (reserveTop.isEmpty) {
      return; // Pool does not exist
    }

    var token1 = selectedTopToken!.setAmount(reserveTop);
    var token2 = selectedBottomToken!.setAmount(reserveBottom);

    var res = (await ReefAppState.instance.swapCtrl
            .getSwapAmount(value, false, token1, token2))
        .replaceAll("\"", "");

    selectedBottomToken = selectedBottomToken!.setAmount(res);
    amountBottomController.text = toAmountDisplayBigInt(
        selectedBottomToken!.amount,
        decimals: selectedBottomToken!.decimals);

    print(
        "${selectedTopToken!.amount} - ${toAmountDisplayBigInt(selectedTopToken!.amount, decimals: selectedTopToken!.decimals)}");
    print(
        "${selectedBottomToken!.amount} - ${toAmountDisplayBigInt(selectedBottomToken!.amount, decimals: selectedBottomToken!.decimals)}");
  }

  Future<void> _amountBottomUpdated(String value) async {
    if (selectedBottomToken == null) {
      return;
    }

    var formattedValue =
        toStringWithoutDecimals(value, selectedBottomToken!.decimals);

    if (value.isEmpty ||
        formattedValue.replaceAll(".", "").replaceAll("0", "").isEmpty) {
      print("ERROR: Invalid value");
      if (selectedTopToken != null) {
        selectedTopToken = selectedTopToken!.setAmount("0");
        amountTopController.clear();
      }
      return;
    }

    selectedBottomToken = selectedBottomToken!.setAmount(formattedValue);

    if (reserveTop.isEmpty) {
      return; // Pool does not exist
    }

    if (BigInt.parse(formattedValue) > BigInt.parse(reserveBottom)) {
      print(
          "ERROR: Insufficient ${selectedBottomToken!.symbol} liquidity in pool");
      selectedTopToken = selectedTopToken!.setAmount("0");
      amountTopController.clear();
      return;
    }

    var token1 = selectedTopToken!.setAmount(reserveTop);
    var token2 = selectedBottomToken!.setAmount(reserveBottom);

    var res = (await ReefAppState.instance.swapCtrl
            .getSwapAmount(value, true, token1, token2))
        .replaceAll("\"", "");

    if (BigInt.parse(res) > selectedTopToken!.balance) {
      print("WARN: Insufficient ${selectedTopToken!.symbol} balance");
    }

    selectedTopToken = selectedTopToken!.setAmount(res);
    amountTopController.text = toAmountDisplayBigInt(selectedTopToken!.amount,
        decimals: selectedTopToken!.decimals);

    print(
        "${selectedTopToken!.amount} - ${toAmountDisplayBigInt(selectedTopToken!.amount, decimals: selectedTopToken!.decimals)}");
    print(
        "${selectedBottomToken!.amount} - ${toAmountDisplayBigInt(selectedBottomToken!.amount, decimals: selectedBottomToken!.decimals)}");
  }

  void _executeSwap() async {
    if (selectedTopToken == null || selectedBottomToken == null) {
      return;
    }

    if (selectedTopToken!.amount <= BigInt.zero) {
      return;
    }
    var signerAddress = await ReefAppState.instance.storage
        .getValue(StorageKey.selected_address.name);
    var res = await ReefAppState.instance.swapCtrl.swapTokens(
        signerAddress, selectedTopToken!, selectedBottomToken!, settings);
    _getPoolReserves();
    print(res);
  }

  String _toAmountDisplay(String amount, int decimals) {
    return (BigInt.parse(amount) / BigInt.from(10).pow(decimals))
        .toStringAsFixed(decimals);
  }

  void _testFindToken() async {
    var res = await ReefAppState.instance.tokensCtrl
        .findToken(Constants.REEF_TOKEN_ADDRESS);
    print("TEST FIND TOKEN: ${res}");
    tokens.add(TokenWithAmount.fromJSON(res));
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
      child: Column(
        children: [
          TextButton(onPressed: _testFindToken, child: Text("Test")),
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
                                      callback: _changeSelectedTopToken);
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
                                    if (selectedTopToken == null)
                                      const Text("Select token")
                                    else ...[
                                      IconFromUrl(selectedTopToken!.iconUrl),
                                      const Gap(4),
                                      Text(selectedTopToken!.symbol),
                                    ],
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
                                  controller: amountTopController,
                                  onChanged: (text) async {
                                    await _amountTopUpdated(
                                        amountTopController.text);
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
                                if (selectedTopToken != null) ...[
                                  Text(
                                    "Balance: ${toAmountDisplayBigInt(selectedTopToken!.balance, decimals: selectedTopToken!.decimals)} ${selectedTopToken!.symbol}",
                                    style: TextStyle(
                                        color: Styles.textLightColor,
                                        fontSize: 12),
                                  ),
                                  TextButton(
                                      onPressed: () async {
                                        var topTokenBalance =
                                            toAmountDisplayBigInt(
                                                selectedTopToken!.balance,
                                                decimals:
                                                    selectedTopToken!.decimals,
                                                fractionDigits:
                                                    selectedTopToken!.decimals);
                                        await _amountTopUpdated(
                                            topTokenBalance);
                                        amountTopController.text =
                                            topTokenBalance;
                                      },
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
                                ]
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
                                    if (selectedBottomToken == null)
                                      const Text("Select token")
                                    else ...[
                                      IconFromUrl(selectedBottomToken!.iconUrl),
                                      const Gap(4),
                                      Text(selectedBottomToken!.symbol),
                                    ],
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
                                    onChanged: (text) async {
                                      await _amountBottomUpdated(
                                          amountBottomController.text);
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
                                if (selectedBottomToken != null)
                                  Text(
                                    "Balance: ${toAmountDisplayBigInt(selectedBottomToken!.balance, decimals: selectedBottomToken!.decimals)} ${selectedBottomToken!.symbol}",
                                    style: TextStyle(
                                        color: Styles.textLightColor,
                                        fontSize: 12),
                                  )
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
                          primary: (selectedTopToken == null ||
                                  selectedTopToken!.amount <= BigInt.zero ||
                                  selectedBottomToken == null ||
                                  selectedBottomToken!.amount <= BigInt.zero)
                              ? const Color(0xff9d6cff)
                              : Styles.secondaryAccentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (selectedTopToken == null ||
                              selectedTopToken!.amount <= BigInt.zero ||
                              selectedBottomToken == null ||
                              selectedBottomToken!.amount <= BigInt.zero) {
                            return;
                          }
                          _executeSwap();
                        },
                        child: Text(
                          // TODO changes not reflected in UI
                          (selectedTopToken == null
                              ? "Select sell token"
                              : selectedBottomToken == null
                                  ? "Select buy token"
                                  : selectedTopToken!.amount <= BigInt.zero ||
                                          selectedBottomToken!.amount <=
                                              BigInt.zero
                                      ? "Insert amount"
                                      : "Swap"),
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
                      child: IconButton(
                        icon: Icon(
                          CupertinoIcons.arrow_down,
                          color: Styles.textLightColor,
                          size: 12,
                        ),
                        onPressed: () {
                          _switchTokens();
                        },
                      )),
                ),
              ]),
        ],
      ),
    ));
  }
}
