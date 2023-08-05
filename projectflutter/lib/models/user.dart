import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

 class User {
late final int id;
late final String userName;
late final String email;
late final String password;
Uint8List? image;

User( {required this.id, required  this.userName, required  this.email, required  this.password, this.image});

factory User.fromJson(Map<String, dynamic> json) {
 return User(
 id: json['user_id'] as int,
 userName: json['username'] as String,
 email: json['email'] as String,
 password: json['password'] as String,
  image: json['avatar']  != null ? Uint8List.fromList(base64.decode(json['avatar'])) : null,

  // Parse other columns here
 );
}
}
