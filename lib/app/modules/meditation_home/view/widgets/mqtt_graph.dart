import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:io' show Platform; // 플랫폼 판별
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:meditation_friend/app/constant/app_color.dart';

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

  @override
  void initState() {
    super.initState();
    _tryConnectNextHost();
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
            }
            if (r.hum != null) {
              _latestHum = r.hum;
              _hums.add(r.hum!);
              if (_hums.length > _maxPoints) {
                _hums.removeRange(0, _hums.length - _maxPoints);
              }
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
              )
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
                : CustomPaint(
                    painter: _SparklinePainter(_temps),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          '${_temps.last.toStringAsFixed(1)}°C',
                          style: TextStyle(
                            color: AppColors.kBrighYellow,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(blurRadius: 6, color: Colors.black54)
                            ],
                          ),
                        ),
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
                : CustomPaint(
                    painter: _HumidityPainter(_hums),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          '${_hums.last.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(blurRadius: 6, color: Colors.black54)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  _SparklinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV).abs() < 1e-9 ? 1.0 : (maxV - minV);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * (size.width / (values.length - 1));
      final norm = (values[i] - minV) / span;
      final y = size.height * (1 - norm);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }

    final linePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x6625F0FF), Color(0x0025F0FF)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, Paint()..shader = shader);

    final lastX = size.width;
    final lastNorm = (values.last - minV) / span;
    final lastY = size.height * (1 - lastNorm);
    canvas.drawCircle(
        Offset(lastX, lastY), 3.5, Paint()..color = Colors.amberAccent);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      !identical(oldDelegate.values, values);
}

class _HumidityPainter extends CustomPainter {
  final List<double> values;
  _HumidityPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV).abs() < 1e-9 ? 1.0 : (maxV - minV);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * (size.width / (values.length - 1));
      final norm = (values[i] - minV) / span;
      final y = size.height * (1 - norm);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }

    final linePaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x6625FF25), Color(0x0025FF25)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, Paint()..shader = shader);

    final lastX = size.width;
    final lastNorm = (values.last - minV) / span;
    final lastY = size.height * (1 - lastNorm);
    canvas.drawCircle(
        Offset(lastX, lastY), 3.5, Paint()..color = Colors.lightGreenAccent);
  }

  @override
  bool shouldRepaint(covariant _HumidityPainter oldDelegate) =>
      !identical(oldDelegate.values, values);
}
