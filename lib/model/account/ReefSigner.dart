import '../../utils/json_big_int.dart';

class ReefSigner {
  String address;
  String name;
  BigInt balance;
  String? iconSVG;
  String evmAddress;
  bool isEvmClaimed;

  ReefSigner(
      {required String this.address,
      required String this.name,
      required BigInt this.balance,
      required String this.evmAddress,
      required bool this.isEvmClaimed,
      this.iconSVG});

  static fromJson(dynamic json) {
    var balanceVal = JsonBigInt.toBigInt(json['balance']);
    return ReefSigner(
        address: json["address"],
        name: json["name"],
        balance: balanceVal ?? BigInt.zero,
        evmAddress: json["evmAddress"] ?? '',
        isEvmClaimed: json["isEvmClaimed"],
        iconSVG: json["iconSVG"]);
  }
}
