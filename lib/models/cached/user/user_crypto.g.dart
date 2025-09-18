// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_crypto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserCryptoAdapter extends TypeAdapter<UserCrypto> {
  @override
  final int typeId = 5;

  @override
  UserCrypto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserCrypto(
      cryptoId: fields[0] as String,
      amount: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, UserCrypto obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.cryptoId)
      ..writeByte(1)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCryptoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
