import 'package:reef_mobile_app/service/JsApiService.dart';

import 'token.dart';
import 'token_list.dart';

class TokenCtrl {
  // TODO: rename lists
  final TokenList tokenList = TokenList();
  // TODO: change to observable ?
  final List<Token> allTokens = [];

  TokenCtrl(JsApiService jsApi) {
    jsApi
        .jsObservable('appState.selectedSignerTokenBalances\$')
        .listen((tokens) {
      var tkns = tokens?.map((t) => tokenFromJson(t));
      if (tkns == null) {
        return;
      }
      List<Token> tknList = List.from(tkns);
      tokenList.setTokens(tknList);
    });

    // TODO get real list with all available tokens
    allTokens.add(Token(
      'REEF',
      '0x0000000000000000000000000000000001000000',
      'https://s2.coinmarketcap.com/static/img/coins/64x64/6951.png',
      'REEF',
      '1542087625938626180855',
      18
    ));
    allTokens.add(Token(
      'Free Mint Token"',
      '0x4676199AdA480a2fCB4b2D4232b7142AF9fe9D87',
      '',
      'FMT',
      '2761008739220176308876',
      18
    ));
    allTokens.add(Token(
      'Reef To Moon"',
      '0x06E346efDfB45ECe8e2F17Baef9a9d7aCF2f3653',
      '',
      'RTM',
      '0',
      18
    ));
  }
}
