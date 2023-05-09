import 'package:flutter/foundation.dart';
import 'package:reef_mobile_app/model/network/NetworkCtrl.dart';
import 'package:reef_mobile_app/model/network/network_model.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/model/tokens/TokenActivity.dart';
import 'package:reef_mobile_app/model/tokens/TokenNFT.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

import 'token_model.dart';

class TokenCtrl {
  final JsApiService jsApi;
  final NetworkModel _networkModel;
  final NetworkCtrl _networkCtrl;

  TokenCtrl(this.jsApi, TokenModel tokenModel, this._networkModel,
      this._networkCtrl) {
    jsApi
        .jsObservable('window.reefState.selectedTokenPrices_status\$')
        .listen((tokens) {
      ParseListFn<StatusDataObject<TokenWithAmount>> parsableListFn =
          getParsableListFn(TokenWithAmount.fromJson);
      var tokensListFdm = StatusDataObject.fromJsonList(tokens, parsableListFn);

      if (kDebugMode) {
        try {
          var tkn = tokensListFdm.data.firstWhere((t) =>
              t.data.address == '0x9250BA0e7616357D6d98825186CF7723D38D8B23');
          print(
              'GOT TOKENS ${tkn.statusList.map((e) => e.code.toString()).toString()}');
        } catch (e) {}
      }
      // print(
      //     'GOT TOKENS ${tokensListFdm.statusList.map((e) => e.code)} msg = ${tokensListFdm.statusList[0].propertyName}');
      tokenModel.setSelectedErc20s(tokensListFdm);
    });

    jsApi
        .jsObservable('window.reefState.selectedNFTs_status\$')
        .listen((tokens) {
      ParseListFn<StatusDataObject<TokenNFT>> parsableListFn =
          getParsableListFn(TokenNFT.fromJson);
      var tokensListFdm = StatusDataObject.fromJsonList(tokens, parsableListFn);
      if (kDebugMode) {
        print('NFTs=${tokensListFdm.data.length}');
      }
      tokenModel.setSelectedNFTs(tokensListFdm);
    });

    jsApi.jsObservable('window.tokenUtil.reefPrice\$').listen((value) {
      var fdm = StatusDataObject.fromJson(value, (v) => v);
      if (fdm != null && fdm.hasStatus(StatusCode.completeData)) {
        if (fdm.data is int) {
          fdm.data = (fdm.data as int).toDouble();
        }
        tokenModel.setReefPrice(fdm.data);
      }
    });

    jsApi
        .jsObservable('window.reefState.selectedTransactionHistory_status\$')
        .listen((items) {
      parsableFn(accList) =>
          List<TokenActivity>.from(accList.map(TokenActivity.fromJson));
      var tokensListFdm = StatusDataObject.fromJsonList(items, parsableFn);

      tokenModel.setTxHistory(tokensListFdm);
      if (kDebugMode) {
        print('GOT HISTORY=${tokensListFdm.data.length}');
      }
    });
  }

  Future<dynamic> findToken(String address) async {
    return jsApi.jsPromise('window.utils.findToken("$address")');
  }

  Future<dynamic> getTxInfo(String timestamp) async {
    return jsApi.jsPromise('window.utils.getTxInfo("$timestamp")');
  }

  void reload() {
    jsApi.jsCallVoidReturn('window.reefState.reloadTokens()');
  }
}
