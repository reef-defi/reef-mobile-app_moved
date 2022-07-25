import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

import 'token_list.dart';

class TokenCtrl {

  final TokenModel tokenModel = TokenModel();

  TokenCtrl(JsApiService jsApi){

    jsApi.jsObservable('appState.selectedSignerTokenBalances\$').listen((tokens) {
      var tkns = tokens?.map(( t)=>t['symbol']);
      if(tkns==null) {
        return;
      }
      List<TokenWithAmount> tknList = List.from(tkns.map((t)=>TokenWithAmount.fromJSON(t)));
      tokenModel.setTokens(tknList);
    });

  }

}
