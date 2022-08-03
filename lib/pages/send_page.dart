import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/components/modals/token_selection_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shimmer/shimmer.dart';

import '../components/SignatureContentToggle.dart';

//TODO: Complete the second box and add modal and button

class SendPage extends StatefulWidget {
  const SendPage({Key? key}) : super(key: key);

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  TextEditingController valueController = TextEditingController();
  String address = "";
  TextEditingController amountController = TextEditingController();
  String amount = "";

  Map selectedToken = {
    "name": "REEF",
    "address": REEF_TOKEN_ADDRESS,
    "logo": "https://s2.coinmarketcap.com/static/img/coins/64x64/6951.png",
    "balance": 4200.00,
    "decimals": 18,
  };

  void _changeSelectedToken(Map token) {
    setState(() {
      selectedToken = token;
    });
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
                              onPressed: () {},
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
                    const Gap(8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                          shadowColor: const Color(0x559d6cff),
                          elevation: 5,
                          primary: (address.isEmpty || amount.isEmpty)
                              ? const Color(0xff9d6cff)
                              : Styles.secondaryAccentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          if (address.isEmpty ||
                              amount.isEmpty ||
                              selectedToken['balance'] == 0) {
                            return;
                          }
                          var signerAddress = await ReefAppState
                              .instance.storage
                              .getValue(StorageKey.selected_address.name);
                          TokenWithAmount tokenToTranfer = TokenWithAmount(
                              name: selectedToken['name'],
                              address: selectedToken['address'],
                              iconUrl: selectedToken['logo'],
                              symbol: selectedToken['name'],
                              balance: BigInt.from(selectedToken['balance']),
                              decimals: selectedToken['decimals'],
                              amount: BigInt.parse(toStringWithoutDecimals(
                                  amount, selectedToken['decimals'])),
                              price: 1.0);
                          var res = await ReefAppState.instance.transferCtrl
                              .transferTokens(
                                  signerAddress, address, tokenToTranfer);
                          amountController.clear();
                          valueController.clear();
                          print('res = $res');
                        },
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
                ),
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
