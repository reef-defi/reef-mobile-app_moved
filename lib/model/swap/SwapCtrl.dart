import 'dart:convert';

import 'package:reef_mobile_app/model/swap/swap_settings.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class SwapCtrl {
  final JsApiService jsApi;

  SwapCtrl(this.jsApi);

  Future<dynamic> swapTokens(String signerAddress, TokenWithAmount token1,
      TokenWithAmount token2, SwapSettings settings) async {
    var mappedToken1 = {
      'address': token1.address,
      'decimals': token1.decimals,
      'amount': token1.getAmountDisplay(decimalPositions: token1.decimals),
    };
    var mappedToken2 = {
      'address': token2.address,
      'decimals': token2.decimals,
      'amount': token2.getAmountDisplay(decimalPositions: token2.decimals),
    };
    return jsApi.jsPromise(
        'swap.execute("$signerAddress", ${jsonEncode(mappedToken1)}, ${jsonEncode(mappedToken2)}, ${jsonEncode(settings.toJson())})');
  }

  Future<dynamic> getPoolReserves(
      String token1Address, String token2Address) async {
    return jsApi
        .jsPromise('swap.getPoolReserves("$token1Address", "$token2Address")');
  }

  dynamic getSwapAmount(String tokenAmount, bool buy,
      TokenWithAmount token1Reserve, TokenWithAmount token2Reserve) {
    return jsApi.jsCall(
        'swap.getSwapAmount($tokenAmount, $buy, ${jsonEncode(token1Reserve.toJsonSkinny())}, ${jsonEncode(token2Reserve.toJsonSkinny())})');
  }
}
