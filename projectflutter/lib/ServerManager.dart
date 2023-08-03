
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:projectflutter/models/user.dart';

class ServerManager
{
  Uint8List? imageDefault;
  Future<void> getImageBytesFromAssets(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    Uint8List a =  data.buffer.asUint8List();
    imageDefault = a;
  }
  static final ServerManager _instance = ServerManager._internal();
  factory ServerManager() => _instance;
  User? _user;
  WebSocketChannel? _channel;
  String IpAddress = '';
  ServerManager._internal();
  void InitUser(User tempUser)
  {
    _user = tempUser;
  }
  void connect(String ipAddress) {
    _channel = IOWebSocketChannel.connect('ws://$ipAddress:9090');
    IpAddress = ipAddress;
    getImageBytesFromAssets('assets/images/default_image.jpg');
  }

  WebSocketChannel? get channel => _channel;
  User? get user => _user;
  Uint8List? get img_default => imageDefault;
  void dispose() {
    _channel?.sink.close();
  }
}