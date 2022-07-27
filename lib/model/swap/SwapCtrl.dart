import 'dart:convert';

import 'package:reef_mobile_app/model/swap/swap_settings.dart';
import 'package:reef_mobile_app/model/tokens/token_with_amount.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class SwapCtrl {
  final JsApiService jsApi;

  SwapCtrl(this.jsApi);

  Future<dynamic> swapTokens(String signerAddress, TokenWithAmount token1,
      TokenWithAmount token2, SwapSettings settings) async {
    return jsApi.jsPromise(
        'swap.execute("$signerAddress", ${jsonEncode(token1.toJson())}, ${jsonEncode(token2.toJson())}, ${jsonEncode(settings.toJson())})');
  }

  Future<dynamic> getPoolReserves(
      String signerAddress, String token1Address, String token2Address) async {
    return jsApi.jsPromise(
        'swap.getPoolReserves("$signerAddress", "$token1Address", "$token2Address")');
  }

  Future<dynamic> getSwapAmount(TokenWithAmount token, bool buy,
      TokenWithAmount token1Reserve, TokenWithAmount token2Reserve) {
    return jsApi.jsCall(
        'swap.getSwapAmount(${jsonEncode(token.toJson())}, $buy, ${jsonEncode(token1Reserve.toJson())}, ${jsonEncode(token2Reserve.toJson())})');
  }

  Future<dynamic> testSwapTokens(String signerAddress) async {
    TokenWithAmount token1 = TokenWithAmount(
        '0x0000000000000000000000000000000001000000', '10.000', 18);
    TokenWithAmount token2 = TokenWithAmount(
        '0x4676199AdA480a2fCB4b2D4232b7142AF9fe9D87', '4.2721', 18);
    SwapSettings settings = SwapSettings(1, 0.8);
    return swapTokens(signerAddress, token1, token2, settings);
  }

  Future<dynamic> testGetPoolReserves(String signerAddress) async {
    String token1Address = '0x0000000000000000000000000000000001000000';
    String token2Address = '0x4676199AdA480a2fCB4b2D4232b7142AF9fe9D87';
    return getPoolReserves(signerAddress, token1Address, token2Address);
  }

  Future<dynamic> testGetSwapAmount() async {
    // Buy 10 FTM with REEF
    TokenWithAmount token = TokenWithAmount(
        '0x0000000000000000000000000000000001000000', '10.000', 18);
    TokenWithAmount token1Reserves = TokenWithAmount(
        '0x0000000000000000000000000000000001000000', '311620000000000000000', 18);
    TokenWithAmount token2Reserves = TokenWithAmount(
        '0x4676199AdA480a2fCB4b2D4232b7142AF9fe9D87', '156388823265255224997', 18);
    return getSwapAmount(token, false, token1Reserves, token2Reserves);
  }
}
