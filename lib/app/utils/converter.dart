// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

Map<String, dynamic> responseConverter(String base64Data) {
  // 받은 응답 데이터를 복호화 + 압축 해제 + JSON 디코딩 하는 로직
  // Base64로 인코딩된 문자열을 받아서
  List<int> decodedData = base64.decode(base64Data);
  // 서버에서 받은 데이터는 Base64 문자열
  // 이걸 바이너리로 디코딩하면 List<int> 형태의 압축된 바이트 배열이 나와
  List<int> decompressedData = gzip.decode(decodedData);
  // 위에서 나온 바이트 배열은 GZIP으로 압축된 데이터야
  // gzip.decode를 통해 압축을 해제해 원래 JSON 형태의 바이트로 되돌림.
  String jsonEncoded = utf8.decode(decompressedData);
  // 압축 해제된 바이트를 UTF-8 문자열로 변환. 이건 이제 "{"key":"value", ...}" 형태의 JSON 문자열이 됨.
  Map<String, dynamic> jsonDecoded = jsonDecode(jsonEncoded);
  // JSON 문자열을 Dart에서 쓸 수 있도록 Map 형태로 디코딩
  return jsonDecoded;
  // 결론: Base64 문자열 ➝ 바이너리 ➝ GZIP 압축 해제 ➝ UTF-8 문자열 ➝ JSON 파싱 ➝ Map
}

String sha1Encode(String input) {
  var bytes = utf8.encode(input);
  var digest = sha1.convert(bytes);
  var result = digest.toString();
  return result;
}

String periodConverter({
  required String? bgnDt,
  required String? endDt,
}) {
  if (bgnDt == null || endDt == null) {
    return '';
  }

  try {
    List<String> bgn = bgnDt.split('-');
    List<String> end = endDt.split('-');
    return '${bgn[0]}.${bgn[1]}.${bgn[2]} ~ ${end[1]}.${end[2]}';
  } catch (e) {
    return '';
  }
}

// 설치일자 변환
String setupDateConverter(String? setup_date) {
  if (setup_date == null) {
    return '-';
  }
  List<String> splitted = setup_date.split('-');
  return '${splitted[0]}-${splitted[1]}';
}

int? getYearFromServerDate(String? server_date) {
  if (server_date == null) {
    return null;
  }
  List<String> splitted = server_date.split('-');

  int year = DateTime.now().year;
  if (splitted.length > 1) {
    year = int.parse(splitted[0]);
  }

  return year;
}

int? getMonthFromServerDate(String? server_date) {
  if (server_date == null) {
    return null;
  }
  List<String> splitted = server_date.split('-');
  int month = DateTime.now().month;
  if (splitted.length > 1) {
    month = int.parse(splitted[1]);
  }
  return month;
}

int? getDayFromServerDate(String? server_date) {
  if (server_date == null) {
    return null;
  }
  List<String> splitted = server_date.split('-');
  int day = int.parse(splitted[2]);
  return day;
}

extension DateTimeConverter on DateTime {
  toYYYYMMDD() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  toYYYYMM() => '$year-${month.toString().padLeft(2, '0')}';
  String toPhotoFileName() {
    DateTime now = DateTime.now();
    String date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}_${now.millisecond.toString().padLeft(3, '0')}';
    return '$date.jpg';
  }
}

String photoFileNameConverter(File file) {
  String fileName = file.lastModifiedSync().toPhotoFileName();
  var path = file.path;
  var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
  var newPath = path.substring(0, lastSeparator + 1) + fileName;
  return newPath;
}

String pathWithoutName(String path) {
  var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
  var pathWithoutName = path.substring(0, lastSeparator);
  return pathWithoutName;
}

bool isFilePath(String? path) {
  if (path == null) {
    return false;
  }
  return Directory(path).isAbsolute;
}

bool isSameValue(dynamic value1, dynamic value2) {
  if (value1 != null) {
    if (value2 != null) {
      return value1.toString() == value2.toString();
    } else {
      return value1.toString() == '';
    }
  } else {
    if (value2 != null) {
      return value2.toString() == '';
    } else {
      return true;
    }
  }
}
