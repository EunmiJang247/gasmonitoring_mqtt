class Attendance {
  int? id;
  DateTime? attendanceDate; // 출석 날짜
  String? diary; // 짧은 일기
  String? mood; // 오늘의 기분
  String? imageUrl; // 이미지 URL (옵션)

  Attendance({
    this.id,
    this.attendanceDate,
    this.diary,
    this.mood,
    this.imageUrl,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json["id"],
      attendanceDate: json["attendance_date"] != null
          ? DateTime.parse(json["attendance_date"])
          : null,
      diary: json["diary"],
      mood: json["mood"],
      imageUrl: json["image_url"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "attendance_date": attendanceDate?.toIso8601String(),
        "diary": diary,
        "mood": mood,
        "image_url": imageUrl,
      };
}
