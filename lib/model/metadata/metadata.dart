import 'package:hive/hive.dart';

part 'metadata.g.dart';

@HiveType(typeId: 2)
class Metadata extends HiveObject {
  @HiveField(0)
  late String chain;

  @HiveField(1)
  late String genesisHash;

  @HiveField(2)
  late String icon;

  @HiveField(3)
  late int specVersion;

  @HiveField(4)
  late int ss58Format;

  @HiveField(5)
  late int tokenDecimals;

  @HiveField(6)
  late String tokenSymbol;

  @HiveField(7)
  late dynamic types;

  @HiveField(8)
  late String color;

  @HiveField(9)
  late String chainType;

  @HiveField(10)
  late dynamic userExtensions;

  @HiveField(11)
  late String metaCalls;

  static Metadata fromMap(Map map) {
    return Metadata()
      ..chain = map['chain']
      ..genesisHash = map['genesisHash']
      ..icon = map['icon']
      ..specVersion = map['specVersion']
      ..ss58Format = map['ss58Format']
      ..tokenDecimals = map['tokenDecimals']
      ..tokenSymbol = map['tokenSymbol']
      ..types = map['types']
      ..color = map['color'] ?? ""
      ..chainType = map['chainType'] ?? ""
      ..userExtensions = map['userExtensions'] ?? {}
      ..metaCalls = map['metaCalls'] ?? "";
  }

  Map toJson() => {
        'chain': chain,
        'genesisHash': genesisHash,
        'icon': icon,
        'specVersion': specVersion,
        'ss58Format': ss58Format,
        'tokenDecimals': tokenDecimals,
        'tokenSymbol': tokenSymbol,
        'types': types,
        'color': color,
        'chainType': chainType,
        'userExtensions': userExtensions,
        'metaCalls': metaCalls
      };

  Map toInjectedMetadataKnownJson() => {
        'genesisHash': genesisHash,
        'specVersion': specVersion,
      };
}
