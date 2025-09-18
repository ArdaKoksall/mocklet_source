// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 4;

  @override
  UserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserData(
      userId: fields[0] as String,
      transactions: (fields[1] as List).cast<Transaction>(),
      userCryptos: (fields[2] as List).cast<UserCrypto>(),
      totalBalance: fields[3] as double,
      favoriteCryptos: (fields[4] as List).cast<String>(),
      tetherBalance: fields[5] as double,
      latestCryptos: (fields[6] as List).cast<String>(),
      settings: fields[7] as Settings,
    );
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.transactions)
      ..writeByte(2)
      ..write(obj.userCryptos)
      ..writeByte(3)
      ..write(obj.totalBalance)
      ..writeByte(4)
      ..write(obj.favoriteCryptos)
      ..writeByte(5)
      ..write(obj.tetherBalance)
      ..writeByte(6)
      ..write(obj.latestCryptos)
      ..writeByte(7)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
