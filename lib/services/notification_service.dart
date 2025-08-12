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
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
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
