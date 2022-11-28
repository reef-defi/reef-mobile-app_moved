import '../../utils/json_big_int.dart';

class ReefAccount {
  String address;
  String name;
  BigInt balance;
  String? iconSVG;
  String evmAddress;
  bool isEvmClaimed;

  ReefAccount(
      {required String this.address,
      required String this.name,
      required BigInt this.balance,
      required String this.evmAddress,
      required bool this.isEvmClaimed,
      this.iconSVG});

  static ReefAccount fromJson(dynamic json) {
    var balanceVal = JsonBigInt.toBigInt(json['balance']);
    var claimed = json["isEvmClaimed"]!=null?json["isEvmClaimed"]==true||json["isEvmClaimed"]=='true':false;
    return ReefAccount(
        address: json["address"],
        name: json["name"],
        balance: balanceVal ?? BigInt.zero,
        evmAddress: json["evmAddress"] ?? '',
        isEvmClaimed: claimed,
        iconSVG: json["iconSVG"]);
  }
}
