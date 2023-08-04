
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:projectflutter/models/conversation.dart';
import 'package:projectflutter/models/messages.dart';
import 'package:projectflutter/presentation/chats_screen/chats_screen.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:projectflutter/models/user.dart';

import 'Views/Login.dart';
typedef void ChatRoomReloadCallback(dynamic message);
class ServerManager
{
  Uint8List? imageDefault;


  VoidCallback? onChatRoomReload;

  // Phương thức để đăng ký callback
  void registerChatRoomReloadCallback(VoidCallback callback) {
    onChatRoomReload = callback;
  }

  // Biến để lưu trữ callback function
  ChatRoomReloadCallback? _onChatRoomReload;

  // Hàm để đăng ký callback
  void registerChatRoomCallback(ChatRoomReloadCallback callback) {
    _onChatRoomReload = callback;
  }

  void callChatRoomCallback(dynamic message) {
    if (_onChatRoomReload != null) {
      _onChatRoomReload!(message);
    }
  }

  Future<void> getImageBytesFromAssets(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    Uint8List a =  data.buffer.asUint8List();
    imageDefault = a;
  }
  static final ServerManager _instance = ServerManager._internal();
  factory ServerManager() => _instance;

  WebSocketChannel? _channel;
  String IpAddress = '';
  ServerManager._internal();

  User? _user;
  void InitUser(User tempUser)
  {
    _user = tempUser;
  }
  User? get user => _user;

  List<User>? _list_user;
  void InitListUser(List<User> tempUser)
  {
    _list_user =List.from(tempUser);
  }
  List<User>? get list_user => _list_user;


  List<Conversation>? _conversation;
  void InitConversation(List<Conversation> temp)
  {
    _conversation = List.from(temp);
  }
  List<Conversation>? get conversation => _conversation;

  List<Messages>? _messages;
  void InitMessages(List<Messages> temp)
  {
    _messages = List.from(temp);
  }
  List<Messages>? get messages => _messages;
  int OnRoomNumber = -1;
  bool isUpdateNeeded = false;
  void setUpdateNeeded(bool value) {
    isUpdateNeeded = value;
  }
  void connect(String ipAddress) {
    _channel = IOWebSocketChannel.connect('ws://$ipAddress:9090');
    _channel?.stream.listen((message) {
      // Xử lý các thông báo từ server
      // Ví dụ: Cập nhật dữ liệu từ thông báo 'update-conversation'
      if (message == 'update-conversation') {
        // Gọi hàm để lấy dữ liệu mới từ server và cập nhật vào singleton
        //fetchAndSaveConversation();
        String newsql = "Select * from Conversation";
        Frame10().InitRooms(newsql);
        onChatRoomReload?.call();

        // if(isOnChatScreen)
          //   {
          //       ChatsScreen(OwnListConversation: Frame10().GetConverSation());
          //   }
      }
      else {
        if (OnRoomNumber != -1)
      {
        callChatRoomCallback(message);
      }

      }
    });
    IpAddress = ipAddress;
    getImageBytesFromAssets('assets/images/default_image.jpg');
  }

  WebSocketChannel? get channel => _channel;

  Uint8List? get img_default => imageDefault;
  void dispose() {
    _channel?.sink.close();
  }


  //// a lot of function to get information

  String? getNameRoom(int id)
  {
    for(var data in conversation!)
    {
      if(data.id == id)
      {
        return data.name;
      }
    }
    return null;
  }

  String? getNameUser(int id)
  {
    for(var data in _list_user!)
      {
        if(data.id == id)
          {
            return data.userName;
          }
      }
    return null;
  }

  Uint8List? getAvatarUser(int id)
  {
    for(var data in _list_user!)
    {
      if(data.id == id)
      {
        if(data.image == null)
          {
            return imageDefault;
          }
        return data.image;
      }
    }
    return null;
  }
}