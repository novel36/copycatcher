class ClipboardItem {
  final String text;
  final String tag;
  final bool favorites;
  final String device;
  final String userId;
  final String userEmail;

  ClipboardItem({
    required this.text,
    required this.tag,
    required this.favorites,
    required this.device,
    required this.userId,
    required this.userEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'tag': tag,
      'favorites': favorites,
      'device': device,
      'user_id': userId,
      'user_email': userEmail,
    };
  }

  factory ClipboardItem.fromJson(Map<String, dynamic> json) {
    return ClipboardItem(
      text: json['text'] as String,
      tag: json['tag'] as String,
      favorites: json['favorites'] as bool,
      device: json['device'] as String,
      userId: json['user_id'] as String,
      userEmail: json['user_email'] as String,
    );
  }
}
