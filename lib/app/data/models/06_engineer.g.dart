// GENERATED CODE - DO NOT MODIFY BY HAND

part of '06_engineer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EngineerAdapter extends TypeAdapter<Engineer> {
  @override
  final int typeId = 6;

  @override
  Engineer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Engineer(
      seq: fields[0] as String?,
      user_seq: fields[1] as String?,
      license_no: fields[2] as String?,
      grade: fields[3] as String?,
      deleted: fields[4] as String?,
      status: fields[5] as String?,
      remark: fields[6] as String?,
      engineer_seq: fields[7] as String?,
      email: fields[8] as String?,
      name: fields[9] as String?,
      mobile: fields[10] as String?,
      avatar_file: fields[11] as String?,
      position_seq: fields[12] as String?,
      position: fields[13] as String?,
      license_seq: fields[14] as String?,
      license_name: fields[15] as String?,
      project_seq: fields[16] as String?,
      project_list: (fields[17] as List?)?.cast<Project>(),
    );
  }

  @override
  void write(BinaryWriter writer, Engineer obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.seq)
      ..writeByte(1)
      ..write(obj.user_seq)
      ..writeByte(2)
      ..write(obj.license_no)
      ..writeByte(3)
      ..write(obj.grade)
      ..writeByte(4)
      ..write(obj.deleted)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.remark)
      ..writeByte(7)
      ..write(obj.engineer_seq)
      ..writeByte(8)
      ..write(obj.email)
      ..writeByte(9)
      ..write(obj.name)
      ..writeByte(10)
      ..write(obj.mobile)
      ..writeByte(11)
      ..write(obj.avatar_file)
      ..writeByte(12)
      ..write(obj.position_seq)
      ..writeByte(13)
      ..write(obj.position)
      ..writeByte(14)
      ..write(obj.license_seq)
      ..writeByte(15)
      ..write(obj.license_name)
      ..writeByte(16)
      ..write(obj.project_seq)
      ..writeByte(17)
      ..write(obj.project_list);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EngineerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Engineer _$EngineerFromJson(Map<String, dynamic> json) => Engineer(
      seq: json['seq'] as String?,
      user_seq: json['user_seq'] as String?,
      license_no: json['license_no'] as String?,
      grade: json['grade'] as String?,
      deleted: json['deleted'] as String?,
      status: json['status'] as String?,
      remark: json['remark'] as String?,
      engineer_seq: json['engineer_seq'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      mobile: json['mobile'] as String?,
      avatar_file: json['avatar_file'] as String?,
      position_seq: json['position_seq'] as String?,
      position: json['position'] as String?,
      license_seq: json['license_seq'] as String?,
      license_name: json['license_name'] as String?,
      project_seq: json['project_seq'] as String?,
      project_list: (json['project_list'] as List<dynamic>?)
          ?.map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EngineerToJson(Engineer instance) => <String, dynamic>{
      'seq': instance.seq,
      'user_seq': instance.user_seq,
      'license_no': instance.license_no,
      'grade': instance.grade,
      'deleted': instance.deleted,
      'status': instance.status,
      'remark': instance.remark,
      'engineer_seq': instance.engineer_seq,
      'email': instance.email,
      'name': instance.name,
      'mobile': instance.mobile,
      'avatar_file': instance.avatar_file,
      'position_seq': instance.position_seq,
      'position': instance.position,
      'license_seq': instance.license_seq,
      'license_name': instance.license_name,
      'project_seq': instance.project_seq,
      'project_list': instance.project_list,
    };
