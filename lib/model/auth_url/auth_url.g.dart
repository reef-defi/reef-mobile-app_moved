// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_url.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthUrlAdapter extends TypeAdapter<AuthUrl> {
  @override
  final int typeId = 3;

  @override
  AuthUrl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthUrl(
      fields[0] as String,
      fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AuthUrl obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.isAllowed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUrlAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
