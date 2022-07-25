import 'dart:convert';

import 'package:reef_mobile_app/model/swap/swap_settings.dart';
import 'package:reef_mobile_app/model/tokens/token_with_amount.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class SwapCtrl {
  final JsApiService jsApi;

  SwapCtrl(this.jsApi);

  Future<dynamic> swapTokens(String signerAddress, TokenWithAmount token1, TokenWithAmount token2, SwapSettings settings) async {
    return jsApi.jsPromise(
      'swap.send("$signerAddress", ${jsonEncode(token1.toJson())}, ${jsonEncode(token2.toJson())}, ${jsonEncode(settings.toJson())})');
  }

  Future<dynamic> testSwapTokens(String signerAddress) async {
    TokenWithAmount token1 = TokenWithAmount('0x0000000000000000000000000000000001000000', '10.000', 18);
    TokenWithAmount token2 = TokenWithAmount('0x4676199AdA480a2fCB4b2D4232b7142AF9fe9D87', '5.2721', 18);
    SwapSettings settings = SwapSettings(1, 0.8);
    return swapTokens(signerAddress, token1, token2, settings);
  }
}
