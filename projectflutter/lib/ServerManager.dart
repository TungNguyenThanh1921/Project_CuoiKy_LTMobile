import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:projectflutter/Login.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ServerManager
{
  static final ServerManager _instance = ServerManager._internal();
  factory ServerManager() => _instance;

  WebSocketChannel? _channel;
  String IpAddress = '';
  ServerManager._internal();

  void connect(String ipAddress) {
    _channel = IOWebSocketChannel.connect('ws://$ipAddress:9090');
    IpAddress = ipAddress;
  }

  WebSocketChannel? get channel => _channel;

  void dispose() {
    _channel?.sink.close();
  }
}