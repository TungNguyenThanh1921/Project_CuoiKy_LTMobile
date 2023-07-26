import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:projectflutter/Login.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class InitServer
{
  late final String IpAddress;
  late final WebSocketChannel channel;

  InitServer(this.IpAddress) {
    channel = IOWebSocketChannel.connect('ws://$IpAddress:9090');

  }
}