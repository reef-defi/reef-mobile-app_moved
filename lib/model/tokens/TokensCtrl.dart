import 'package:reef_mobile_app/model/tokens/TokenActivity.dart';
import 'package:reef_mobile_app/model/tokens/TokenNFT.dart';
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
      tokenModel.setSelectedSignerTokens(tknList);
    });

    jsApi.jsObservable('appState.selectedSignerNFTs\$').listen((tokens) {
      if(tokens==null) {
        return;
      }
      print('NFTs=${tokens}');
      List<TokenNFT> tknList = List.from(tokens.map((t)=>TokenNFT.fromJSON(t)));
      tokenModel.setSelectedSignerNFTs(tknList);
    });

    jsApi.jsObservable('appState.reefPrice\$').listen((value) {
      if(value==null) {
        return;
      }
      tokenModel.setReefPrice(value);
    });

    jsApi.jsObservable('appState.transferHistory\$').listen((items) {
      if(items==null) {
        return;
      }
      List<TokenActivity> tknList = List.from(items.map((i)=>TokenActivity.fromJSON(i)));
      tokenModel.setTokenActivity(tknList);
    });

  }

}
