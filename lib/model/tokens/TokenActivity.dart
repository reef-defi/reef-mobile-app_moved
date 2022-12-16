import 'Token.dart';
import 'TokenNFT.dart';

class TokenActivity {
  final DateTime timestamp;
  final String url;
  final bool isInbound;
  final Token? token;
  final TokenNFT? tokenNFT;
  dynamic? extrinsic;

  TokenActivity({required this.timestamp, required this.isInbound, required this.url, this.token, this.tokenNFT});

  static TokenActivity fromJson (dynamic json) {
    var token, tokenNFT;
    if(json['token']['contractType']!=null){
      tokenNFT = TokenNFT.fromJson(json['token']);
    }else{
      token = Token.fromJson(json['token']);
    }
    return TokenActivity(timestamp: DateTime.parse(json['timestamp']), isInbound: json['inbound'], url: json['url'], token: token, tokenNFT: tokenNFT);
  }
}
