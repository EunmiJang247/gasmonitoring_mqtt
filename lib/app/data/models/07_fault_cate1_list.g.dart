// GENERATED CODE - DO NOT MODIFY BY HAND

part of '07_fault_cate1_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FaultCate1ListAdapter extends TypeAdapter<FaultCate1List> {
  @override
  final int typeId = 7;

  @override
  FaultCate1List read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FaultCate1List(
      fault_cate1_list: (fields[0] as List?)?.cast<FaultCategory>(),
    );
  }

  @override
  void write(BinaryWriter writer, FaultCate1List obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.fault_cate1_list);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaultCate1ListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaultCate1List _$FaultCate1ListFromJson(Map<String, dynamic> json) =>
    FaultCate1List(
      fault_cate1_list: (json['fault_cate1_list'] as List<dynamic>?)
          ?.map((e) => FaultCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FaultCate1ListToJson(FaultCate1List instance) =>
    <String, dynamic>{
      'fault_cate1_list': instance.fault_cate1_list,
    };
