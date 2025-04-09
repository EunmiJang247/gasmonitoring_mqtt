// GENERATED CODE - DO NOT MODIFY BY HAND

part of '10_elem_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ElementListAdapter extends TypeAdapter<ElementList> {
  @override
  final int typeId = 10;

  @override
  ElementList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ElementList(
      seq: fields[0] as String?,
      name: fields[1] as String?,
      order: fields[2] as String?,
      reg_time: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ElementList obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.seq)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.order)
      ..writeByte(3)
      ..write(obj.reg_time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ElementListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElementList _$ElementListFromJson(Map<String, dynamic> json) => ElementList(
      seq: json['seq'] as String?,
      name: json['name'] as String?,
      order: json['order'] as String?,
      reg_time: json['reg_time'] as String?,
    );

Map<String, dynamic> _$ElementListToJson(ElementList instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'name': instance.name,
      'order': instance.order,
      'reg_time': instance.reg_time,
    };
