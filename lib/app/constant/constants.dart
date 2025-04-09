const int imageQuality = 100; // 0~100(%)
const double imageMaxWidth = 1200; // 사진의 가로 최대 크기를 1200px 로 제한
const double photoAspectRatio = 342 / 230;
const double leftBarWidth = 64;
const double appBarHeight = 70;
const String updateUrl = 'https://work.eleng.co.kr';
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
