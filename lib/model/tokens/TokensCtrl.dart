import 'package:reef_mobile_app/service/JsApiService.dart';

import 'token.dart';
import 'token_list.dart';

class TokenCtrl {

  final TokenList tokenList = TokenList();

  TokenCtrl(JsApiService jsApi){


    jsApi.jsObservable('appState.selectedSignerTokenBalances\$').listen((tokens) {
      var tkns = tokens.map(( t)=>t['symbol']);
      print('TKNS=${tkns}');
      List<Token> tknList = List.from(tkns.map((t)=>Token(t)));
      tokenList.setTokens(tknList);
    });
  }

}
