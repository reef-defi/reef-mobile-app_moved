import 'package:hive/hive.dart';

part 'stored_account.g.dart';

@HiveType(typeId: 1)
class StoredAccount extends HiveObject {
  @HiveField(0)
  late String mnemonic;

  @HiveField(1)
  late String address;

  @HiveField(2)
  late String svg;
}

