// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoiAdapter extends TypeAdapter<Roi> {
  @override
  final int typeId = 1;

  @override
  Roi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Roi(
      times: fields[0] as double,
      currency: fields[1] as String,
      percentage: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Roi obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.times)
      ..writeByte(1)
      ..write(obj.currency)
      ..writeByte(2)
      ..write(obj.percentage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
