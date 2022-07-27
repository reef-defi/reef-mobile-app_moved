import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

import 'token_model.dart';

class TokenCtrl {

  TokenCtrl(JsApiService jsApi, TokenModel tokenModel){

    jsApi.jsObservable('appState.tokenPrices\$').listen((tokens) {
      if(tokens==null) {
        return;
      }
      List<TokenWithAmount> tknList = List.from(tokens.map((t)=>TokenWithAmount.fromJSON(t)));
      tokenModel.setTokens(tknList);
    });

  }

}
