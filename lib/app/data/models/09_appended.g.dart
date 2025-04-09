// GENERATED CODE - DO NOT MODIFY BY HAND

part of '09_appended.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppendedAdapter extends TypeAdapter<Appended> {
  @override
  final int typeId = 9;

  @override
  Appended read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appended(
      markerList: (fields[0] as List?)?.cast<Marker>(),
      faultList: (fields[1] as List?)?.cast<Fault>(),
    );
  }

  @override
  void write(BinaryWriter writer, Appended obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.markerList)
      ..writeByte(1)
      ..write(obj.faultList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppendedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appended _$AppendedFromJson(Map<String, dynamic> json) => Appended(
      markerList: (json['markerList'] as List<dynamic>?)
          ?.map((e) => Marker.fromJson(e as Map<String, dynamic>))
          .toList(),
      faultList: (json['faultList'] as List<dynamic>?)
          ?.map((e) => Fault.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AppendedToJson(Appended instance) => <String, dynamic>{
      'markerList': instance.markerList,
      'faultList': instance.faultList,
    };
