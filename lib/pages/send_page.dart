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
  bool isTokenReef = false;
  String sendBtnVal = "Missing destination address";
  bool shouldSend = false;
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

    //checking if selected token is REEF or not
    if (widget.preselected ==
        "0x0000000000000000000000000000000001000000") {
      setState(() {
        isTokenReef=true;
      });
    }
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

  Future<bool> _addressValidator(String address) async {
    //checking if selected address is not evm
    if (address.startsWith("5")) {
      //if length of address == native address length
      if (address.length == 48) {
        String resolveEvmAddressResult;
        try {
          resolveEvmAddressResult = await ReefAppState.instance.accountCtrl
              .resolveEvmAddress(address);
          address = resolveEvmAddressResult;
          return true;
        } catch (e) {
          return false;
        }
      } else {
        return false;
      }
    } else if (address.startsWith("0")) {
      return await ReefAppState.instance.accountCtrl.isValidEvmAddress(address);
    }
    return false;
  }

  void _validator() async {
    bool addressValidatorResult = await _addressValidator(address);
    if (address.isEmpty) {
      setState(() {
        sendBtnVal = "Missing destination address";
      });
    } else if (amount.isEmpty || amount == "0.00") {
      setState(() {
        sendBtnVal = "Insert amount";
      });
    } else if (addressValidatorResult && amount.isNotEmpty) {
      setState(() {
        sendBtnVal = "Confirm Send";
      });
    } else {
      setState(() {
        sendBtnVal = "Enter a valid address";
      });
    }
  }

  void _onConfirmSend(TokenWithAmount sendToken) async {
    bool _send = true;
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
                              isTokenReef
                            );
                          },
                          color: const Color(0xffDFDAED),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          focusNode: _focus,
                          controller: valueController,
                          onChanged: (text) async {
                            setState(() {
                              address = valueController.text;
                            });
                            _validator();
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
                    onChanged: (newRating) async {
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

                      _validator();
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
                        gradient: (sendBtnVal == "Confirm Send")
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
                          sendBtnVal,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: (sendBtnVal != "Confirm Send")
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
