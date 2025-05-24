class Music {
  int? id;
  String? title; // 명상 세션 제목
  String? description; // 명상 세션 설명
  String? imageUrl; // 명상 이미지 URL
  String? category; // 카테고리
  String? musicUrl;
  int? duration; // 명상 시간 (초 단위)

  Music({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.category,
    this.musicUrl,
    this.duration,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      imageUrl: json["image_url"],
      category: json["category"],
      musicUrl: json["music_url"],
      duration: json["duration"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "category": category,
        "musicUrl": musicUrl,
        "duration": duration,
      };
}
