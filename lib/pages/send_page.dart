import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reef_mobile_app/components/modals/qr_code_scanner.dart';
import 'package:reef_mobile_app/components/modals/select_account_modal.dart';
import 'package:reef_mobile_app/components/send/custom_stepper.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class SendPage extends StatefulWidget {
  final String preselected; 

  const SendPage(this.preselected, {Key? key}) : super(key: key);

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  bool isTokenReef = false;
  SendStatus statusValue = SendStatus.NO_ADDRESS;
  TextEditingController valueController = TextEditingController();
  String address = "";
  String? resolvedEvmAddress;
  TextEditingController amountController = TextEditingController();
  String amount = "";

  late String selectedTokenAddress;
  bool _isValueEditing = false;
  bool _isValueSecondEditing = false;
  double rating = 0;

  final FocusNode _focus = FocusNode();
  final FocusNode _focusSecond = FocusNode();

  bool isFormDisabled = false;

  dynamic transactionData;

  @override
  void initState() {
    super.initState();

    _focus.addListener(_onFocusChange);
    _focusSecond.addListener(_onFocusSecondChange);
    setState(() {
      selectedTokenAddress = widget.preselected;
    });

    //checking if selected token is REEF or not
    if (widget.preselected == Constants.REEF_TOKEN_ADDRESS) {
      setState(() {
        isTokenReef = true;
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

  /*void _changeSelectedToken(String tokenAddr) {
    setState(() {
      selectedTokenAddress = tokenAddr;
    });
  }*/

  Future<bool> _isValidAddress(String address) async {
    //checking if selected address is not evm
    if (address.startsWith("5")) {
      //if length of address == native address length
      print("verifying for substrate addr");
      return true;
    } else if (address.startsWith("0x")) {
      print("verifying for evm addr");
      return await ReefAppState.instance.accountCtrl.isValidEvmAddress(address);
    }
    return false;
  }

  Future<SendStatus> _validate(String addr, TokenWithAmount token, String amt,
      [bool skipAsync = false]) async {
    var isValidAddr = await _isValidAddress(addr);
    var balance = getSelectedTokenBalance(token);
    if (amt == '') {
      amt = '0';
    }
    var amtVal = double.parse(amt);
    if (addr.isEmpty) {
      return SendStatus.NO_ADDRESS;
    } else if (amtVal <= 0) {
      return SendStatus.NO_AMT;
    } else if (amtVal > getMaxTransferAmount(token, balance)) {
      return SendStatus.AMT_TOO_HIGH;
    } else if (isValidAddr &&
        token.address != Constants.REEF_TOKEN_ADDRESS &&
        !addr.startsWith('0x')) {
      try {
        if (skipAsync == false) {
          resolvedEvmAddress =
              await ReefAppState.instance.accountCtrl.resolveEvmAddress(addr);
        }
      } catch (e) {
        resolvedEvmAddress = null;
      }
      if (resolvedEvmAddress == null) {
        return SendStatus.NO_EVM_CONNECTED;
      }
    } else if (!isValidAddr) {
      return SendStatus.ADDR_NOT_VALID;
    } else if (skipAsync == false &&
        addr.startsWith('0x') &&
        !(await ReefAppState.instance.accountCtrl.isEvmAddressExist(addr))) {
      return SendStatus.ADDR_NOT_EXIST;
    }
    return SendStatus.READY;
  }

  Future<void> _onConfirmSend(TokenWithAmount sendToken) async {
    if (address.isEmpty ||
        sendToken.balance <= BigInt.zero ||
        statusValue != SendStatus.READY) {
      return;
    }
    setState(() {
      isFormDisabled = true;
      statusValue = SendStatus.SIGNING;
    });

    setStatusOnSignatureClosed();

    Stream<dynamic> transferTransactionFeedbackStream =
        await executeTransferTransaction(sendToken);

    transferTransactionFeedbackStream =
        transferTransactionFeedbackStream.asBroadcastStream();

    transferTransactionFeedbackStream.listen((txResponse) {
      print('TRANSACTION RESPONSE=$txResponse');
      if (handleExceptionResponse(txResponse)) {
        return;
      }
      if (handleNativeTransferResponse(txResponse)) {
        return;
      }
      if (handleEvmTransactionResponse(txResponse)) {
        return;
      }
    });
  }

  Future<Stream<dynamic>> executeTransferTransaction(
      TokenWithAmount sendToken) async {
    final signerAddress = await ReefAppState.instance.storageCtrl
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

    var toAddress = resolvedEvmAddress ?? address;
    return ReefAppState.instance.transferCtrl
        .transferTokensStream(signerAddress, toAddress, tokenToTransfer);
  }

  void setStatusOnSignatureClosed() {
    when(
        (p0) =>
            ReefAppState.instance.signingCtrl.signatureRequests.list.isNotEmpty,
        () {
      // NEW SIGNATURE DISPLAYED
      when(
          (p0) =>
              ReefAppState.instance.signingCtrl.signatureRequests.list.isEmpty,
          () {
        print('REMOVED SIGN DISPLAY');
        setState(() {
          statusValue = SendStatus.SENDING;
        });
      });
    });
  }

  bool handleExceptionResponse(txResponse) {
    if (txResponse == null || txResponse['success'] != true) {
      setState(() {
        statusValue = txResponse['data'] == '_canceled'
            ? SendStatus.CANCELED
            : SendStatus.ERROR;
      });
      return true;
    }
    return false;
  }

  bool handleEvmTransactionResponse(txResponse) {
    if (txResponse['type'] == 'reef20') {
      if (txResponse['data']['status'] == 'broadcast') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.SENT_TO_NETWORK;
        });
      }
      if (txResponse['data']['status'] == 'included-in-block') {
        setState(() {
          transactionData = txResponse['data'];
          print('TRANSSSSSS $transactionData');
          statusValue = SendStatus.INCLUDED_IN_BLOCK;
        });
      }
      if (txResponse['data']['status'] == 'finalized') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.FINALIZED;
        });
      }
      if (txResponse['data']['status'] == 'not-finalized') {
        print('block was not finalized');
        setState(() {
          statusValue = SendStatus.NOT_FINALIZED;
        });
      }
      return true;
    }
    return false;
  }

  bool handleNativeTransferResponse(txResponse) {
    if (txResponse['type'] == 'native') {
      if (txResponse['data']['status'] == 'broadcast') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.SENT_TO_NETWORK;
        });
      }
      if (txResponse['data']['status'] == 'included-in-block') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.INCLUDED_IN_BLOCK;
        });
      }
      if (txResponse['data']['status'] == 'finalized') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.FINALIZED;
        });
      }
      return true;
    }
    return false;
  }

  void resetState() {
    amountController.clear();
    valueController.clear();
    setState(() {
      amount = '';
      resolvedEvmAddress = null;
      transactionData = null;
      address = '';
      rating = 0;
      isFormDisabled = false;
      statusValue = SendStatus.NO_ADDRESS;
      transactionData = null;
    });
  }

  getSendBtnLabel(SendStatus validation) {
    switch (validation) {
      case SendStatus.NO_ADDRESS:
        return "Missing destination address";
      case SendStatus.NO_AMT:
        return "Insert amount";
      case SendStatus.AMT_TOO_HIGH:
        return "Amount too high";
      case SendStatus.NO_EVM_CONNECTED:
        return "Target not EVM";
      case SendStatus.ADDR_NOT_VALID:
        return "Enter a valid address";
      case SendStatus.ADDR_NOT_EXIST:
        return "Unknown address";
      case SendStatus.SIGNING:
        return "Signing transaction ...";
      case SendStatus.SENDING:
        return "Sending ...";
      case SendStatus.READY:
        return "Confirm Send";
      default:
        return "Not Valid";
    }
  }

  @override
  Widget build(BuildContext context) {
    var transferStatusUI =
        buildFeedbackUI(context, statusValue, resetState, () {
      final navigator = Navigator.of(context);
      navigator.pop();
      // ReefAppState.instance.navigationCtrl.navigate(NavigationPage.home);
    });
    return transferStatusUI ??
        Column(
          children: [
            // Gap(16),
            Observer(builder: (_) {
              var tokens = ReefAppState.instance.model.tokens.selectedErc20List;
              var selectedToken = tokens
                  .firstWhere((tkn) => tkn.address == selectedTokenAddress);
              if (selectedToken == null && !tokens.isEmpty) {
                selectedToken = tokens[0];
              }
              if (selectedToken == null) {
                return Text(AppLocalizations.of(context)!.no_token_selected);
              }
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Styles.primaryBackgroundColor,
                    boxShadow: neumorphicShadow()),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: <Widget>[
                    ...buildInputElements(selectedToken),
                    const Gap(36),
                    ...buildSliderWidgets(selectedToken),
                    const Gap(36),
                    buildSendStatusButton(selectedToken),
                  ],
                ),
              );
            }),
          ],
        );
  }

  List<Widget> buildInputElements(TokenWithAmount selectedToken) {
    return [
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
                  if (isFormDisabled) {
                    return;
                  }
                  showSelectAccountModal(
                      AppLocalizations.of(context)!.select_address,
                      (selectedAddress) async {
                    setState(() {
                      address = selectedAddress.trim();
                      valueController.text = address;
                    });
                    var state = await _validate(address, selectedToken, amount);
                    setState(() {
                      statusValue = state;
                    });
                  }, isTokenReef);
                },
                //color: const Color(0xffDFDAED),
                child: RotatedBox(
                    quarterTurns: 1,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: isFormDisabled
                          ? Styles.textLightColor
                          : Styles.textColor,
                    )),
              ),
            ),
            Expanded(
              child: TextFormField(
                focusNode: _focus,
                readOnly: isFormDisabled,
                controller: valueController,
                onChanged: (text) async {
                  setState(() {
                    address = valueController.text.trim();
                  });

                  var state = await _validate(address, selectedToken, amount);
                  setState(() {
                    statusValue = state;
                  });
                },
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isFormDisabled
                        ? Styles.textLightColor
                        : Styles.textColor),
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    border: InputBorder.none,
                    hintText: AppLocalizations.of(context)!.send_to_address,
                    hintStyle: TextStyle(color: Styles.textLightColor)),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .address_can_not_be_empty;
                  }
                  return null;
                },
              ),
            ),
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
                    showQrCodeScannerModal(
                        AppLocalizations.of(context)!.scan_address,
                        (selectedAddress) async {
                      setState(() {
                        address = selectedAddress.trim();
                        valueController.text = address;
                      });
                    });
                  },
                  child: const Icon(
                    Icons.qr_code_scanner_sharp,
                    color: Styles.textColor,
                  )),
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
                          selectedToken != null ? selectedToken.name : 'Select',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: isFormDisabled
                                  ? Styles.textLightColor
                                  : Styles.darkBackgroundColor),
                        ),
                        Text(
                          "${toAmountDisplayBigInt(selectedToken.balance)} ${selectedToken.name.toUpperCase()}",
                          style: TextStyle(
                              color: Styles.textLightColor, fontSize: 12),
                        )
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: TextFormField(
                    focusNode: _focusSecond,
                    readOnly: isFormDisabled,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    keyboardType: TextInputType.number,
                    controller: amountController,
                    onChanged: (text) async {
                      amount = amountController.text;
                      var status =
                          await _validate(address, selectedToken, amount);
                      setState(() {
                        statusValue = status;
                        var balance = getSelectedTokenBalance(selectedToken);

                        var amt = amount != '' ? double.parse(amount) : 0;
                        var calcRating = (amt /
                            getMaxTransferAmount(selectedToken, balance));
                        if (calcRating < 0) {
                          calcRating = 0;
                        }
                        rating = calcRating > 1 ? 1 : calcRating;
                      });
                    },
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isFormDisabled
                            ? Styles.textLightColor
                            : Styles.textColor),
                    decoration: const InputDecoration(
                        constraints: BoxConstraints(maxHeight: 32),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        hintText: '0.0',
                        hintStyle: TextStyle(color: Styles.textLightColor)),
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
      )
    ];
  }

  List<Widget> buildSliderWidgets(TokenWithAmount selectedToken) {
    return [
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
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4),
            thumbShape: const ThumbShape()),
        child: Slider(
          value: rating,
          onChanged: isFormDisabled
              ? null
              : (newRating) async {
                  String amountStr = getSliderValues(newRating, selectedToken);
                  var status =
                      await _validate(address, selectedToken, amountStr, true);
                  setState(() {
                    amount = amountStr;
                    amountController.text = amountStr;
                    statusValue = status;
                  });
                },
          onChangeEnd: (newRating) async {
            String amountStr = getSliderValues(newRating, selectedToken);

            amount = amountStr;
            amountController.text = amountStr;
            var status = await _validate(address, selectedToken, amount);
            setState(() {
              statusValue = status;
            });
          },
          inactiveColor: Colors.white24,
          divisions: 100,
          label: "${(rating * 100).toInt()}%",
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
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
      )
    ];
  }

  SizedBox buildSendStatusButton(TokenWithAmount selectedToken) {
    return SizedBox(
      width: double.infinity,
      child: statusValue!=SendStatus.SIGNING?ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          shadowColor: const Color(0x559d6cff),
          elevation: 0,
          backgroundColor: (statusValue == SendStatus.READY)
              ? const Color(0xffe6e2f1)
              : Colors.transparent,
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () => {_onConfirmSend(selectedToken)},
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xffe6e2f1),
            gradient: (statusValue == SendStatus.READY)
                ? const LinearGradient(colors: [
                    Color(0xffae27a5),
                    Color(0xff742cb2),
                  ])
                : null,
            borderRadius: const BorderRadius.all(Radius.circular(14.0)),
          ),
          child: Center(
            child: Text(
              getSendBtnLabel(statusValue),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: (statusValue != SendStatus.READY)
                    ? const Color(0x65898e9c)
                    : Colors.white,
              ),
            ),
          ),
        ),
      )
      :Column(children: [
        Text('Generating Signature'),
        Gap(12),
        LinearProgressIndicator(
          valueColor:
          AlwaysStoppedAnimation<Color>(Styles.primaryAccentColor),
          backgroundColor: Styles.greyColor,
        )
      ],),
    );
  }

  String getSliderValues(double newRating, TokenWithAmount selectedToken) {
    rating = newRating;
    var balance = getSelectedTokenBalance(selectedToken);
    double? amountValue = (balance * rating);
    if (amountValue <= 0) {
      amountValue = null;
    }
    var maxTransferAmount = getMaxTransferAmount(selectedToken, balance);
    if (amountValue != null && amountValue > maxTransferAmount) {
      amountValue = maxTransferAmount;
    }

    var amountStr = amountValue?.toStringAsFixed(2) ?? '';
    return amountStr;
  }

  double getMaxTransferAmount(TokenWithAmount token, double balance) =>
      token.address == Constants.REEF_TOKEN_ADDRESS ? balance - 3 : balance;

  double getSelectedTokenBalance(TokenWithAmount selectedToken) {
    return double.parse(toAmountDisplayBigInt(selectedToken.balance));
  }

  buildFeedbackUI(BuildContext context, SendStatus stat, void Function() onNew,
      void Function() onHome) {
    int? index;

    if (stat == SendStatus.ERROR) {
      //index = 'Transaction Error';
    }
    if (stat == SendStatus.CANCELED) {
      //title = 'Transaction Canceled';
    }
    if (stat == SendStatus.SENDING) {
      index = 0;
    }
    if (stat == SendStatus.SENT_TO_NETWORK) {
      index = 1;
    }
    if (stat == SendStatus.INCLUDED_IN_BLOCK) {
      index = 2;
    }
    if (stat == SendStatus.FINALIZED) {
      index = 3;
    }

    if (stat == SendStatus.NOT_FINALIZED) {
      // title = 'NOT finalized!';
    }

    if (index == null) {
      return null;
    }

    return Container(
        margin: const EdgeInsets.only(top: 20),
        child: SingleChildScrollView(
          child: ReefStepper(
            currentStep: index,
            steps: steps(stat, index),
            controlsBuilder: (context, details) {
              if ((index ?? 0) >= 3) {
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Flex(
                      mainAxisAlignment: MainAxisAlignment.center,
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                        (states) => Colors.deepPurple)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Go Back to Homepage"),
                          ),
                        )
                      ],
                    ));
              }
              return Flex(
                direction: Axis.horizontal,
                children: const <Widget>[
                  Expanded(
                      child: SizedBox(
                    height: 0,
                  ))
                ],
              );
            },
          ),
        ));
  }

  List<ReefStep> steps(SendStatus stat, int index) => [
        ReefStep(
            state: getStepState(stat, 0, index),
            title: Text(
              'Sending Transaction',
              style: TextStyle(
                  fontSize: index == 0 ? 25 : 20,
                  color: Colors.purple.shade400),
            ),
            content: Padding(
              padding: const EdgeInsets.all(20),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                      child: Text(
                    "Sending Transaction to the network ...",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  )),
                ],
              ),
            )),
        ReefStep(
            state: getStepState(stat, 1, index),
            title: Text(
              'Transaction Sent',
              style: TextStyle(
                  fontSize: index == 1 ? 25 : 20,
                  color: Colors.purple.shade400),
            ),
            content: Padding(
              padding: const EdgeInsets.all(20),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                      child: Text(
                    "Waiting to be included in a Block...",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  )),
                ],
              ),
            )),
        ReefStep(
            state: getStepState(stat, 2, index),
            title: Text(
              'Transaction in Block',
              style: TextStyle(
                  fontSize: index == 2 ? 25 : 20,
                  color: Colors.purple.shade400),
            ),
            content: Padding(
              padding: const EdgeInsets.all(20),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Waiting for finalization...",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                ],
              ),
            )),
        ReefStep(
            state: getStepState(stat, 3, index),
            title: Text(
              'Transaction Success',
              style: TextStyle(
                  fontSize: index == 3 ? 25 : 20,
                  color: Colors.purple.shade400),
            ),
            content: const SizedBox()),
      ];

  ReefStepState getStepState(SendStatus stat, int stepIndex, int currentIndex) {
    switch (stat) {
      case SendStatus.FINALIZED:
        if (stepIndex == currentIndex) {
          return ReefStepState.complete;
        } else if (stepIndex < currentIndex) {
          return ReefStepState.complete;
        }
        break;
      case SendStatus.CANCELED:
        if (stepIndex == currentIndex) {
          return ReefStepState.error;
        }
        break;
      case SendStatus.ERROR:
        if (stepIndex == currentIndex) {
          return ReefStepState.error;
        }
        break;
      default:
        if (currentIndex == stepIndex) {
          return ReefStepState.indexed;
        } else if (stepIndex < currentIndex) {
          return ReefStepState.complete;
        }
    }
    return ReefStepState.indexed;
  }
}

enum SendStatus {
  READY,
  NO_EVM_CONNECTED,
  NO_ADDRESS,
  NO_AMT,
  AMT_TOO_HIGH,
  ADDR_NOT_VALID,
  ADDR_NOT_EXIST,
  SIGNING,
  SENDING,
  CANCELED,
  ERROR,
  SENT_TO_NETWORK,
  INCLUDED_IN_BLOCK,
  FINALIZED,
  NOT_FINALIZED,
}
