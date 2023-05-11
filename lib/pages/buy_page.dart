import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:reef_mobile_app/components/modals/alert_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/binance_connect/bc_pair.dart';
import 'package:reef_mobile_app/model/binance_connect/bc_trade_resp.dart';
import 'package:reef_mobile_app/model/network/NetworkCtrl.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/sign/SignatureContentToggle.dart';

const FIAT_NAME = 'USD';
const TOKEN_NAME = 'BUSD'; // TODO change to REEF

enum TradeState { pending, requested, redirected }

class BuyPage extends StatefulWidget {
  const BuyPage({Key? key}) : super(key: key);

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  @override
  void initState() {
    super.initState();
    network = ReefAppState.instance.model.network.selectedNetworkName;
    if (network == Network.mainnet.name) {
      _getPairs();
    }
  }

  late String? network;
  String baseUrl = Constants.BINANCE_CONNECT_PROXY_URL;
  BcPair selectedPair = BcPair(cryptoCurrency: '', fiatCurrency: '');
  num fiatAmount = 0;
  dynamic tradeResp;
  TradeState tradeState = TradeState.pending;
  String orderStatus = '';

  TextEditingController amountFiatController = TextEditingController();
  TextEditingController amountReefController = TextEditingController();

  dynamic manageResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'An error occurred';
      try {
        var responseBody = jsonDecode(response.body);
        if (responseBody['metaData'] != null) {
          errorMessage = '${responseBody['metaData']}';
        } else if (responseBody['name'] != null) {
          errorMessage = '${responseBody['name']}';
        }
      } catch (e) {}
      throw Exception(errorMessage);
    }
  }

  Future<void> _amountFiatUpdated(String value) async {
    if (value.isEmpty) {
      amountReefController.text = '';
      setState(() {
        fiatAmount = 0;
      });
      return;
    }

    setState(() {
      fiatAmount = num.parse(value);
    });
    var reefAmount = fiatAmount / selectedPair.quotation!;
    amountReefController.text = reefAmount.toStringAsFixed(2);
  }

  Future<void> _amountReefUpdated(String value) async {
    if (value.isEmpty) {
      amountFiatController.text = '';
      setState(() {
        fiatAmount = 0;
      });
      return;
    }

    var reefAmount = num.parse(value);
    setState(() {
      fiatAmount = reefAmount * selectedPair.quotation!;
    });
    amountFiatController.text = fiatAmount.toStringAsFixed(2);
  }

  // TODO: Once we have access to prod API, check if REEF network max and min withdrawal amounts
  // are in the range of trade limits. If so, we have to request network for withdrawal limits
  // void _getNetwork() async {
  //   http.Response response = await http.get(Uri.parse('$baseUrl/get-network'));
  //   tradeNetwork = BcNetwork.fromJson(manageResponse(response));
  //   print(tradeNetwork);
  // }

  void _getPairs() async {
    try {
      http.Response response = await http.get(Uri.parse('$baseUrl/get-pairs'));
      List<dynamic> pairs = manageResponse(response)
          .map((item) => BcPair.fromJson(item))
          .toList();
      pairs = pairs
          .where((pair) =>
              pair.fiatCurrency == FIAT_NAME &&
              pair.cryptoCurrency == TOKEN_NAME)
          .toList();
      if (pairs.isNotEmpty) {
        setState(() {
          selectedPair = pairs.first;
          if (selectedPair.quotation == null) {
            var reefPrice = ReefAppState.instance.model.tokens.reefPrice;
            if (reefPrice != null) {
              selectedPair.quotation = reefPrice;
            } else {
              showAlertModal("Error", ["An error occurred"], context: context);
              throw Exception('No quotation found');
            }
          }
          selectedPair.minLimit ??= 0;
          selectedPair.maxLimit ??= 20000;
        });
      } else {
        showAlertModal("Error", ["An error occurred"], context: context);
        throw Exception('No pairs found');
      }
    } catch (e) {
      showAlertModal("Error", ["An error occurred"], context: context);
      throw Exception('Error getting pairs');
    }
  }

  Future<String> _authenticate() async {
    try {
      var signerAddress = await ReefAppState.instance.storageCtrl
          .getValue(StorageKey.selected_address.name);
      http.Response responseNonce =
          await http.get(Uri.parse('$baseUrl/auth/$signerAddress'));
      var resData = manageResponse(responseNonce);
      var message = resData['message'];
      var signed = await ReefAppState.instance.signingCtrl
          .signRaw(signerAddress, message);
      var signature = signed['signature'];
      var body = {'address': signerAddress, 'signature': signature};
      http.Response responseAuth =
          await http.post(Uri.parse('$baseUrl/jwt'), body: body);
      var auth = manageResponse(responseAuth);
      if (auth['authenticated'] == true) {
        var jwt = auth['token'];
        await ReefAppState.instance.storageCtrl.saveJwt(signerAddress, jwt);
        return jwt;
      } else {
        showAlertModal("Error", ["Authentication failed"], context: context);
        throw Exception('Authentication failed');
      }
    } catch (e) {
      showAlertModal("Error", ["Authentication failed"], context: context);
      throw Exception('Authentication failed');
    }
  }

  void _buy() async {
    var signerAddress = await ReefAppState.instance.storageCtrl
        .getValue(StorageKey.selected_address.name);
    var jwt = await ReefAppState.instance.storageCtrl.getJwt(signerAddress);
    if (jwt == null) {
      jwt = await _authenticate();
      if (jwt == "") {
        return;
      }
    }
    var body = {
      'address': signerAddress,
      'fiatCurrency': FIAT_NAME,
      'orderAmount': num.parse(amountFiatController.text).toStringAsFixed(2),
    };
    var headers = {'Authorization': 'Bearer $jwt'};

    try {
      http.Response responseBuy = await http.post(Uri.parse('$baseUrl/buy'),
          body: body, headers: headers);
      var tradeRespRaw = manageResponse(responseBuy);
      if (tradeRespRaw['status'] == 401) {
        await ReefAppState.instance.storage.saveJwt(signerAddress, jwt);
        _buy();
      } else {
        tradeResp = BcTradeResp.fromJson(tradeRespRaw);
        print(tradeResp.toJson());
        setState(() {
          tradeState = TradeState.requested;
        });
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('TokenExpiredError')) {
        await ReefAppState.instance.storageCtrl.deleteJwt(signerAddress);
        await _authenticate();
        _buy();
      } else {
        showAlertModal("Error", ["An error occurred"], context: context);
        throw Exception('Error buying');
      }
    }
  }

  void _navigateBinanceConnect() {
    launchUrl(Uri.parse(tradeResp.eternalRedirectUrl));
    fiatAmount = 0;
    amountFiatController.text = '';
    amountReefController.text = '';

    Timer(
        const Duration(seconds: 2),
        () => setState(() {
              tradeState = TradeState.redirected;
            }));
  }

  void _getOrder() async {
    var _orderStatus = "unknown";
    try {
      http.Response response = await http
          .get(Uri.parse('$baseUrl/get-order/${tradeResp.internalOrderId}'));
      var order = manageResponse(response);
      if (order.isNotEmpty) {
        _orderStatus = order[0]["orderMainStatus"];
      }
    } catch (e) {
      print("Error getting status order: ${e.toString()}");
    }
    setState(() {
      orderStatus = _orderStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (network == Network.mainnet.name) {
      return buildBuy(context);
    }
    if (network == Network.testnet.name) {
      return buildTestnetReef(context);
    }
    return const CircularProgressIndicator();
  }

  Widget buildBuy(BuildContext context) {
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
          if (tradeState == TradeState.pending)
            buildForm(context)
          else if (tradeState == TradeState.requested)
            buildRedirect(context)
          else
            buildRedirected(context)
        ],
      ),
    ));
  }

  Widget buildRedirect(BuildContext context) {
    return Column(
      children: [
        Text(
          "Complete your purchase on Binance Connect.",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        const Gap(24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              shadowColor: const Color(0x559d6cff),
              elevation: 5,
              backgroundColor: Styles.secondaryAccentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              _navigateBinanceConnect();
            },
            child: Text(
              AppLocalizations.of(context)!.go_to_binance,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRedirected(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.completed_binance_purchase,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        const Gap(24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              shadowColor: const Color(0x559d6cff),
              elevation: 5,
              backgroundColor: Styles.secondaryAccentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              _getOrder();
            },
            child: Text(
              AppLocalizations.of(context)!.scan_address,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (orderStatus.isNotEmpty) ...[
          const Gap(16),
          Text(
            "Order status: $orderStatus",
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
        const Gap(24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              shadowColor: const Color(0x559d6cff),
              elevation: 5,
              backgroundColor: Styles.secondaryAccentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              tradeResp = null;
              orderStatus = '';
              setState(() {
                tradeState = TradeState.pending;
              });
            },
            child: Text(
              AppLocalizations.of(context)!.create_purchase,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildForm(BuildContext context) {
    return Stack(
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
                              image: AssetImage("./assets/images/USD.png"),
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
                              image: AssetImage("./assets/images/reef.png"),
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
                              textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(8),
              if (selectedPair.cryptoCurrency.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                      shadowColor: const Color(0x559d6cff),
                      elevation: 5,
                      backgroundColor: fiatAmount < selectedPair.minLimit! ||
                              fiatAmount > selectedPair.maxLimit!
                          ? const Color(0xff9d6cff)
                          : Styles.secondaryAccentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (fiatAmount < selectedPair.minLimit! ||
                          fiatAmount > selectedPair.maxLimit!) {
                        return;
                      }
                      _buy();
                    },
                    child: Text(
                      (fiatAmount < selectedPair.minLimit!
                          ? "Minimum amount is ${selectedPair.minLimit} USD"
                          : fiatAmount > selectedPair.maxLimit!
                              ? "Maximum amount is ${selectedPair.maxLimit} USD"
                              : "Buy"),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Text(AppLocalizations.of(context)!.approximate_reef),
              ]
            ],
          ),
        ]);
  }

  Widget buildTestnetReef(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
      child: Column(
        children: [
          Text(
            "Get testnet REEF",
            style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w500,
                fontSize: 24,
                color: Colors.grey[800]),
          ),
          const Gap(24),
          RichText(
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Styles.textColor),
              children: [
                const TextSpan(
                  text: 'To get 1000 REEF testnet tokens type ',
                ),
                const TextSpan(
                  text: '!drip <YOUR_ADDRESS>',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const TextSpan(
                  text: ' in ',
                ),
                TextSpan(
                  text: 'Reef matrix chat',
                  style: TextStyle(color: Styles.primaryAccentColorDark),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse(
                          'https://app.element.io/#/room/#reef:matrix.org'));
                    },
                ),
                const TextSpan(
                  text: '.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
