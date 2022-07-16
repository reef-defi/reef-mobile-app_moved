// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoredAccountAdapter extends TypeAdapter<StoredAccount> {
  @override
  final int typeId = 1;

  @override
  StoredAccount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoredAccount()
      ..mnemonic = fields[0] as String
      ..address = fields[1] as String
      ..svg = fields[2] as String
      ..name = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, StoredAccount obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.mnemonic)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.svg)
      ..writeByte(3)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoredAccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
