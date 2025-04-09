// GENERATED CODE - DO NOT MODIFY BY HAND

part of '08_fault_cate2_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FaultCate2ListAdapter extends TypeAdapter<FaultCate2List> {
  @override
  final int typeId = 8;

  @override
  FaultCate2List read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FaultCate2List(
      fault_cate2_list: (fields[0] as List?)?.cast<FaultCategory>(),
    );
  }

  @override
  void write(BinaryWriter writer, FaultCate2List obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.fault_cate2_list);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaultCate2ListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaultCate2List _$FaultCate2ListFromJson(Map<String, dynamic> json) =>
    FaultCate2List(
      fault_cate2_list: (json['fault_cate2_list'] as List<dynamic>?)
          ?.map((e) => FaultCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FaultCate2ListToJson(FaultCate2List instance) =>
    <String, dynamic>{
      'fault_cate2_list': instance.fault_cate2_list,
    };
