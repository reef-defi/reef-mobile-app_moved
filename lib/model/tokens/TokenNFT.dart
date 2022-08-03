import 'ContractType.dart';
import 'Token.dart';

class TokenNFT extends Token {

  final int nftId;
  final ContractType contractType;
  final String? mimetype;

  const TokenNFT(
      {required String name,
      required address,
      required iconUrl,
      required symbol,
      required balance,
      required this.nftId,
      required this.contractType,
        this.mimetype})
      : super(
            name: name,
            address: address,
            iconUrl: iconUrl,
            symbol: symbol,
            balance: balance,
            decimals: 0);

  static fromJSON(dynamic json) {
    var tkn = Token.fromJSON(json);
    return TokenNFT(
        name: tkn.name,
        address: tkn.address,
        iconUrl: tkn.iconUrl,
        symbol: tkn.symbol,
        balance: tkn.balance,
        nftId: json['nftId'],
        mimetype: json['mimetype']??'',
        contractType: ContractType.fromString(json['contractType']));
  }
}
