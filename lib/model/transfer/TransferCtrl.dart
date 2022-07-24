import 'package:reef_mobile_app/service/JsApiService.dart';

class TransferCtrl {
  final JsApiService jsApi;

  TransferCtrl(this.jsApi);

  Future<dynamic> transferTokens(String fromAddress, String toAddress, String tokenAmount,
      int tokenDecimals, String tokenAddress) async {
    return jsApi.jsPromise(
        'transfer.send("$fromAddress", "$toAddress", "${tokenAmount}", ${tokenDecimals}, "${tokenAddress}")');
  }

  Future<dynamic> testTransferTokens(String from) async {
    if(from==null) {
      print('No from address value specified');
      return false;
    }
    const toAddress = '5DWsQ5XpdixnPZUMZMiPuGRXaUKN115YNNqDcneqWfKaqvsK';
    const amount = "1.0";
    const decimals = 18;
    // reef
    // const address = '0x0000000000000000000000000000000001000000';
    // test erc20
    const address = '0x4676199AdA480a2fCB4b2D4232b7142AF9fe9D87';
    return transferTokens(from, toAddress, amount, decimals, address);
  }
}
