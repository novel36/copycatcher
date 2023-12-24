class ClipboardEntry {
  final String content;
  final DateTime timestamp;

  ClipboardEntry({required this.content, required this.timestamp});

  @override
  String toString() =>
      'ClipboardEntry(content: $content, timestamp: $timestamp)';
}

class ClipboardData {
  final String text;
  final DateTime timestamp;

  ClipboardData({required this.text, required this.timestamp});

  factory ClipboardData.fromJson(Map<String, dynamic> json) {
    return ClipboardData(
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };
}
