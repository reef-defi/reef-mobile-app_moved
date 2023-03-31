import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/MaxAmountButton.dart';
import 'package:reef_mobile_app/components/SliderStandAlone.dart';
import 'package:reef_mobile_app/components/modals/token_selection_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/swap/swap_settings.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shimmer/shimmer.dart';

import '../components/sign/SignatureContentToggle.dart';

class SwapPage extends StatefulWidget {
  final String preselected;
  const SwapPage(this.preselected, {Key? key}) : super(key: key);

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  // TODO: use tokenList instead of selectedSignerTokens
  var tokens = ReefAppState.instance.model.tokens.selectedErc20List;

  TokenWithAmount? selectedTopToken = ReefAppState
      .instance.model.tokens.selectedErc20List
      .firstWhere((token) => token.address == Constants.REEF_TOKEN_ADDRESS);

  TokenWithAmount? selectedBottomToken;

  SwapSettings settings = SwapSettings(1, 0.8);

  TextEditingController amountTopController = TextEditingController();
  String reserveTop = "";
  TextEditingController amountBottomController = TextEditingController();
  String reserveBottom = "";
  bool _isValueEditing = false;
  bool _isValueSecondEditing = false;

  double rating = 0;
  bool isSelectedTokenREEF = true;

  TextEditingController amountController = TextEditingController();
  String amount = "";
  FocusNode _focus = FocusNode();
  FocusNode _focusSecond = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    
    //If token is not REEF - set target to reef
    if (widget.preselected != Constants.REEF_TOKEN_ADDRESS) {
     setState(() {
       isSelectedTokenREEF = false;
       selectedBottomToken = ReefAppState
      .instance.model.tokens.selectedErc20List
      .firstWhere((token) => token.address == Constants.REEF_TOKEN_ADDRESS);
     });
    }else{
      setState(() {
       selectedTopToken = ReefAppState
      .instance.model.tokens.selectedErc20List
      .firstWhere((token) => token.address == Constants.REEF_TOKEN_ADDRESS);
     });
    }
  }

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

  void _onFocusChange() {
    setState(() {
      _isValueEditing = !_isValueEditing;
    });
  }

  void _onFocusSecondChange() {
    setState(() {
      _isValueSecondEditing = !_isValueSecondEditing;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
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
    var signerAddress = await ReefAppState.instance.storageCtrl
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
    tokens.add(TokenWithAmount.fromJson(res));
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Column(children: [
      const Gap(64),
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Styles.primaryBackgroundColor,
            boxShadow: neumorphicShadow()),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Gap(24),
            Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Column(
                    children: <Widget>[
                      !isSelectedTokenREEF? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: _isValueEditing
                              ? Border.all(color: const Color(0xffa328ab))
                              : Border.all(color: const Color(0x00d7d1e9)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (_isValueEditing)
                              const BoxShadow(
                                  blurRadius: 15,
                                  spreadRadius: -8,
                                  offset: Offset(0, 10),
                                  color: Color(0x40a328ab))
                          ],
                          color: _isValueEditing
                              ? const Color(0xffeeebf6)
                              : const Color(0xffE7E2F2),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                MaterialButton(
                                  onPressed: () {
                                    showTokenSelectionModal(context,
                                        callback: _changeSelectedTopToken,selectedToken: selectedBottomToken?.address);
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
                                          size: 16,
                                          color: Styles.textLightColor)
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
                                    MaxAmountButton(
                                      onPressed: () async {
                                        //TODO: anukul -  set slider to max
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
                                    )
                                  ]
                                ],
                              ),
                            )
                          ],
                        ),
                      ):
                      // If selected Token is REEF
                       Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: _isValueEditing
                        ? Border.all(color: const Color(0xffa328ab))
                        : Border.all(color: const Color(0x00d7d1e9)),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (_isValueEditing)
                        const BoxShadow(
                            blurRadius: 15,
                            spreadRadius: -8,
                            offset: Offset(0, 10),
                            color: Color(0x40a328ab))
                    ],
                    color: _isValueEditing
                        ? const Color(0xffeeebf6)
                        : const Color(0xffE7E2F2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              IconFromUrl(selectedTopToken?.iconUrl, size: 48),
                              const Gap(13),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedTopToken != null
                                        ? selectedTopToken!.name
                                        : 'Select',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Color(0xff19233c)),
                                  ),
                                  Text(
                                    "${toAmountDisplayBigInt(selectedTopToken!.balance)} ${selectedTopToken!.name.toUpperCase()}",
                                    style: TextStyle(
                                        color: Styles.textLightColor,
                                        fontSize: 12),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Expanded(
                            child: TextFormField(
                              focusNode: _focus,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[\.0-9]'))
                              ],
                              keyboardType: TextInputType.number,
                              controller: amountController,
                              onChanged: (text) async {
                                setState(() {
                                  //you can access nameController in its scope to get
                                  // the value of text entered as shown below
                                  amount = amountController.text;
                                });
                              },
                              decoration: InputDecoration(
                                  constraints:
                                      const BoxConstraints(maxHeight: 32),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  border: const OutlineInputBorder(),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  hintText: '0.0',
                                  hintStyle:
                                      TextStyle(color: Styles.textLightColor)),
                              textAlign: TextAlign.right,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Address cannot be empty';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                    
                      const Gap(14),
                      isSelectedTokenREEF?Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: _isValueEditing
                              ? Border.all(color: const Color(0xffa328ab))
                              : Border.all(color: const Color(0x00d7d1e9)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (_isValueEditing)
                              const BoxShadow(
                                  blurRadius: 15,
                                  spreadRadius: -8,
                                  offset: Offset(0, 10),
                                  color: Color(0x40a328ab))
                          ],
                          color: _isValueEditing
                              ? const Color(0xffeeebf6)
                              : const Color(0xffE7E2F2),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                MaterialButton(
  onPressed: () {
    showTokenSelectionModal(context,
        callback: _changeSelectedBottomToken,selectedToken: selectedTopToken?.address);
  },
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  minWidth: 0,
  height: 36,
  elevation: 0,
  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    // Remove the `BorderSide` from the `shape` property
  ),
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
          size: 16,
          color: Styles.textLightColor)
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
                                          constraints: const BoxConstraints(
                                              maxHeight: 32),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          border: const OutlineInputBorder(),
                                          focusedBorder:
                                              const OutlineInputBorder(
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
                      )
                      :
                      // render this if selected token is not reef
                      Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: _isValueSecondEditing
                        ? Border.all(color: const Color(0xffa328ab))
                        : Border.all(color: const Color(0x00d7d1e9)),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (_isValueSecondEditing)
                        const BoxShadow(
                            blurRadius: 15,
                            spreadRadius: -8,
                            offset: Offset(0, 10),
                            color: Color(0x40a328ab))
                    ],
                    color: _isValueSecondEditing
                        ? const Color(0xffeeebf6)
                        : const Color(0xffE7E2F2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              IconFromUrl(selectedBottomToken?.iconUrl, size: 48),
                              const Gap(13),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedBottomToken != null
                                        ? selectedBottomToken!.name
                                        : 'Select',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Color(0xff19233c)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Expanded(
                            child: TextFormField(
                              focusNode: _focusSecond,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[\.0-9]'))
                              ],
                              keyboardType: TextInputType.number,
                              controller: amountController,
                              onChanged: (text) async {
                                setState(() {
                                  //you can access nameController in its scope to get
                                  // the value of text entered as shown below
                                  amount = amountController.text;
                                });
                              },
                              decoration: InputDecoration(
                                  constraints:
                                      const BoxConstraints(maxHeight: 32),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  border: const OutlineInputBorder(),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  hintText: '0.0',
                                  hintStyle:
                                      TextStyle(color: Styles.textLightColor)),
                              textAlign: TextAlign.right,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Address cannot be empty';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                      const Gap(36),
                      SliderStandAlone(
                          rating: rating,
                          onChanged: (newRating) async {
                            setState(() {
                              rating = newRating;
                              String amountValue = (double.parse(
                                          toAmountDisplayBigInt(
                                              selectedTopToken!.balance)) *
                                      rating)
                                  .toStringAsFixed(2);
                              amount = amountValue;
                              amountController.text = amountValue;
                              amountTopController.text = amountValue;
                            });
                          }),
                      const Gap(36),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            shadowColor: const Color(0x559d6cff),
                            elevation: 0,
                            backgroundColor: (selectedTopToken == null ||
                                    selectedTopToken!.amount <= BigInt.zero ||
                                    selectedBottomToken == null ||
                                    selectedBottomToken!.amount <= BigInt.zero)
                                ? Color.fromARGB(255, 125, 125, 125)
                                : Color.fromARGB(0, 215, 31, 31),
                            padding: const EdgeInsets.all(0),
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
                          child: Ink(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 22),
                            decoration: BoxDecoration(
                              color: const Color(0xffe6e2f1),
                              gradient: (selectedTopToken == null ||
                                      selectedTopToken!.amount <= BigInt.zero ||
                                      selectedBottomToken == null ||
                                      selectedBottomToken!.amount <=
                                          BigInt.zero)
                                  ? null
                                  : const LinearGradient(colors: [
                                      Color(0xffae27a5),
                                      Color(0xff742cb2),
                                    ]),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(14.0)),
                            ),
                            child: Center(
                              child: Text(
                                (selectedTopToken == null
                                    ? "Select sell token"
                                    : selectedBottomToken == null
                                        ? "Select buy token"
                                        : selectedTopToken!.amount <=
                                                    BigInt.zero ||
                                                selectedBottomToken!.amount <=
                                                    BigInt.zero
                                            ? "Insert amount"
                                            : "Swap"),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: (selectedTopToken == null || selectedBottomToken == null||selectedTopToken!.amount <=
                                                    BigInt.zero ||
                                                selectedBottomToken!.amount <=
                                                    BigInt.zero)
                                ? const Color(0x65898e9c)
                                : Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
          ],
        ),
      ),
    ]));
  }
}
