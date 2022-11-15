import 'package:reef_mobile_app/model/tokens/Token.dart';
import 'package:reef_mobile_app/model/tokens/TokenActivity.dart';
import 'package:reef_mobile_app/model/tokens/TokenNFT.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/utils/constants.dart';

import 'token_model.dart';

class TokenCtrl {
  final JsApiService jsApi;

  TokenCtrl(this.jsApi, TokenModel tokenModel) {
    jsApi.jsObservable('window.appState.tokenPrices\$').listen((tokens) {
      if (tokens == null) {
        return;
      }
      List<TokenWithAmount> tknList =
          List.from(tokens.map((t) => TokenWithAmount.fromJSON(t)));
      tokenModel.setSelectedSignerTokens(tknList);
    });

    jsApi.jsObservable('window.appState.selectedSignerNFTs\$').listen((tokens) {
      if (tokens == null) {
        return;
      }
      List<TokenNFT> tknList =
          List.from(tokens.map((t) => TokenNFT.fromJSON(t)));
      tokenModel.setSelectedSignerNFTs(tknList);
    });

    jsApi.jsObservable('window.appState.reefPrice\$').listen((value) {
      if (value == null) {
        return;
      }
      tokenModel.setReefPrice(value);
    });

    jsApi.jsObservable('window.appState.transferHistory\$').listen((items) {
      if (items == null) {
        return;
      }
      List<TokenActivity> tknList =
          List.from(items.map((i) => TokenActivity.fromJSON(i)));
      tokenModel.setTokenActivity(tknList);
    });
  }

  Future<dynamic> findToken(String address) async {
    return jsApi.jsPromise('window.utils.findToken("$address")');
  }
}
