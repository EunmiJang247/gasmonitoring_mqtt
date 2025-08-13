import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool _notificationsEnabled = true;

  // 마지막 알림 시간 추적 (쿨다운용)
  static DateTime? _lastTempAlert;
  static DateTime? _lastHumAlert;

  static Future<void> initialize() async {
    // 알림 발송 자체가 아니라, “알림 기능을 사용할 준비”를 하는 단계
    // 클래스명.initialize()로 바로 호출 가능
    if (_isInitialized) return;
    // 중복 초기화 방지

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // 앱의 기본 아이콘을 알림 아이콘으로 사용

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true, // 팝업 알림 허용 요청
      requestBadgePermission: true, // 앱 아이콘에 빨간 뱃지 표시 권한 요청
      requestSoundPermission: true, // 알림 소리 재생 권한 요청
    );
    // iOS/macOS에서 사용할 알림 초기 세팅
    // 실행 시, iOS에서는 “앱이 알림을 보내려고 합니다” 팝업이 뜨게 됨

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    // 안드로이드/IOS 설정을 하나의 객체로 합침.

    await _notificationsPlugin.initialize(initializationSettings);
    // _notificationsPlugin → FlutterLocalNotificationsPlugin의 인스턴스
    // 알림 시스템을 앱에서 쓸 수 있도록 준비

    _isInitialized = true;
  }

  static Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    final bool? result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return result ?? false;
  }

  static void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
  }

  static bool get notificationsEnabled => _notificationsEnabled;

  static Future<void> showTemperatureAlert(
      double temperature, double min, double max, int cooldownMinutes) async {
    if (!_notificationsEnabled) return;

    // 쿨다운 체크
    if (_lastTempAlert != null) {
      final difference = DateTime.now().difference(_lastTempAlert!);
      if (difference.inMinutes < cooldownMinutes) {
        return; // 쿨다운 시간 내에는 알림을 보내지 않음
      }
    }

    String title = '온도 경고';
    String body;

    if (temperature < min) {
      body =
          '온도가 너무 낮습니다: ${temperature.toStringAsFixed(1)}°C (최소: ${min.toStringAsFixed(1)}°C)';
    } else {
      body =
          '온도가 너무 높습니다: ${temperature.toStringAsFixed(1)}°C (최대: ${max.toStringAsFixed(1)}°C)';
    }

    await _showNotification(1, title, body);
    _lastTempAlert = DateTime.now();
  }

  static Future<void> showHumidityAlert(
      double humidity, double min, double max, int cooldownMinutes) async {
    if (!_notificationsEnabled) return;

    // 쿨다운 체크
    if (_lastHumAlert != null) {
      final difference = DateTime.now().difference(_lastHumAlert!);
      if (difference.inMinutes < cooldownMinutes) {
        return; // 쿨다운 시간 내에는 알림을 보내지 않음
      }
    }

    String title = '습도 경고';
    String body;

    if (humidity < min) {
      body =
          '습도가 너무 낮습니다: ${humidity.toStringAsFixed(1)}% (최소: ${min.toStringAsFixed(1)}%)';
    } else {
      body =
          '습도가 너무 높습니다: ${humidity.toStringAsFixed(1)}% (최대: ${max.toStringAsFixed(1)}%)';
    }

    await _showNotification(2, title, body);
    _lastHumAlert = DateTime.now();
  }

  static Future<void> _showNotification(
      int id, String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sensor_alerts',
      'Sensor Alerts',
      channelDescription: 'Notifications for sensor threshold alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // 테스트용 알림
  static Future<void> showTestNotification() async {
    await _showNotification(999, '테스트 알림', '알림 시스템이 정상적으로 작동합니다.');
  }
}
