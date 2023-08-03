import 'dart:convert';
import 'dart:typed_data';

class Messages {
  late final int id;
  late final int conversation_id;
  late final int sender_id;
  late final String content;
  late final Uint8List? image;
  late final DateTime? sent_at;
  Messages({
    required this.id,
    required this.conversation_id,
    required this.sender_id,
    required this.content,
    required this.image,
    required this.sent_at,
  });

  factory Messages.fromJson(Map<String, dynamic> json) {
    return Messages(
      id: json['message_id'] as int,
      conversation_id: json['conversation_id'] as int,
      sender_id: json['sender_user_id'] as int,
      content: json['content'] as String,
      image: json['avatar'] != null ? base64Decode(json['avatar']) : null,
      sent_at: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : DateTime.now(),
    );
  }
}
