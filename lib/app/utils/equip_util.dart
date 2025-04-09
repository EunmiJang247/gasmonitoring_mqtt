import 'dart:math';


// 반올림하여 값을 지정된 소수점 이하 자리까지 비교
double roundToPrecision(double value, int precision) {
  int factor = pow(10, precision).toInt();
  return (value * factor).round() / factor;
}
