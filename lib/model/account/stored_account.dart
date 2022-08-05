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

  @HiveField(3)
  late String name;

  static StoredAccount fromString(String jsonString) {
    var jsonObject = json.decode(jsonString);

    return StoredAccount()
      ..mnemonic = jsonObject['mnemonic']
      ..address = jsonObject['address']
      ..svg = jsonObject['svg']
      ..name = jsonObject['name'] ?? "";
  }

   Map toJson(bool? canIncludeKeys) => {
    'mnemonic': canIncludeKeys!=null && canIncludeKeys == true ? mnemonic : null,
    'address': address,
    'svg': svg,
    'name': name
  };

  Map toJsonSkinny() => {
    'address': address,
    'name': name
  };
}
