// GENERATED CODE - DO NOT MODIFY BY HAND

part of '03_marker.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarkerAdapter extends TypeAdapter<Marker> {
  @override
  final int typeId = 3;

  @override
  Marker read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Marker(
      seq: fields[0] as String?,
      drawing_seq: fields[1] as String?,
      outline_color: fields[2] as String?,
      foreground_color: fields[3] as String?,
      x: fields[4] as String?,
      y: fields[5] as String?,
      no: fields[6] as String?,
      live_tour_url: fields[7] as String?,
      reg_time: fields[8] as String?,
      update_time: fields[9] as String?,
      deleted: fields[10] as String?,
      fault_list: (fields[11] as List?)?.cast<Fault>(),
      fault_cnt: fields[12] as int?,
      mid: fields[13] as String?,
      project_seq: fields[14] as String?,
      dong: fields[15] as String?,
      floor: fields[16] as String?,
      first_fault_seq: fields[17] as String?,
      size: fields[18] as String?,
      floor_name: fields[19] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Marker obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.seq)
      ..writeByte(1)
      ..write(obj.drawing_seq)
      ..writeByte(2)
      ..write(obj.outline_color)
      ..writeByte(3)
      ..write(obj.foreground_color)
      ..writeByte(4)
      ..write(obj.x)
      ..writeByte(5)
      ..write(obj.y)
      ..writeByte(6)
      ..write(obj.no)
      ..writeByte(7)
      ..write(obj.live_tour_url)
      ..writeByte(8)
      ..write(obj.reg_time)
      ..writeByte(9)
      ..write(obj.update_time)
      ..writeByte(10)
      ..write(obj.deleted)
      ..writeByte(11)
      ..write(obj.fault_list)
      ..writeByte(12)
      ..write(obj.fault_cnt)
      ..writeByte(13)
      ..write(obj.mid)
      ..writeByte(14)
      ..write(obj.project_seq)
      ..writeByte(15)
      ..write(obj.dong)
      ..writeByte(16)
      ..write(obj.floor)
      ..writeByte(17)
      ..write(obj.first_fault_seq)
      ..writeByte(18)
      ..write(obj.size)
      ..writeByte(19)
      ..write(obj.floor_name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Marker _$MarkerFromJson(Map<String, dynamic> json) => Marker(
      seq: json['seq'] as String?,
      drawing_seq: json['drawing_seq'] as String?,
      outline_color: json['outline_color'] as String?,
      foreground_color: json['foreground_color'] as String?,
      x: json['x'] as String?,
      y: json['y'] as String?,
      no: json['no'] as String?,
      live_tour_url: json['live_tour_url'] as String?,
      reg_time: json['reg_time'] as String?,
      update_time: json['update_time'] as String?,
      deleted: json['deleted'] as String?,
      fault_list: (json['fault_list'] as List<dynamic>?)
          ?.map((e) => Fault.fromJson(e as Map<String, dynamic>))
          .toList(),
      fault_cnt: (json['fault_cnt'] as num?)?.toInt(),
      mid: json['mid'] as String?,
      project_seq: json['project_seq'] as String?,
      dong: json['dong'] as String?,
      floor: json['floor'] as String?,
      first_fault_seq: json['first_fault_seq'] as String?,
      size: json['size'] as String?,
      floor_name: json['floor_name'] as String?,
    );

Map<String, dynamic> _$MarkerToJson(Marker instance) => <String, dynamic>{
      'seq': instance.seq,
      'drawing_seq': instance.drawing_seq,
      'outline_color': instance.outline_color,
      'foreground_color': instance.foreground_color,
      'x': instance.x,
      'y': instance.y,
      'no': instance.no,
      'live_tour_url': instance.live_tour_url,
      'reg_time': instance.reg_time,
      'update_time': instance.update_time,
      'deleted': instance.deleted,
      'fault_list': instance.fault_list,
      'fault_cnt': instance.fault_cnt,
      'mid': instance.mid,
      'project_seq': instance.project_seq,
      'dong': instance.dong,
      'floor': instance.floor,
      'first_fault_seq': instance.first_fault_seq,
      'size': instance.size,
      'floor_name': instance.floor_name,
    };
