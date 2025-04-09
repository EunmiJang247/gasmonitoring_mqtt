// GENERATED CODE - DO NOT MODIFY BY HAND

part of '04_fault.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FaultAdapter extends TypeAdapter<Fault> {
  @override
  final int typeId = 4;

  @override
  Fault read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Fault(
      seq: fields[0] as String?,
      marker_seq: fields[1] as String?,
      user_seq: fields[2] as String?,
      location: fields[3] as String?,
      elem_seq: fields[4] as String?,
      cate1_seq: fields[5] as String?,
      width: fields[6] as String?,
      length: fields[7] as String?,
      qty: fields[8] as String?,
      structure: fields[9] as String?,
      status: fields[10] as String?,
      ing_yn: fields[11] as String?,
      group_fid: fields[12] as String?,
      deleted: fields[13] as String?,
      x: fields[14] as String?,
      y: fields[15] as String?,
      color: fields[16] as String?,
      cause: fields[17] as String?,
      cloned: fields[18] as String?,
      fid: fields[19] as String?,
      reg_time: fields[20] as String?,
      update_time: fields[21] as String?,
      user_name: fields[22] as String?,
      elem: fields[23] as String?,
      mid: fields[24] as String?,
      marker_no: fields[25] as String?,
      drawing_seq: fields[26] as String?,
      project_seq: fields[27] as String?,
      dong: fields[28] as String?,
      floor: fields[29] as String?,
      cate1_name: fields[30] as String?,
      cate2: fields[31] as String?,
      cate2_name: fields[32] as String?,
      pic_no: fields[33] as String?,
      note: fields[34] as String?,
      picture_list: (fields[35] as List?)?.cast<CustomPicture>(),
      floor_name: fields[36] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Fault obj) {
    writer
      ..writeByte(37)
      ..writeByte(0)
      ..write(obj.seq)
      ..writeByte(1)
      ..write(obj.marker_seq)
      ..writeByte(2)
      ..write(obj.user_seq)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.elem_seq)
      ..writeByte(5)
      ..write(obj.cate1_seq)
      ..writeByte(6)
      ..write(obj.width)
      ..writeByte(7)
      ..write(obj.length)
      ..writeByte(8)
      ..write(obj.qty)
      ..writeByte(9)
      ..write(obj.structure)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.ing_yn)
      ..writeByte(12)
      ..write(obj.group_fid)
      ..writeByte(13)
      ..write(obj.deleted)
      ..writeByte(14)
      ..write(obj.x)
      ..writeByte(15)
      ..write(obj.y)
      ..writeByte(16)
      ..write(obj.color)
      ..writeByte(17)
      ..write(obj.cause)
      ..writeByte(18)
      ..write(obj.cloned)
      ..writeByte(19)
      ..write(obj.fid)
      ..writeByte(20)
      ..write(obj.reg_time)
      ..writeByte(21)
      ..write(obj.update_time)
      ..writeByte(22)
      ..write(obj.user_name)
      ..writeByte(23)
      ..write(obj.elem)
      ..writeByte(24)
      ..write(obj.mid)
      ..writeByte(25)
      ..write(obj.marker_no)
      ..writeByte(26)
      ..write(obj.drawing_seq)
      ..writeByte(27)
      ..write(obj.project_seq)
      ..writeByte(28)
      ..write(obj.dong)
      ..writeByte(29)
      ..write(obj.floor)
      ..writeByte(30)
      ..write(obj.cate1_name)
      ..writeByte(31)
      ..write(obj.cate2)
      ..writeByte(32)
      ..write(obj.cate2_name)
      ..writeByte(33)
      ..write(obj.pic_no)
      ..writeByte(34)
      ..write(obj.note)
      ..writeByte(35)
      ..write(obj.picture_list)
      ..writeByte(36)
      ..write(obj.floor_name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fault _$FaultFromJson(Map<String, dynamic> json) => Fault(
      seq: json['seq'] as String?,
      marker_seq: json['marker_seq'] as String?,
      user_seq: json['user_seq'] as String?,
      location: json['location'] as String?,
      elem_seq: json['elem_seq'] as String?,
      cate1_seq: json['cate1_seq'] as String?,
      width: json['width'] as String?,
      length: json['length'] as String?,
      qty: json['qty'] as String?,
      structure: json['structure'] as String?,
      status: json['status'] as String?,
      ing_yn: json['ing_yn'] as String?,
      group_fid: json['group_fid'] as String?,
      deleted: json['deleted'] as String?,
      x: json['x'] as String?,
      y: json['y'] as String?,
      color: json['color'] as String?,
      cause: json['cause'] as String?,
      cloned: json['cloned'] as String?,
      fid: json['fid'] as String?,
      reg_time: json['reg_time'] as String?,
      update_time: json['update_time'] as String?,
      user_name: json['user_name'] as String?,
      elem: json['elem'] as String?,
      mid: json['mid'] as String?,
      marker_no: json['marker_no'] as String?,
      drawing_seq: json['drawing_seq'] as String?,
      project_seq: json['project_seq'] as String?,
      dong: json['dong'] as String?,
      floor: json['floor'] as String?,
      cate1_name: json['cate1_name'] as String?,
      cate2: json['cate2'] as String?,
      cate2_name: json['cate2_name'] as String?,
      pic_no: json['pic_no'] as String?,
      note: json['note'] as String?,
      picture_list: (json['picture_list'] as List<dynamic>?)
          ?.map((e) => CustomPicture.fromJson(e as Map<String, dynamic>))
          .toList(),
      floor_name: json['floor_name'] as String?,
    );

Map<String, dynamic> _$FaultToJson(Fault instance) => <String, dynamic>{
      'seq': instance.seq,
      'marker_seq': instance.marker_seq,
      'user_seq': instance.user_seq,
      'location': instance.location,
      'elem_seq': instance.elem_seq,
      'cate1_seq': instance.cate1_seq,
      'width': instance.width,
      'length': instance.length,
      'qty': instance.qty,
      'structure': instance.structure,
      'status': instance.status,
      'ing_yn': instance.ing_yn,
      'group_fid': instance.group_fid,
      'deleted': instance.deleted,
      'x': instance.x,
      'y': instance.y,
      'color': instance.color,
      'cause': instance.cause,
      'cloned': instance.cloned,
      'fid': instance.fid,
      'reg_time': instance.reg_time,
      'update_time': instance.update_time,
      'user_name': instance.user_name,
      'elem': instance.elem,
      'mid': instance.mid,
      'marker_no': instance.marker_no,
      'drawing_seq': instance.drawing_seq,
      'project_seq': instance.project_seq,
      'dong': instance.dong,
      'floor': instance.floor,
      'cate1_name': instance.cate1_name,
      'cate2': instance.cate2,
      'cate2_name': instance.cate2_name,
      'pic_no': instance.pic_no,
      'note': instance.note,
      'picture_list': instance.picture_list,
      'floor_name': instance.floor_name,
    };
