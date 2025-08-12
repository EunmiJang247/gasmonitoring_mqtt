import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:io' show Platform; // 플랫폼 판별
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/services/notification_service.dart';
import 'package:meditation_friend/services/threshold_settings.dart';
import 'package:fl_chart/fl_chart.dart';

class MqttGraph extends StatefulWidget {
  const MqttGraph({super.key});
  @override
  State<MqttGraph> createState() => _MqttGraphState();
}

class _Reading {
  final double? temp;
  final double? hum;
  const _Reading({this.temp, this.hum});
}

class _MqttGraphState extends State<MqttGraph> {
  double? _tempMin, _tempMax, _humMin, _humMax;
  // ====== 여기만 필요 시 바꾸면 됨 ======
  static const int _port = 1883; // Docker로 연 브로커: 1883
  static const bool _useTls = false; // 로컬 Docker는 TLS 없음
  static String get _clientId =>
      'mf_${DateTime.now().millisecondsSinceEpoch}'; // 유니크 권장
  static const String _topic = 'home/seoul/livingroom/tempSensor/001/data';
  static const String? _username = null; // 필요시 입력
  static const String? _password = null; // 필요시 입력
  static const int _keepAlive = 30;

  // 후보 호스트들 (환경별 우선순위)
  static List<String> get _hostCandidates {
    final list = <String>[];
    // 실행 환경에 따라 우선순위
    try {
      if (Platform.isAndroid)
        list.addAll(['10.0.2.2', '127.0.0.1']);
      else if (Platform.isIOS)
        list.addAll(['localhost', '127.0.0.1']);
      else
        list.addAll(['localhost', '127.0.0.1']);
    } catch (_) {
      list.addAll(['localhost']);
    }
    // 실기기 테스트용: 맥북 IP
    list.add('192.168.0.241');
    return list.toSet().toList(); // 중복 제거
  }

  late MqttServerClient _client;

  final _temps = <double>[];
  final _hums = <double>[];
  final _rawLogs = <String>[];

  static const int _maxPoints = 160;
  double? _latestTemp;
  double? _latestHum;
  String _stateText = 'Connecting…';
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _sub;
  bool _disposed = false;
  int _retryAttempt = 0;
  Timer? _retryTimer;
  int _hostIndex = 0;
  String _currentHost = '';

  // 알림 관련
  bool _alertsEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _tryConnectNextHost();
  }

  /// 서비스 초기화
  Future<void> _initializeServices() async {
    await NotificationService.initialize();
    await _loadThresholds();
    print('🔔 Notification service initialized');
  }

  Future<void> _loadThresholds() async {
    final tMin = await ThresholdSettings.getTempMinThreshold();
    final tMax = await ThresholdSettings.getTempMaxThreshold();
    final hMin = await ThresholdSettings.getHumMinThreshold();
    final hMax = await ThresholdSettings.getHumMaxThreshold();
    setState(() {
      _tempMin = tMin;
      _tempMax = tMax;
      _humMin = hMin;
      _humMax = hMax;
    });
  }

  void _tryConnectNextHost() {
    if (_hostIndex >= _hostCandidates.length) {
      _stateText = 'All hosts failed. Check IP/port/firewall.';
      setState(() {});
      return;
    }
    _currentHost = _hostCandidates[_hostIndex];
    _stateText = 'Connecting to $_currentHost:$_port…';
    setState(() {});
    _client = MqttServerClient.withPort(
        _currentHost, _clientId, _useTls ? 8883 : _port)
      ..logging(on: true) // 진단 로그 ON
      ..keepAlivePeriod = _keepAlive
      ..connectTimeoutPeriod = 5000 // 5s 타임아웃
      ..setProtocolV311(); // ★ MQTT 3.1.1 사용 (중요!)
    _connect(_currentHost);
  }

  Future<void> _connect(String host) async {
    _client.onConnected = () {
      print('✅ MQTT Connected to $_currentHost');
      _stateText = 'Connected ($_currentHost)';
      _retryAttempt = 0;
      setState(() {});

      // 연결 성공 후 구독
      _client.subscribe(_topic, MqttQos.atMostOnce);
      _sub?.cancel();
      _sub = _client.updates?.listen((events) {
        for (final e in events) {
          final msg = e.payload as MqttPublishMessage;
          final bytes = msg.payload.message;
          final text = utf8.decode(bytes);
          print('📨 Received: $text');

          final r = _parseReading(text); // {temp, hum}
          if (!_disposed) {
            _rawLogs.insert(0, text);
            if (_rawLogs.length > 100) _rawLogs.removeLast();

            if (r.temp != null) {
              _latestTemp = r.temp;
              _temps.add(r.temp!);
              if (_temps.length > _maxPoints) {
                _temps.removeRange(0, _temps.length - _maxPoints);
              }
              // 온도 임계치 체크
              _checkTemperatureThreshold(r.temp!);
            }

            if (r.hum != null) {
              _latestHum = r.hum;
              _hums.add(r.hum!);
              if (_hums.length > _maxPoints) {
                _hums.removeRange(0, _hums.length - _maxPoints);
              }
              // 습도 임계치 체크
              _checkHumidityThreshold(r.hum!);
            }

            setState(() {});
          }
        }
      });
    };

    _client.onDisconnected = () {
      print('❌ MQTT Disconnected from $_currentHost');
      _stateText = 'Disconnected ($_currentHost)';
      setState(() {});
      if (!_disposed) _scheduleReconnect(); // 같은 host로 재시도
    };

    _client.onSubscribed = (topic) {
      print('📡 Subscribed to $topic');
    };

    if (_useTls) {
      _client.secure = true;
      _client.onBadCertificate = (_) => true; // 로컬 테스트용
    }

    final conn = MqttConnectMessage()
        .withClientIdentifier(_clientId)
        .startClean()
        .keepAliveFor(_keepAlive)
        .withWillQos(MqttQos.atLeastOnce)
        .withProtocolVersion(
            MqttClientConstants.mqttV311ProtocolVersion); // ★ MQTT 3.1.1 명시
    _client.connectionMessage = conn;

    try {
      print('🔄 Attempting to connect to $_currentHost:$_port');
      await _client.connect(_username, _password);

      final status = _client.connectionStatus;
      print(
          '📊 Connection status: ${status?.state}, return code: ${status?.returnCode}');

      if (status?.state != MqttConnectionState.connected) {
        _stateText =
            'Failed on $_currentHost (${status?.state}) rc=${status?.returnCode}';
        setState(() {});
        // 다음 후보 호스트로 넘어가기
        _hostIndex++;
        await Future.delayed(Duration(seconds: 1)); // 잠시 대기
        _tryConnectNextHost();
      }
    } catch (e) {
      print('💥 Connection error: $e');
      _stateText = 'Error on $_currentHost: $e';
      setState(() {});
      // 다음 후보 호스트로 넘어가기
      _hostIndex++;
      await Future.delayed(Duration(seconds: 1)); // 잠시 대기
      _tryConnectNextHost();
    }
  }

  void _scheduleReconnect() {
    if (_retryAttempt >= 3) {
      // 3번 실패하면 다음 호스트로 넘어가기
      print('🔄 Max retries reached for $_currentHost, trying next host');
      _retryAttempt = 0;
      _hostIndex++;
      _tryConnectNextHost();
      return;
    }

    _retryAttempt = math.min(_retryAttempt + 1, 5);
    final delay = [2, 4, 8, 16, 30][_retryAttempt - 1];
    _stateText =
        'Reconnecting to $_currentHost in ${delay}s… (${_retryAttempt}/3)';
    setState(() {});
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delay), () {
      if (!_disposed) {
        print(
            '🔄 Retrying connection to $_currentHost (attempt $_retryAttempt)');
        try {
          _client.disconnect();
        } catch (_) {}

        _client = MqttServerClient.withPort(
            _currentHost, _clientId, _useTls ? 8883 : _port)
          ..logging(on: true)
          ..keepAlivePeriod = _keepAlive
          ..connectTimeoutPeriod = 5000
          ..setProtocolV311(); // ★ MQTT 3.1.1 사용
        _connect(_currentHost); // 같은 host 재시도
      }
    });
  }

  _Reading _parseReading(String text) {
    Map<String, dynamic>? m;
    try {
      final obj = json.decode(text);
      if (obj is Map) m = obj.map((k, v) => MapEntry('$k', v));
    } catch (_) {}
    if (m == null && text.contains("'") && !text.contains('"')) {
      try {
        final obj = json.decode(text.replaceAll("'", '"'));
        if (obj is Map) m = obj.map((k, v) => MapEntry('$k', v));
      } catch (_) {}
    }
    if (m != null) {
      final temp =
          (m['temp'] as num?)?.toDouble() ?? (m['value'] as num?)?.toDouble();
      final hum = (m['hum'] as num?)?.toDouble();
      return _Reading(temp: temp, hum: hum);
    }
    final lone = double.tryParse(text.trim());
    return _Reading(temp: lone, hum: null);
  }

  /// 온도 임계치 체크 및 알림
  Future<void> _checkTemperatureThreshold(double temperature) async {
    if (!_alertsEnabled) return;

    try {
      final tempMin = await ThresholdSettings.getTempMinThreshold();
      final tempMax = await ThresholdSettings.getTempMaxThreshold();
      final cooldown = await ThresholdSettings.getAlertCooldown();

      if (temperature < tempMin || temperature > tempMax) {
        await NotificationService.showTemperatureAlert(
            temperature, tempMin, tempMax, cooldown);
        print(
            '🚨 Temperature alert sent: $temperature°C (범위: $tempMin~$tempMax°C)');
      }
    } catch (e) {
      print('❌ Error checking temperature threshold: $e');
    }
  }

  /// 습도 임계치 체크 및 알림
  Future<void> _checkHumidityThreshold(double humidity) async {
    if (!_alertsEnabled) return;

    try {
      final humMin = await ThresholdSettings.getHumMinThreshold();
      final humMax = await ThresholdSettings.getHumMaxThreshold();
      final cooldown = await ThresholdSettings.getAlertCooldown();

      if (humidity < humMin || humidity > humMax) {
        await NotificationService.showHumidityAlert(
            humidity, humMin, humMax, cooldown);
        print('🚨 Humidity alert sent: $humidity% (범위: $humMin~$humMax%)');
      }
    } catch (e) {
      print('❌ Error checking humidity threshold: $e');
    }
  }

  /// 임계치 설정 다이얼로그 표시 (현재는 간단한 토글만)
  void _showThresholdSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('임계값 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 온도 설정
            Text('온도 범위 (°C)'),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _tempMin?.toString() ?? '18',
                    decoration: InputDecoration(labelText: '최소'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final temp = double.tryParse(value);
                      if (temp != null) _tempMin = temp;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _tempMax?.toString() ?? '28',
                    decoration: InputDecoration(labelText: '최대'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final temp = double.tryParse(value);
                      if (temp != null) _tempMax = temp;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 습도 설정
            Text('습도 범위 (%)'),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _humMin?.toString() ?? '40',
                    decoration: InputDecoration(labelText: '최소'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final hum = double.tryParse(value);
                      if (hum != null) _humMin = hum;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _humMax?.toString() ?? '70',
                    decoration: InputDecoration(labelText: '최대'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final hum = double.tryParse(value);
                      if (hum != null) _humMax = hum;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 설정 저장
              if (_tempMin != null && _tempMax != null) {
                await ThresholdSettings.setTempThresholds(_tempMin!, _tempMax!);
              }
              if (_humMin != null && _humMax != null) {
                await ThresholdSettings.setHumThresholds(_humMin!, _humMax!);
              }
              // setState(() {}); // UI 업데이트
              await _loadThresholds();
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    _sub?.cancel();
    try {
      _client.disconnect();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 상태/현재값
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '관리자님 안녕하세요',
                style: TextStyle(
                  color: AppColors.kBrighYellow,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.normal,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _stateText.startsWith('Connected')
                        ? Colors.greenAccent.withOpacity(0.6)
                        : Colors.orangeAccent.withOpacity(0.6),
                  ),
                ),
                child: Text(
                  '$_stateText  •  $_currentHost:$_port  •  $_topic',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.sp,
                      letterSpacing: 0.2),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_latestTemp != null)
                    Text('Temp: ${_latestTemp!.toStringAsFixed(1)}°C',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600)),
                  if (_latestHum != null) ...[
                    SizedBox(width: 12.w),
                    Text('Hum: ${_latestHum!.toStringAsFixed(0)}%',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
              SizedBox(height: 6.h),
              // 임계값 표시
              if (_tempMin != null &&
                  _tempMax != null &&
                  _humMin != null &&
                  _humMax != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.white24, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '설정된 임계값',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Temp: ${_tempMin!.toStringAsFixed(1)}°C ~ ${_tempMax!.toStringAsFixed(1)}°C',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Hum: ${_humMin!.toStringAsFixed(0)}% ~ ${_humMax!.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 6.h),
              // 알림 상태 및 설정 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 알림 상태 표시
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _alertsEnabled
                          ? Colors.green.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: _alertsEnabled
                            ? Colors.greenAccent.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _alertsEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color:
                              _alertsEnabled ? Colors.greenAccent : Colors.grey,
                          size: 12.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _alertsEnabled ? '알림 활성화' : '알림 비활성화',
                          style: TextStyle(
                            color: _alertsEnabled
                                ? Colors.greenAccent
                                : Colors.grey,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // 설정 버튼
                  GestureDetector(
                    onTap: _showThresholdSettings,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.settings,
                            color: Colors.blueAccent,
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '임계치 설정',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              // 알림 상태 표시
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              //   decoration: BoxDecoration(
              //     color: _alertsEnabled
              //         ? Colors.green.withOpacity(0.2)
              //         : Colors.grey.withOpacity(0.2),
              //     borderRadius: BorderRadius.circular(8.r),
              //     border: Border.all(
              //       color: _alertsEnabled
              //           ? Colors.greenAccent.withOpacity(0.5)
              //           : Colors.grey.withOpacity(0.5),
              //     ),
              //   ),
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Icon(
              //         _alertsEnabled
              //             ? Icons.notifications_active
              //             : Icons.notifications_off,
              //         color: _alertsEnabled ? Colors.greenAccent : Colors.grey,
              //         size: 12.sp,
              //       ),
              //       SizedBox(width: 4.w),
              //       Text(
              //         _alertsEnabled ? '알림 활성화' : '알림 비활성화',
              //         style: TextStyle(
              //           color:
              //               _alertsEnabled ? Colors.greenAccent : Colors.grey,
              //           fontSize: 10.sp,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(
              //   height: 8,
              // )
            ],
          ),

          // 그래프 카드
          Container(
            margin: EdgeInsets.only(left: 14.w),
            padding: EdgeInsets.all(12.w),
            height: 140.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x3325F0FF), Color(0x3311C5D9)],
              ),
              border: Border.all(color: Colors.white24, width: 0.8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 16,
                    offset: Offset(0, 6))
              ],
            ),
            child: _temps.isEmpty
                ? Center(
                    child: Text(
                      '메시지를 기다리는 중…\n($_topic)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                  )
                // : CustomPaint(
                //     painter: _SparklinePainter(_temps),
                //     child: Align(
                //       alignment: Alignment.bottomRight,
                //       child: Padding(
                //         padding: EdgeInsets.only(top: 8.h),
                //         child: Text(
                //           '${_temps.last.toStringAsFixed(1)}°C',
                //           style: TextStyle(
                //             color: AppColors.kBrighYellow,
                //             fontSize: 18.sp,
                //             fontWeight: FontWeight.bold,
                //             shadows: const [
                //               Shadow(blurRadius: 6, color: Colors.black54)
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // : LineChart(
                //     _buildLineChartData(
                //       _temps,
                //       color: Colors.cyanAccent,
                //       labelSuffix: '°C',
                //       minLine: _tempMin,
                //       maxLine: _tempMax,
                //       maxPoints: _maxPoints,
                //     ),
                //   ),
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20.r), // 카드와 동일
                    child: LineChart(
                      _buildLineChartData(
                        _temps,
                        color: Colors.cyanAccent,
                        labelSuffix: '°C',
                        minLine: _tempMin,
                        maxLine: _tempMax,
                        maxPoints: _maxPoints,
                      ),
                    ),
                  ),
          ),

          SizedBox(height: 20.h),

          // 습도 그래프 카드
          Container(
            margin: EdgeInsets.only(left: 14.w),
            padding: EdgeInsets.all(12.w),
            height: 140.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x3325FF25), Color(0x3311D959)],
              ),
              border: Border.all(color: Colors.white24, width: 0.8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 16,
                    offset: Offset(0, 6))
              ],
            ),
            child: _hums.isEmpty
                ? Center(
                    child: Text(
                      '습도 데이터 대기중…\n($_topic)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                  )
                // : CustomPaint(
                //     painter: _HumidityPainter(_hums),
                //     child: Align(
                //       alignment: Alignment.bottomRight,
                //       child: Padding(
                //         padding: EdgeInsets.only(top: 8.h),
                //         child: Text(
                //           '${_hums.last.toStringAsFixed(0)}%',
                //           style: TextStyle(
                //             color: Colors.greenAccent,
                //             fontSize: 18.sp,
                //             fontWeight: FontWeight.bold,
                //             shadows: const [
                //               Shadow(blurRadius: 6, color: Colors.black54)
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                : LineChart(
                    _buildLineChartData(
                      _hums,
                      color: Colors.greenAccent,
                      labelSuffix: '%',
                      minLine: _humMin,
                      maxLine: _humMax,
                      maxPoints: _maxPoints,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

LineChartData _buildLineChartData(
  List<double> series, {
  required Color color,
  required String labelSuffix,
  double? minLine,
  double? maxLine,
  required int maxPoints, // maxPoints를 매개변수로 전달
}) {
  if (series.isEmpty) {
    return LineChartData(
      lineBarsData: [],
      titlesData: const FlTitlesData(show: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    );
  }

  final n = series.length;
  final maxPointsDouble = maxPoints.toDouble(); // 전달받은 매개변수 사용

  // X축을 전체 범위에 균등하게 분배
  final spots = <FlSpot>[];
  for (int i = 0; i < n; i++) {
    // 데이터를 오른쪽부터 채우기 (최신 데이터가 오른쪽에 위치)
    final x = maxPointsDouble - (n - 1 - i);
    spots.add(FlSpot(x, series[i]));
  }

  // 값 + 임계치 모두 포함하도록 y범위 계산
  double yMin = series.reduce(math.min);
  double yMax = series.reduce(math.max);
  if (minLine != null) yMin = math.min(yMin, minLine);
  if (maxLine != null) yMax = math.max(yMax, maxLine);
  final pad = (yMax - yMin).abs() < 1e-6 ? 1.0 : (yMax - yMin) * 0.12;
  yMin -= pad;
  yMax += pad;

  return LineChartData(
    minX: 0,
    maxX: maxPointsDouble,
    minY: yMin,
    maxY: yMax,
    gridData: FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: false,
      horizontalInterval:
          ((yMax - yMin) / 4).abs() < 1e-6 ? 1.0 : (yMax - yMin) / 4,
      getDrawingHorizontalLine: (v) => FlLine(
        color: Colors.white24,
        strokeWidth: 0.6,
      ),
    ),
    titlesData: FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: ((yMax - yMin) / 4).abs() < 1e-6 ? 1.0 : (yMax - yMin) / 4,
          getTitlesWidget: (value, meta) {
            return Text(
              '${value.toStringAsFixed(1)}$labelSuffix',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    borderData: FlBorderData(show: false),
    lineBarsData: [
      LineChartBarData(
        spots: spots,
        isCurved: series.length >= 6, // 데이터 6개 전까진 직선
        curveSmoothness: 0.15, // 기본(0.35)보다 낮춰 과도한 꺾임 완화
        preventCurveOverShooting: true,
        color: color,
        barWidth: 2.2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.35), color.withOpacity(0.0)],
          ),
        ),
      ),
    ],
    extraLinesData: ExtraLinesData(
      // 임계치를 그리는 부분
      horizontalLines: [
        if (minLine != null)
          HorizontalLine(
            y: minLine,
            color: Colors.amberAccent,
            strokeWidth: 2,
            dashArray: [6, 4],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 6),
              style: const TextStyle(color: Colors.amberAccent, fontSize: 10),
              labelResolver: (_) =>
                  'MIN ${minLine.toStringAsFixed(1)}$labelSuffix',
            ),
          ),
        if (maxLine != null)
          HorizontalLine(
            y: maxLine,
            color: Colors.amberAccent,
            strokeWidth: 2,
            dashArray: [6, 4],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 6),
              style: const TextStyle(color: Colors.amberAccent, fontSize: 10),
              labelResolver: (_) =>
                  'MAX ${maxLine.toStringAsFixed(1)}$labelSuffix',
            ),
          ),
      ],
    ),
    lineTouchData: LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => Colors.black87,
        fitInsideVertically: true,
        fitInsideHorizontally: true,
        getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
          final v = s.y.toStringAsFixed(labelSuffix == '%' ? 0 : 1);
          return LineTooltipItem(
              '$v$labelSuffix', const TextStyle(color: Colors.white));
        }).toList(),
      ),
    ),
  );
}
