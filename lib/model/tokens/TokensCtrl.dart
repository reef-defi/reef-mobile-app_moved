import 'package:reef_mobile_app/model/feedback-data-model/FeedbackDataModel.dart';
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
    jsApi
        .jsObservable('window.reefState.selectedTokenPrices\$')
        .listen((tokens) {
      ParseListFn<FeedbackDataModel<TokenWithAmount>> parsableListFn =
          getParsableListFn(TokenWithAmount.fromJson);
      var tokensListFdm =
          FeedbackDataModel.fromJsonList(tokens, parsableListFn);

      print(
          'GOT TOKENS ${tokensListFdm.statusList.map((e) => e.code)} msg = ${tokensListFdm.statusList[0].message}');
      tokenModel.setSelectedAccountTokens(tokensListFdm);
    });

    jsApi.jsObservable('window.reefState.selectedNFTs\$').listen((tokens) {
      print('TODOOOOO');
      return;
      if (tokens == null) {
        return;
      }
      List<TokenNFT> tknList =
          List.from(tokens.map((t) => TokenNFT.fromJSON(t)));
      tokenModel.setSelectedSignerNFTs(tknList);
    });

    jsApi.jsObservable('window.tokenUtil.reefPrice\$').listen((value) {
      var fdm = FeedbackDataModel.fromJson(value, (v) => v);
      if (fdm != null && fdm.hasStatus(StatusCode.completeData)) {
        print('TODOOOOOO');
        // tokenModel.setReefPrice(fdm.data+.0);
      }
    });

    jsApi
        .jsObservable('reefState.selectedTransactionHistory\$')
        .listen((items) {
      print('TODOOOOO');
      return;
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
