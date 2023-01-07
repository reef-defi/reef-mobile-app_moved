import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modals/select_account_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import '../components/SignatureContentToggle.dart';

class SendPage extends StatefulWidget {
  final String preselected;
  SendPage(this.preselected, {Key? key}) : super(key: key);

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  TextEditingController valueController = TextEditingController();
  String address = "";
  TextEditingController amountController = TextEditingController();
  String amount = "";

  late String selectedTokenAddress;
  bool _isValueEditing = false;
  bool _isValueSecondEditing = false;
  double rating = 0;

  FocusNode _focus = FocusNode();
  FocusNode _focusSecond = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    _focusSecond.addListener(_onFocusSecondChange);
    setState(() {
      selectedTokenAddress = widget.preselected;
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
    _focusSecond.removeListener(_onFocusSecondChange);
    _focus.dispose();
    _focusSecond.dispose();
  }

  void _changeSelectedToken(String tokenAddr) {
    setState(() {
      selectedTokenAddress = tokenAddr;
    });
  }

  void _onConfirmSend(TokenWithAmount sendToken) async {
    if (address.isEmpty || amount.isEmpty || sendToken.balance <= BigInt.zero) {
      return;
    }
    var signerAddress = await ReefAppState.instance.storage
        .getValue(StorageKey.selected_address.name);
    TokenWithAmount tokenToTransfer = TokenWithAmount(
        name: sendToken.name,
        address: sendToken.address,
        iconUrl: sendToken.iconUrl,
        symbol: sendToken.name,
        balance: sendToken.balance,
        decimals: sendToken.decimals,
        amount:
            BigInt.parse(toStringWithoutDecimals(amount, sendToken.decimals)),
        price: 0);

    await ReefAppState.instance.transferCtrl
        .transferTokens(signerAddress, address, tokenToTransfer);
    amountController.clear();
    valueController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Column(
      children: [
        buildHeader(context),
        Gap(16),
        Observer(builder: (_) {
          var tokens = ReefAppState.instance.model.tokens.selectedErc20List;
          var selectedToken =
              tokens.firstWhere((tkn) => tkn.address == selectedTokenAddress);
          if (selectedToken == null && !tokens.isEmpty) {
            selectedToken = tokens[0];
          }
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Styles.primaryBackgroundColor,
                boxShadow: neumorphicShadow()),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: <Widget>[
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
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: MaterialButton(
                          elevation: 0,
                          height: 48,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onPressed: () {
                            showSelectAccountModal(
                              "Select account",
                              (selectedAddress) {
                                setState(() {
                                  address = selectedAddress;
                                  valueController.text = selectedAddress;
                                });
                              },
                            );
                          },
                          color: const Color(0xffDFDAED),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          focusNode: _focus,
                          controller: valueController,
                          onChanged: (text) {
                            setState(() {
                              address = valueController.text;
                            });
                          },
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              border: InputBorder.none,
                              hintText: 'Send to address',
                              hintStyle:
                                  TextStyle(color: Styles.textLightColor)),
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
                ),
                const Gap(10),
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
                              IconFromUrl(selectedToken.iconUrl, size: 48),
                              const Gap(13),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedToken != null
                                        ? selectedToken.name
                                        : 'Select',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Color(0xff19233c)),
                                  ),
                                  Text(
                                    "${toAmountDisplayBigInt(selectedToken.balance)} ${selectedToken.name.toUpperCase()}",
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
                              focusNode: _focusSecond,
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
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         "Balance: ${toAmountDisplayBigInt(selectedToken.balance)} ${selectedToken.name.toUpperCase()}",
                      //         style: TextStyle(
                      //             color: Styles.textLightColor, fontSize: 12),
                      //       ),
                      //       /*TextButton(
                      //               onPressed: () {},
                      //               style: TextButton.styleFrom(
                      //                   padding: EdgeInsets.zero,
                      //                   minimumSize: const Size(30, 10),
                      //                   tapTargetSize:
                      //                       MaterialTapTargetSize.shrinkWrap),
                      //               child: Text(
                      //                 "(Max)",
                      //                 style: TextStyle(
                      //                     color: Styles.blueColor,
                      //                     fontSize: 12),
                      //               ))*/
                      //     ],
                      //   ),
                      // )
                    ],
                  ),
                ),
                const Gap(36),
                SliderTheme(
                  data: SliderThemeData(
                      showValueIndicator: ShowValueIndicator.never,
                      overlayShape: SliderComponentShape.noOverlay,
                      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                      valueIndicatorColor: Color(0xff742cb2),
                      thumbColor: const Color(0xff742cb2),
                      inactiveTickMarkColor: Color(0xffc0b8dc),
                      trackShape: const GradientRectSliderTrackShape(
                          gradient: LinearGradient(colors: <Color>[
                            Color(0xffae27a5),
                            Color(0xff742cb2),
                          ]),
                          darkenInactive: true),
                      activeTickMarkColor: const Color(0xffffffff),
                      tickMarkShape:
                          const RoundSliderTickMarkShape(tickMarkRadius: 4),
                      thumbShape: const ThumbShape()),
                  child: Slider(
                    value: rating,
                    onChanged: (newRating) {
                      setState(() {
                        rating = newRating;
                        String amountValue = (double.parse(
                                    toAmountDisplayBigInt(
                                        selectedToken.balance)) *
                                rating)
                            .toStringAsFixed(2);
                        amount = amountValue;
                        amountController.text = amountValue;
                      });
                    },
                    divisions: 100,
                    label: "${(rating * 100).toInt()}%",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "0%",
                        style: TextStyle(
                            color: Styles.textLightColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                      Text(
                        "50%",
                        style: TextStyle(
                            color: Styles.textLightColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                      Text(
                        "100%",
                        style: TextStyle(
                            color: Styles.textLightColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Gap(36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      shadowColor: const Color(0x559d6cff),
                      elevation: 0,
                      backgroundColor: (address.isEmpty || amount.isEmpty)
                          ? const Color(0xffe6e2f1)
                          : Colors.transparent,
                      padding: const EdgeInsets.all(0),
                    ),
                    onPressed: () => _onConfirmSend(selectedToken),
                    child: Ink(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 22),
                      decoration: BoxDecoration(
                        color: const Color(0xffe6e2f1),
                        gradient: (!(address.isEmpty || amount.isEmpty))
                            ? const LinearGradient(colors: [
                                Color(0xffae27a5),
                                Color(0xff742cb2),
                              ])
                            : null,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(14.0)),
                      ),
                      child: Center(
                        child: Text(
                          address.isEmpty
                              ? 'Missing destination address'
                              : amount.isEmpty
                                  ? "Insert amount"
                                  : "Confirm Send",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: (address.isEmpty || amount.isEmpty)
                                ? const Color(0x65898e9c)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ));
  }

  Padding buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // const Image(
              //   image: AssetImage("./assets/images/reef.png"),
              //   width: 24,
              //   height: 24,
              // ),
              const Gap(8),
              Text(
                "Send Tokens",
                style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w500,
                    fontSize: 32,
                    color: Colors.grey[800]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
