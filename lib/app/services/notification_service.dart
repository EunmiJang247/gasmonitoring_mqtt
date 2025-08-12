import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 권한 요청
    await _requestPermissions();

    // Android 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
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

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    print('🔔 Notification Service Initialized');
  }

  /// 권한 요청
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    } else if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  /// 알림 클릭 시 콜백
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    // 필요시 특정 화면으로 네비게이션 등 처리
  }

  /// 온도 임계치 초과 알림
  Future<void> showTemperatureAlert({
    required double temperature,
    required double threshold,
    required bool isHigh,
  }) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'temp_alerts',
      '온도 알림',
      channelDescription: '온도 임계치 초과 시 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF6B6B),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String title = isHigh ? '🔥 고온 경고!' : '🧊 저온 경고!';
    final String body = isHigh
        ? '현재 온도 ${temperature.toStringAsFixed(1)}°C가 설정값 ${threshold.toStringAsFixed(1)}°C를 초과했습니다!'
        : '현재 온도 ${temperature.toStringAsFixed(1)}°C가 설정값 ${threshold.toStringAsFixed(1)}°C 미만입니다!';

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: 'temperature_alert',
    );

    print('🔔 Temperature alert sent: $temperature°C');
  }

  /// 습도 임계치 초과 알림
  Future<void> showHumidityAlert({
    required double humidity,
    required double threshold,
    required bool isHigh,
  }) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'humidity_alerts',
      '습도 알림',
      channelDescription: '습도 임계치 초과 시 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4ECDC4),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String title = isHigh ? '💧 고습도 경고!' : '🏜️ 저습도 경고!';
    final String body = isHigh
        ? '현재 습도 ${humidity.toStringAsFixed(0)}%가 설정값 ${threshold.toStringAsFixed(0)}%를 초과했습니다!'
        : '현재 습도 ${humidity.toStringAsFixed(0)}%가 설정값 ${threshold.toStringAsFixed(0)}% 미만입니다!';

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
      title,
      body,
      details,
      payload: 'humidity_alert',
    );

    print('🔔 Humidity alert sent: $humidity%');
  }

  /// 연결 상태 알림
  Future<void> showConnectionAlert({required String message}) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'connection_alerts',
      '연결 상태',
      channelDescription: 'MQTT 연결 상태 알림',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFFB74D),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2,
      '📡 센서 연결 상태',
      message,
      details,
      payload: 'connection_alert',
    );

    print('🔔 Connection alert sent: $message');
  }
}
