class NotificationSetting {
  final int notifyHour;
  final int notifyMinute;
  final String notifyDays; // 예: "1111100"
  final bool enabled;

  NotificationSetting({
    required this.notifyHour,
    required this.notifyMinute,
    required this.notifyDays,
    required this.enabled,
  });

  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    return NotificationSetting(
      notifyHour: json['notify_hour'],
      notifyMinute: json['notify_minute'],
      notifyDays: json['notify_days'],
      enabled: json['enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notify_hour': notifyHour,
      'notify_minute': notifyMinute,
      'notify_days': notifyDays,
      'enabled': enabled,
    };
  }
}
