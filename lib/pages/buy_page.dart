import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/binance_connect/bc_pair.dart';
import 'package:reef_mobile_app/model/binance_connect/bc_trade_resp.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:http/http.dart' as http;

import '../components/SignatureContentToggle.dart';

const FIAT_NAME = 'USD';
const TOKEN_NAME = 'BUSD';

dynamic manageResponse(http.Response response) {
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    String errorMessage = 'An error occurred';
    try {
      var responseBody = jsonDecode(response.body);
      if (responseBody['name'] != null) {
        errorMessage = '${responseBody['name']}';
      }
    } catch (e) {}
    print(errorMessage);
    throw Exception(errorMessage);
  }
}

class BuyPage extends StatefulWidget {
  const BuyPage({Key? key}) : super(key: key);

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  @override
  void initState() {
    super.initState();
    getPairs();
  }

  String baseUrl = Constants.BINANCE_CONNECT_PROXY_URL;
  var disabled = false;
  late BcPair selectedPair;
  TokenWithAmount? reefToken = ReefAppState.instance.model.tokens.tokenList
      .firstWhere((token) => token.address == Constants.REEF_TOKEN_ADDRESS);

  TextEditingController amountFiatController = TextEditingController();
  TextEditingController amountReefController = TextEditingController();

  Future<void> _amountFiatUpdated(String value) async {}

  Future<void> _amountReefUpdated(String value) async {}

  void getPairs() async {
    http.Response response = await http.get(Uri.parse('$baseUrl/get-pairs'));
    List<dynamic> pairs =
        manageResponse(response).map((item) => BcPair.fromJson(item)).toList();
    pairs = pairs
        .where((pair) =>
            pair.fiatCurrency == FIAT_NAME && pair.cryptoCurrency == TOKEN_NAME)
        .toList();
    if (pairs.isNotEmpty) {
      setState(() {
        selectedPair = pairs.first;
      });
    }
  }

  Future<String> _authenticate(signerAddress) async {
    var signerAddress = await ReefAppState.instance.storage
        .getValue(StorageKey.selected_address.name);
    http.Response responseNonce =
        await http.get(Uri.parse('$baseUrl/auth/$signerAddress'));
    var resData = manageResponse(responseNonce);
    var message = resData['message'];
    var signed =
        await ReefAppState.instance.signingCtrl.signRaw(signerAddress, message);
    var signature = signed['signature'];
    print("signature: $signature");
    var body = {'address': signerAddress, 'signature': signature};
    http.Response responseAuth =
        await http.post(Uri.parse('$baseUrl/jwt'), body: body);
    var auth = manageResponse(responseAuth);
    if (auth['authenticated'] == true) {
      var jwt = auth['token'];
      await ReefAppState.instance.storage.saveJwt(signerAddress, jwt);
      print("jwt: $jwt");
      return jwt;
    } else {
      print("authentication failed");
      return "";
    }
  }

  void _buy() async {
    var signerAddress = await ReefAppState.instance.storage
        .getValue(StorageKey.selected_address.name);
    var jwt = await ReefAppState.instance.storage.getJwt(signerAddress);
    if (jwt == null) {
      jwt = await _authenticate(signerAddress);
      if (jwt == "") {
        return;
      }
    }
    var body = {
      'address': signerAddress,
      'fiatCurrency': FIAT_NAME,
      'orderAmount': amountFiatController.text,
    };
    var headers = {'Authorization': 'Bearer $jwt'};
    http.Response responseBuy = await http.post(Uri.parse('$baseUrl/buy'),
        body: body, headers: headers);
    BcTradeResp tradeResp = BcTradeResp.fromJson(manageResponse(responseBuy));
    print(tradeResp.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
      child: Column(
        children: [
          Text(
            "Buy REEF",
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
                              Row(
                                children: [
                                  const Image(
                                    image:
                                        AssetImage("./assets/images/USD.png"),
                                    width: 24,
                                    height: 24,
                                  ),
                                  const Gap(8),
                                  Text(
                                    "USD",
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 18,
                                        color: Styles.textColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[\.0-9]'))
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: amountFiatController,
                                  onChanged: (text) async {
                                    await _amountFiatUpdated(
                                        amountFiatController.text);
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
                              Row(
                                children: [
                                  const Image(
                                    image:
                                        AssetImage("./assets/images/reef.png"),
                                    width: 24,
                                    height: 24,
                                  ),
                                  const Gap(8),
                                  Text(
                                    "REEF",
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 18,
                                        color: Styles.textColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: TextField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[\.0-9]'))
                                    ],
                                    keyboardType: TextInputType.number,
                                    controller: amountReefController,
                                    onChanged: (text) async {
                                      await _amountReefUpdated(
                                          amountReefController.text);
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
                          backgroundColor: (disabled)
                              ? const Color(0xff9d6cff)
                              : Styles.secondaryAccentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (disabled) {
                            return;
                          }
                          _buy();
                        },
                        child: Text(
                          (disabled ? "Disabled" : "Buy"),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
        ],
      ),
    ));
  }
}
