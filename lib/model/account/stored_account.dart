import 'package:hive/hive.dart';
import 'dart:convert';

part 'stored_account.g.dart';

@HiveType(typeId: 1)
class StoredAccount extends HiveObject {
  @HiveField(0)
  late String mnemonic;

  @HiveField(1)
  late String address;

  @HiveField(2)
  late String svg;

  static StoredAccount fromString(String jsonString) {
    var jsonObject = json.decode(jsonString);

    return StoredAccount()
      ..mnemonic = jsonObject['mnemonic']
      ..address = jsonObject['address']
      ..svg = jsonObject['svg'];
  }
}
