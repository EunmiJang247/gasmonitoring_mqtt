import 'package:shared_preferences/shared_preferences.dart';

class ThresholdSettings {
  static const String _tempMinKey = 'temp_min_threshold';
  static const String _tempMaxKey = 'temp_max_threshold';
  static const String _humMinKey = 'hum_min_threshold';
  static const String _humMaxKey = 'hum_max_threshold';
  static const String _alertEnabledKey = 'alert_enabled';
  static const String _lastAlertTimeKey = 'last_alert_time';

  // 기본 임계치 설정
  static const double defaultTempMin = 18.0; // 최소 온도 18°C
  static const double defaultTempMax = 28.0; // 최대 온도 28°C
  static const double defaultHumMin = 40.0; // 최소 습도 40%
  static const double defaultHumMax = 70.0; // 최대 습도 70%
  static const int alertCooldownMinutes = 5; // 알림 쿨다운 5분

  late SharedPreferences _prefs;
  bool _initialized = false;

  static final ThresholdSettings _instance = ThresholdSettings._internal();
  factory ThresholdSettings() => _instance;
  ThresholdSettings._internal();

  /// 초기화
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    print('📊 Threshold Settings Initialized');
  }

  /// 온도 최소값
  Future<double> getTempMin() async {
    await initialize();
    return _prefs.getDouble(_tempMinKey) ?? defaultTempMin;
  }

  /// 온도 최대값
  Future<double> getTempMax() async {
    await initialize();
    return _prefs.getDouble(_tempMaxKey) ?? defaultTempMax;
  }

  /// 습도 최소값
  Future<double> getHumMin() async {
    await initialize();
    return _prefs.getDouble(_humMinKey) ?? defaultHumMin;
  }

  /// 습도 최대값
  Future<double> getHumMax() async {
    await initialize();
    return _prefs.getDouble(_humMaxKey) ?? defaultHumMax;
  }

  /// 알림 활성화 상태
  Future<bool> isAlertEnabled() async {
    await initialize();
    return _prefs.getBool(_alertEnabledKey) ?? true;
  }

  /// 온도 최소값 설정
  Future<void> setTempMin(double value) async {
    await initialize();
    await _prefs.setDouble(_tempMinKey, value);
  }

  /// 온도 최대값 설정
  Future<void> setTempMax(double value) async {
    await initialize();
    await _prefs.setDouble(_tempMaxKey, value);
  }

  /// 습도 최소값 설정
  Future<void> setHumMin(double value) async {
    await initialize();
    await _prefs.setDouble(_humMinKey, value);
  }

  /// 습도 최대값 설정
  Future<void> setHumMax(double value) async {
    await initialize();
    await _prefs.setDouble(_humMaxKey, value);
  }

  /// 알림 활성화/비활성화
  Future<void> setAlertEnabled(bool enabled) async {
    await initialize();
    await _prefs.setBool(_alertEnabledKey, enabled);
  }

  /// 마지막 알림 시간 설정
  Future<void> setLastAlertTime() async {
    await initialize();
    await _prefs.setInt(
        _lastAlertTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// 알림 쿨다운 체크 (중복 알림 방지)
  Future<bool> canSendAlert() async {
    await initialize();
    final lastAlert = _prefs.getInt(_lastAlertTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cooldownMs = alertCooldownMinutes * 60 * 1000;
    return (now - lastAlert) > cooldownMs;
  }

  /// 온도 임계치 체크
  Future<AlertType?> checkTemperature(double temperature) async {
    if (!await isAlertEnabled()) return null;

    final min = await getTempMin();
    final max = await getTempMax();

    if (temperature < min) return AlertType.tempLow;
    if (temperature > max) return AlertType.tempHigh;
    return null;
  }

  /// 습도 임계치 체크
  Future<AlertType?> checkHumidity(double humidity) async {
    if (!await isAlertEnabled()) return null;

    final min = await getHumMin();
    final max = await getHumMax();

    if (humidity < min) return AlertType.humLow;
    if (humidity > max) return AlertType.humHigh;
    return null;
  }

  /// 현재 설정값들을 맵으로 반환
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'tempMin': await getTempMin(),
      'tempMax': await getTempMax(),
      'humMin': await getHumMin(),
      'humMax': await getHumMax(),
      'alertEnabled': await isAlertEnabled(),
    };
  }

  /// 설정값들을 문자열로 반환 (UI 표시용)
  Future<String> getSettingsText() async {
    final settings = await getAllSettings();
    return '온도: ${settings['tempMin']}°C ~ ${settings['tempMax']}°C, '
        '습도: ${settings['humMin']}% ~ ${settings['humMax']}%, '
        '알림: ${settings['alertEnabled'] ? '활성화' : '비활성화'}';
  }
}

enum AlertType {
  tempHigh, // 고온
  tempLow, // 저온
  humHigh, // 고습도
  humLow, // 저습도
}
