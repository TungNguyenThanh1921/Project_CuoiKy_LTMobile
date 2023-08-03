import 'dart:convert';
import 'dart:typed_data';

class Conversation {
  late final int id;
  late final String name;
  late final int user_id;
  late final DateTime create_at;
  late final bool is_private;

  Conversation({
    required this.id,
    required this.name,
    required this.user_id,
    required this.create_at,
    required this.is_private,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['conversation_id'] as int,
      name: json['conversation_name'] as String,
      user_id: json['user_id'] as int,
      create_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      is_private: json['IsPrivate'] as bool,
    );
  }

  Map<String, dynamic> toJson(){ return{

  "image": "assets/images/default_image.jpg",
  "title": name,

  "name": user_id.toString(),

  "date": create_at,

  };
}
}
