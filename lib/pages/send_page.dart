import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modals/select_account_modal.dart';
import 'package:reef_mobile_app/components/modals/token_selection_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import '../components/SignatureContentToggle.dart';

class SendPage extends StatefulWidget {
  final String preselected;
  const SendPage(this.preselected, {Key? key}) : super(key: key);

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  TextEditingController valueController = TextEditingController();
  String address = "";
  TextEditingController amountController = TextEditingController();
  String amount = "";

  late String selectedTokenAddress;

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedTokenAddress = widget.preselected;
    });
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
    TokenWithAmount tokenToTranfer = TokenWithAmount(
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
        .transferTokens(signerAddress, address, tokenToTranfer);
    amountController.clear();
    valueController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
      child: Column(
        children: [
          Text(
            "Send Tokens",
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
                Observer(builder: (_) {
                  var tokens =
                      ReefAppState.instance.model.tokens.selectedSignerTokens;
                  var selectedToken = tokens
                      .firstWhere((tkn) => tkn.address == selectedTokenAddress);
                  if (selectedToken == null && !tokens.isEmpty) {
                    selectedToken = tokens[0];
                  }
                  return Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffe1e2e8)),
                          borderRadius: BorderRadius.circular(12),
                          color: Styles.boxBackgroundColor,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: valueController,
                                onChanged: (text) {
                                  setState(() {
                                    //you can access nameController in its scope to get
                                    // the value of text entered as shown below
                                    address = valueController.text;
                                  });
                                },
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 2),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          topLeft: Radius.circular(10)),
                                      borderSide:
                                          BorderSide(color: Color(0xffd1d2d8)),
                                    ),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          topLeft: Radius.circular(10)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          topLeft: Radius.circular(10)),
                                      borderSide: BorderSide(
                                          color: Styles.secondaryAccentColor,
                                          width: 2),
                                    ),
                                    hintText: 'Send to address',
                                    hintStyle: TextStyle(
                                        color: Styles.textLightColor)),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Address cannot be empty';
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
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10),
                                      topRight: Radius.circular(10)),
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
                                color: Styles.buttonColor,
                                child: const Icon(
                                  CupertinoIcons.chevron_down,
                                  color: Colors.white,
                                  size: 18,
                                ),
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
                                        callback: (tkn) =>
                                            _changeSelectedToken(tkn.address));
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
                                      IconFromUrl(selectedToken.iconUrl),
                                      const Gap(4),
                                      Text(selectedToken != null
                                          ? selectedToken.name
                                          : 'Select'),
                                      const Gap(4),
                                      Icon(CupertinoIcons.chevron_down,
                                          size: 16,
                                          color: Styles.textLightColor)
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
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
                            const Gap(8),
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Text(
                                    "Balance: ${toAmountDisplayBigInt(selectedToken.balance)} ${selectedToken.name.toUpperCase()}",
                                    style: TextStyle(
                                        color: Styles.textLightColor,
                                        fontSize: 12),
                                  ),
                                  /*TextButton(
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
                                      ))*/
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
                            backgroundColor: (address.isEmpty || amount.isEmpty)
                                ? const Color(0xff9d6cff)
                                : Styles.secondaryAccentColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => _onConfirmSend(selectedToken),
                          child: Text(
                            address.isEmpty
                                ? 'Missing destination address'
                                : amount.isEmpty
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
                  );
                }),
                Positioned(
                  top: 86,
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
                    child: Icon(CupertinoIcons.plus,
                        size: 12, color: Styles.textLightColor),
                  ),
                ),
              ]),
        ],
      ),
    ));
  }
}
