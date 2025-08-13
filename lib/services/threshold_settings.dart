import 'package:shared_preferences/shared_preferences.dart';

class ThresholdSettings {
  // 앱에서 쓰는 온도/습도 임계값과 알림 쿨다운 시간을 로컬에 저장하고 불러오는 관리자 클래스
  // SharedPreferences를 쓰니까 데이터는 기기 로컬 스토리지에 키-값 쌍으로 저장되고, 앱 재시작해도 유지된다
  // 단순 Key-Value구조의 로컬데이터 저장소
  static const String _tempMinKey = 'temp_min_threshold';
  static const String _tempMaxKey = 'temp_max_threshold';
  static const String _humMinKey = 'hum_min_threshold';
  static const String _humMaxKey = 'hum_max_threshold';
  static const String _alertCooldownKey = 'alert_cooldown_minutes';

  // 기본값
  static const double defaultTempMin = 18.0;
  static const double defaultTempMax = 28.0;
  static const double defaultHumMin = 40.0;
  static const double defaultHumMax = 70.0;
  static const int defaultAlertCooldown = 1; // 5분

  // 온도 임계값 가져오기
  static Future<double> getTempMinThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences 인스턴스 가져오기
    return prefs.getDouble(_tempMinKey) ?? defaultTempMin;
    // 저장된 값이 있으면 가져오고 없으면 기본값 반환
  }

  static Future<double> getTempMaxThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_tempMaxKey) ?? defaultTempMax;
  }

  // 습도 임계값 가져오기
  static Future<double> getHumMinThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_humMinKey) ?? defaultHumMin;
  }

  static Future<double> getHumMaxThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_humMaxKey) ?? defaultHumMax;
  }

  // 알림 쿨다운 시간 가져오기
  static Future<int> getAlertCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_alertCooldownKey) ?? defaultAlertCooldown;
  }

  // 온도 임계값 설정
  static Future<void> setTempThresholds(double min, double max) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_tempMinKey, min);
    await prefs.setDouble(_tempMaxKey, max);
  }

  // 습도 임계값 설정
  static Future<void> setHumThresholds(double min, double max) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_humMinKey, min);
    await prefs.setDouble(_humMaxKey, max);
  }

  // 알림 쿨다운 시간 설정
  static Future<void> setAlertCooldown(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_alertCooldownKey, minutes);
  }

  // 모든 설정 초기화
  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_tempMinKey, defaultTempMin);
    await prefs.setDouble(_tempMaxKey, defaultTempMax);
    await prefs.setDouble(_humMinKey, defaultHumMin);
    await prefs.setDouble(_humMaxKey, defaultHumMax);
    await prefs.setInt(_alertCooldownKey, defaultAlertCooldown);
  }
}
