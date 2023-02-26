import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class TransferCtrl {
  final JsApiService jsApi;

  TransferCtrl(this.jsApi);

  Stream<dynamic> transferTokensStream(
      String fromAddress, String toAddress, TokenWithAmount token) {
    // print(
    //     "$fromAddress | $toAddress | ${token.amount.toString()} | ${token.decimals}  | ${token.address}");
    return jsApi.jsObservable(
        'window.transfer.sendObs("$fromAddress", "$toAddress", "${token.amount.toString()}", ${token.decimals}, "${token.address}")');
  }

  Future<dynamic> transferTokens(
      String fromAddress, String toAddress, TokenWithAmount token) async {
    // print(
    //     "$fromAddress | $toAddress | ${token.amount.toString()} | ${token.decimals}  | ${token.address}");
    return jsApi.jsPromise(
        'window.transfer.sendPromise("$fromAddress", "$toAddress", "${token.amount.toString()}", ${token.decimals}, "${token.address}")');
  }

  /*Future<dynamic> testTransferTokens(String from) async {
    if (from == null) {
      print('No from address value specified');
      return false;
    }
    const toAddress = '5DWsQ5XpdixnPZUMZMiPuGRXaUKN115YNNqDcneqWfKaqvsK';

    TokenWithAmount tokenReef = TokenWithAmount(
        name: 'REEF',
        address: '0x4676199AdA480a2fCB4b2D4232b7142AF9fe9D87',
        iconUrl: 'https://s2.coinmarketcap.com/static/img/coins/64x64/6951.png',
        symbol: 'REEF',
        balance: 0,
        decimals: 18,
        amount: BigInt.one,
        price: null);
    return transferTokens(from, toAddress, tokenReef);
  }*/
}
