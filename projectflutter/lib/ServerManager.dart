
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:projectflutter/models/user.dart';

class ServerManager
{
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
  }

  WebSocketChannel? get channel => _channel;
  User? get user => _user;

  void dispose() {
    _channel?.sink.close();
  }
}