import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';

class Constants {
  static const REEF_TOKEN_ADDRESS =
      "0x0000000000000000000000000000000001000000";
  static const BINANCE_CONNECT_PROXY_URL =
      "http://10.0.2.2:8080"; // TODO change to production url
  static final REEF_TOKEN = TokenWithAmount(
      name: 'Reef',
      address: REEF_TOKEN_ADDRESS,
      iconUrl: '',
      symbol: 'REEF',
      balance: 0,
      decimals: 18,
      amount: BigInt.zero,
      price: null);
  static const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
}
