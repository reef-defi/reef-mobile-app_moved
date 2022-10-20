import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/binance_connect/bc_network.dart';
import 'package:reef_mobile_app/model/binance_connect/bc_pair.dart';
import 'package:reef_mobile_app/model/binance_connect/bc_trade_resp.dart';
import 'package:reef_mobile_app/utils/constants.dart';

import '../components/SignatureContentToggle.dart';

// TODO Page for testing. Delete after testing is done.

const FIAT_NAME = 'USD';
const TOKEN_NAME = 'BUSD';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String baseUrl = Constants.BINANCE_CONNECT_PROXY_URL;
  String address = '5EnY9eFwEDcEJ62dJWrTXhTucJ4pzGym4WZ2xcDKiT3eJecP';
  String signature = '';
  dynamic jwt = {};

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

  void ping() async {
    http.Response response = await http.get(Uri.parse(baseUrl));
    print(response.body);
  }

  void getNonce() async {
    http.Response response =
        await http.get(Uri.parse('$baseUrl/auth/$address'));
    var resData = manageResponse(response);
    var message = resData['message'];
    var signed =
        await ReefAppState.instance.signingCtrl.signRaw(address, message);
    signature = signed['signature'];
    print("signature: $signature");
  }

  void getJwt() async {
    var body = {'address': address, 'signature': signature};
    http.Response response =
        await http.post(Uri.parse('$baseUrl/jwt'), body: body);
    var auth = manageResponse(response);
    if (auth['authenticated'] == true) {
      jwt = auth['token'];
      print("jwt: $jwt");
    } else {
      print("authentication failed");
    }
  }

  void getNetwork() async {
    http.Response response = await http.get(Uri.parse('$baseUrl/get-network'));
    BcNetwork network = BcNetwork.fromJson(manageResponse(response));
    print(network.toJson());
  }

  void getPairs() async {
    http.Response response = await http.get(Uri.parse('$baseUrl/get-pairs'));
    List<dynamic> pairs =
        manageResponse(response).map((item) => BcPair.fromJson(item)).toList();
    pairs = pairs
        .where((pair) =>
            pair.fiatCurrency == FIAT_NAME && pair.cryptoCurrency == TOKEN_NAME)
        .toList();
    for (BcPair pair in pairs) {
      print(pair.toJson());
    }
  }

  void buy() async {
    var fiatCurrency = 'USD';
    var amount = 100;

    var body = {
      'address': address,
      'fiatCurrency': fiatCurrency,
      'orderAmount': amount.toString(),
    };
    var headers = {'Authorization': 'Bearer $jwt'};
    http.Response response = await http.post(Uri.parse('$baseUrl/buy'),
        body: body, headers: headers);
    BcTradeResp tradeResp = BcTradeResp.fromJson(manageResponse(response));
    print(tradeResp.toJson());
  }

  void getOrder() async {
    var internalOrderId = '123';

    http.Response response =
        await http.get(Uri.parse('$baseUrl/get-order/$internalOrderId'));
    var order = manageResponse(response);
    print(order);
  }

  void getTrades() async {
    var body = {'address': address};
    var headers = {'Authorization': 'Bearer $jwt'};
    http.Response response = await http.post(
        Uri.parse('$baseUrl/trades-by-user'),
        body: body,
        headers: headers);
    var resData = manageResponse(response);
    if (resData['error'] != null) {
      print(resData['error']);
      return;
    }
    print(resData);
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
      child: Column(
        children: [
          ElevatedButton(child: const Text('Ping'), onPressed: () => ping()),
          ElevatedButton(
              child: const Text('Get nonce'), onPressed: () => getNonce()),
          ElevatedButton(
              child: const Text('Get JWT'), onPressed: () => getJwt()),
          ElevatedButton(
              child: const Text('Get network'), onPressed: () => getNetwork()),
          ElevatedButton(
              child: const Text('Get pairs'), onPressed: () => getPairs()),
          ElevatedButton(child: const Text('Buy'), onPressed: () => buy()),
          ElevatedButton(
              child: const Text('Get order'), onPressed: () => getOrder()),
          ElevatedButton(
              child: const Text('Get trades'), onPressed: () => getTrades()),
        ],
      ),
    ));
  }
}
