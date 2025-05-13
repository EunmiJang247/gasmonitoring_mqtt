import 'package:meditation_friend/app/data/models/quote.dart';

const int imageQuality = 100; // 0~100(%)
const double imageMaxWidth = 1200; // 사진의 가로 최대 크기를 1200px 로 제한
const double photoAspectRatio = 342 / 230;
const double leftBarWidth = 64;
const double appBarHeight = 70;
const Map<String, double> tableSize = {
  "header_height": 42,
  "row_height": 38,
  "seq": 48,
  "location": 80,
  "element": 80,
  "width": 55,
  "length": 55,
  "qty": 45,
  "ing_yn": 45,
  "status": 70,
  "note": 60,
  "pic_no": 45,
};
const List<String> faultWidth = [
  "0.1",
  "0.2",
  "0.3",
  "0.4",
  "0.5",
]; //폭
const List<String> faultLength = [
  "1",
  "2",
  "3",
  "4",
  "5",
]; //길이
const List<String> location = [
  "1",
  "2",
  "3",
  "4",
  "5",
]; //부위
const String ASSETS_IMAGES_SPLASHSCREEN_PNG = 'assets/images/splashscreen.png';
const String MUSICPLAYING = 'assets/images/music_playing_pic.png';
const String ASSETS_IMAGES_SPLASHSCREEN_DOTDOT_PNG =
    'assets/images/dotdot_splash.png';
const String ASSETS_MUSIC_BAR = 'assets/images/music_sound_bar.png';
const String ASSETS_PLAY_BUTTON = 'assets/images/playbutton.png';
List<Quote> quotes = [
  Quote(author: "파울로 코엘료", quote: "언제나 현재에 집중할 수 있다면 행복할 것이다."),
  Quote(author: "달라이 라마", quote: "행복은 이미 우리 안에 있습니다.\n 그것을 인식하는 것이 중요합니다."),
  Quote(author: "틱낫한", quote: "지금 이 순간이 당신의 삶입니다.\n 숨을 들이쉬며 그걸 느껴보세요."),
  Quote(author: "에크하르트 톨레", quote: "지금 이 순간을 받아들이는 것이\n 고통을 끝내는 열쇠입니다."),
  Quote(author: "공자", quote: "마음이 평화로우면 온 세상이 평화롭다."),
  Quote(author: "마더 테레사", quote: "작은 일에도 사랑을 담아 하세요.\n 그것이 세상을 바꿉니다."),
  Quote(author: "루미", quote: "당신이 찾고 있는 모든 답은 당신 안에 있습니다."),
  Quote(author: "소크라테스", quote: "너 자신을 알라.\n 거기서부터 모든 것이 시작된다."),
  Quote(author: "칼 융", quote: "내면을 들여다보는 자는 깨어난다."),
  Quote(author: "부처", quote: "모든 것은 마음에서 비롯된다.\n 마음을 바꾸면 세상이 바뀐다."),
  Quote(author: "라오쯔", quote: "자연의 흐름을 따를 때 평온을 찾는다."),
  Quote(author: "헬렌 켈러", quote: "희망은 어둠 속에서도 빛나는 별과 같습니다."),
  Quote(author: "레프 톨스토이", quote: "행복은 우리가 사랑하는 사람과 함께 사는 것이다."),
  Quote(author: "마하트마 간디", quote: "당신이 바라는 변화가 되어라."),
  Quote(author: "에이브러햄 링컨", quote: "대부분의 사람들은\n 자신이 마음먹은 만큼 행복하다."),
];
