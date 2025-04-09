// GENERATED CODE - DO NOT MODIFY BY HAND

part of '05_picture.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomPictureAdapter extends TypeAdapter<CustomPicture> {
  @override
  final int typeId = 5;

  @override
  CustomPicture read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomPicture(
      seq: fields[0] as String?,
      project_seq: fields[1] as String?,
      drawing_seq: fields[2] as String?,
      fault_seq: fields[3] as String?,
      file_path: fields[4] as String?,
      file_name: fields[5] as String?,
      file_size: fields[6] as String?,
      thumb: fields[7] as String?,
      no: fields[8] as String?,
      kind: fields[9] as String?,
      pid: fields[10] as String?,
      fid: fields[11] as String?,
      before_picture: fields[12] as CustomPicture?,
      location: fields[13] as String?,
      cate1_seq: fields[14] as String?,
      cate2_seq: (fields[15] as List?)?.cast<String>(),
      cate1_name: fields[16] as String?,
      cate2_name: fields[17] as String?,
      width: fields[18] as String?,
      length: fields[19] as String?,
      dong: fields[20] as String?,
      floor: fields[21] as String?,
      floor_name: fields[22] as String?,
      reg_time: fields[23] as String?,
      update_time: fields[24] as String?,
      state: fields[25] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomPicture obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.seq)
      ..writeByte(1)
      ..write(obj.project_seq)
      ..writeByte(2)
      ..write(obj.drawing_seq)
      ..writeByte(3)
      ..write(obj.fault_seq)
      ..writeByte(4)
      ..write(obj.file_path)
      ..writeByte(5)
      ..write(obj.file_name)
      ..writeByte(6)
      ..write(obj.file_size)
      ..writeByte(7)
      ..write(obj.thumb)
      ..writeByte(8)
      ..write(obj.no)
      ..writeByte(9)
      ..write(obj.kind)
      ..writeByte(10)
      ..write(obj.pid)
      ..writeByte(11)
      ..write(obj.fid)
      ..writeByte(12)
      ..write(obj.before_picture)
      ..writeByte(13)
      ..write(obj.location)
      ..writeByte(14)
      ..write(obj.cate1_seq)
      ..writeByte(15)
      ..write(obj.cate2_seq)
      ..writeByte(16)
      ..write(obj.cate1_name)
      ..writeByte(17)
      ..write(obj.cate2_name)
      ..writeByte(18)
      ..write(obj.width)
      ..writeByte(19)
      ..write(obj.length)
      ..writeByte(20)
      ..write(obj.dong)
      ..writeByte(21)
      ..write(obj.floor)
      ..writeByte(22)
      ..write(obj.floor_name)
      ..writeByte(23)
      ..write(obj.reg_time)
      ..writeByte(24)
      ..write(obj.update_time)
      ..writeByte(25)
      ..write(obj.state);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomPictureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomPicture _$CustomPictureFromJson(Map<String, dynamic> json) =>
    CustomPicture(
      seq: json['seq'] as String?,
      project_seq: json['project_seq'] as String?,
      drawing_seq: json['drawing_seq'] as String?,
      fault_seq: json['fault_seq'] as String?,
      file_path: json['file_path'] as String?,
      file_name: json['file_name'] as String?,
      file_size: json['file_size'] as String?,
      thumb: json['thumb'] as String?,
      no: json['no'] as String?,
      kind: json['kind'] as String?,
      pid: json['pid'] as String?,
      fid: json['fid'] as String?,
      before_picture: json['before_picture'] == null
          ? null
          : CustomPicture.fromJson(
              json['before_picture'] as Map<String, dynamic>),
      location: json['location'] as String?,
      cate1_seq: json['cate1_seq'] as String?,
      cate2_seq: (json['cate2_seq'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      cate1_name: json['cate1_name'] as String?,
      cate2_name: json['cate2_name'] as String?,
      width: json['width'] as String?,
      length: json['length'] as String?,
      dong: json['dong'] as String?,
      floor: json['floor'] as String?,
      floor_name: json['floor_name'] as String?,
      reg_time: json['reg_time'] as String?,
      update_time: json['update_time'] as String?,
      state: (json['state'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CustomPictureToJson(CustomPicture instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'project_seq': instance.project_seq,
      'drawing_seq': instance.drawing_seq,
      'fault_seq': instance.fault_seq,
      'file_path': instance.file_path,
      'file_name': instance.file_name,
      'file_size': instance.file_size,
      'thumb': instance.thumb,
      'no': instance.no,
      'kind': instance.kind,
      'pid': instance.pid,
      'fid': instance.fid,
      'before_picture': instance.before_picture,
      'location': instance.location,
      'cate1_seq': instance.cate1_seq,
      'cate2_seq': instance.cate2_seq,
      'cate1_name': instance.cate1_name,
      'cate2_name': instance.cate2_name,
      'width': instance.width,
      'length': instance.length,
      'dong': instance.dong,
      'floor': instance.floor,
      'floor_name': instance.floor_name,
      'reg_time': instance.reg_time,
      'update_time': instance.update_time,
      'state': instance.state,
    };
