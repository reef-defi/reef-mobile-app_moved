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
      tokenModel.setSelectedErc20s(tokensListFdm);
    });

    jsApi.jsObservable('window.reefState.selectedNFTs\$').listen((tokens) {
      ParseListFn<FeedbackDataModel<TokenNFT>> parsableListFn =
      getParsableListFn(TokenNFT.fromJson);
      var tokensListFdm =
      FeedbackDataModel.fromJsonList(tokens, parsableListFn);
      print('GOT NFTS ${tokensListFdm.statusList}');
      tokenModel.setSelectedNFTs(tokensListFdm);
    });

    jsApi.jsObservable('window.tokenUtil.reefPrice\$').listen((value) {
      var fdm = FeedbackDataModel.fromJson(value, (v) => v);
      if (fdm != null && fdm.hasStatus(StatusCode.completeData)) {
        if(fdm.data is int){
          fdm.data = (fdm.data as int).toDouble();
        }

        tokenModel.setReefPrice(fdm.data);
      }
    });

    jsApi
        .jsObservable('window.reefState.selectedTransactionHistory\$')
        .listen((items) {
      var parsableFn =
          (accList) => List<TokenActivity>.from(accList.map(TokenActivity.fromJSON));
      var tokensListFdm =
      FeedbackDataModel.fromJsonList(items, parsableFn);

      tokenModel.setTxHistory(tokensListFdm);
      print('GOT HISTORY=${tokensListFdm.data.length}');
    });
  }

  Future<dynamic> findToken(String address) async {
    return jsApi.jsPromise('window.utils.findToken("$address")');
  }
}
