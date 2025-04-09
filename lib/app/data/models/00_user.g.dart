// GENERATED CODE - DO NOT MODIFY BY HAND

part of '00_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      seq: fields[0] as String,
      email: fields[1] as String,
      name: fields[2] as String,
      company_name: fields[3] as String,
      avatar_file: fields[4] as String,
      role: fields[5] as String,
      machine_engineer_grade: fields[6] as String?,
      machine_engineer_license_no: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.seq)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.company_name)
      ..writeByte(4)
      ..write(obj.avatar_file)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.machine_engineer_grade)
      ..writeByte(7)
      ..write(obj.machine_engineer_license_no);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      seq: json['seq'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      company_name: json['company_name'] as String,
      avatar_file: json['avatar_file'] as String,
      role: json['role'] as String,
      machine_engineer_grade: json['machine_engineer_grade'] as String?,
      machine_engineer_license_no:
          json['machine_engineer_license_no'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'seq': instance.seq,
      'email': instance.email,
      'name': instance.name,
      'company_name': instance.company_name,
      'avatar_file': instance.avatar_file,
      'role': instance.role,
      'machine_engineer_grade': instance.machine_engineer_grade,
      'machine_engineer_license_no': instance.machine_engineer_license_no,
    };
