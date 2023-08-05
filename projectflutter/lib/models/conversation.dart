import 'dart:convert';
import 'dart:typed_data';

import 'package:projectflutter/ServerManager.dart';

class Conversation {
  late final int id;
  late final String name;
  late final int user_id;
  late final int participant_id;
  late final DateTime create_at;
  late final bool is_private;

  Conversation({
    required this.id,
    required this.name,
    required this.user_id,
    required this.participant_id,
    required this.create_at,
    required this.is_private,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['conversation_id'] as int,
      name: json['conversation_name'] as String,
      user_id: json['user_id'] as int,
      participant_id: json['participant_id'] != null ? json['participant_id'] : -1,
      create_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      is_private: json['IsPrivate'] as bool,
    );
  }

  Map<String, dynamic> toJson(){ return{
  "image": is_private == true ? (ServerManager().getAvatarUser(participant_id) != null ?   ServerManager().getAvatarUser(participant_id) :  ServerManager().img_default) : ServerManager().img_default,
  "title": is_private == true ? (user_id == ServerManager().user?.id ? ServerManager().getNameUser(participant_id)  : ServerManager().getNameUser(user_id) ): name,

  "name":'you: ${ServerManager().user?.userName}',

  "date": create_at,
    "id_room": id,
  };
}
}
