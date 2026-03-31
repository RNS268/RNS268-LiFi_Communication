class EspLog {
  const EspLog({
    required this.message,
    required this.timestamp,
    required this.status,
  });

  final String message;
  final DateTime timestamp;
  final String status;

  Map<String, dynamic> toJson() => {
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  factory EspLog.fromJson(Map<String, dynamic> json) {
    return EspLog(
      message: (json['message'] as String?) ?? '',
      timestamp: DateTime.tryParse((json['timestamp'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      status: (json['status'] as String?) ?? '',
    );
  }
}

