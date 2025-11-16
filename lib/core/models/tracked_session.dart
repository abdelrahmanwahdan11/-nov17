import 'dart:convert';

class TrackedSession {
  TrackedSession({
    required this.id,
    required this.duration,
    required this.timestamp,
    this.taskId,
    this.taskTitle,
  });

  final String id;
  final String? taskId;
  final String? taskTitle;
  final Duration duration;
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'durationSeconds': duration.inSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TrackedSession.fromJson(Map<String, dynamic> json) {
    return TrackedSession(
      id: json['id'] as String,
      taskId: json['taskId'] as String?,
      taskTitle: json['taskTitle'] as String?,
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static TrackedSession fromEncoded(String value) {
    return TrackedSession.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  String encode() => jsonEncode(toJson());
}
