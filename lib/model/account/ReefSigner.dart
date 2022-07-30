import '../../utils/json_big_int.dart';

class ReefSigner {
  String address;
  String name;
  BigInt balance;

  ReefSigner(String this.address, String this.name, BigInt this.balance);

  static fromJson(dynamic json) {
    var balanceVal = JsonBigInt.toBigInt(json['balance']);
    return ReefSigner(json["address"], json["name"], balanceVal??BigInt.zero);
  }
}
