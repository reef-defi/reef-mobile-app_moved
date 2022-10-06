// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MetadataAdapter extends TypeAdapter<Metadata> {
  @override
  final int typeId = 2;

  @override
  Metadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Metadata()
      ..chain = fields[0] as String
      ..genesisHash = fields[1] as String
      ..icon = fields[2] as String
      ..specVersion = fields[3] as int
      ..ss58Format = fields[4] as int
      ..tokenDecimals = fields[5] as int
      ..tokenSymbol = fields[6] as String
      ..types = fields[7] as dynamic
      ..color = fields[8] as String
      ..chainType = fields[9] as String
      ..userExtensions = fields[10] as dynamic
      ..metaCalls = fields[11] as String;
  }

  @override
  void write(BinaryWriter writer, Metadata obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.chain)
      ..writeByte(1)
      ..write(obj.genesisHash)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.specVersion)
      ..writeByte(4)
      ..write(obj.ss58Format)
      ..writeByte(5)
      ..write(obj.tokenDecimals)
      ..writeByte(6)
      ..write(obj.tokenSymbol)
      ..writeByte(7)
      ..write(obj.types)
      ..writeByte(8)
      ..write(obj.color)
      ..writeByte(9)
      ..write(obj.chainType)
      ..writeByte(10)
      ..write(obj.userExtensions)
      ..writeByte(11)
      ..write(obj.metaCalls);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
