import 'Token.dart';
import 'TokenNFT.dart';

class TokenActivity {
  final DateTime timestamp;
  final String url;
  final bool isInbound;
  final Token? token;
  final TokenNFT? tokenNFT;
  final String unparsedTimestamp;
  dynamic? extrinsic;

  TokenActivity(
      {required this.timestamp,
      required this.isInbound,
      required this.url,
      this.token,
      required this.unparsedTimestamp,
      this.tokenNFT});

  static TokenActivity fromJson(dynamic json) {
    var token, tokenNFT;
    if (json['token']['contractType'] != null) {
      tokenNFT = TokenNFT.fromJson(json['token']);
    } else {
      token = Token.fromJson(json['token']);
    }
    return TokenActivity(
        unparsedTimestamp: json['timestamp'],
        timestamp: DateTime.parse(json['timestamp']),
        isInbound: json['inbound'],
        url: json['url'],
        token: token,
        tokenNFT: tokenNFT);
  }
}
