class Schedule {
  final String dayOfWeek;
  final String openTime;
  final String closeTime;

  Schedule(
      {required this.dayOfWeek,
      required this.openTime,
      required this.closeTime});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      dayOfWeek: json['day_of_week'],
      openTime: json['open_time'],
      closeTime: json['close_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'open_time': openTime,
      'close_time': closeTime,
    };
  }
}
