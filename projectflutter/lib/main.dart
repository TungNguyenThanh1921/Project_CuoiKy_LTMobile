import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projectflutter/Views/screenImageView.dart';
import 'package:projectflutter/models/messages.dart';
import 'package:projectflutter/presentation/chats_screen/chats_screen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io';
import 'package:projectflutter/ServerManager.dart';
import 'package:projectflutter/Views/Login.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: IPAddressScreen(),
    );
  }
}

class IPAddressScreen extends StatefulWidget {
  @override
  _IPAddressScreenState createState() => _IPAddressScreenState();
}

class _IPAddressScreenState extends State<IPAddressScreen> {
  final TextEditingController _ipAddressController = TextEditingController();
  // test github
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter IP Address')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _ipAddressController,
              decoration: InputDecoration(hintText: 'Enter IPv4 Of Server Address'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String ipAddress = _ipAddressController.text.trim();
                ServerManager().connect(ipAddress);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                   // builder: (context) => ChatApp(ipAddress: ipAddress),
                      builder: (context) => Login()
                  ),
                );
              },
              child: Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatApp extends StatefulWidget {
  final int id_room;
  ChatApp({required this.id_room});
  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {

  late final ScrollController _scrollController = ScrollController();
  late final WebSocketChannel channel;
  final TextEditingController _textController = TextEditingController();
  List<Message> messages = [];
  String clientName = '';
  List<String> chatSamples = [];
  String selectedChatSample = '';
  String ipAddress = '...';
  PickedFile? _pickedImage;
  @override
  void dispose() {
    ServerManager().OnRoomNumber = -1;
    super.dispose();
  }
  Future<void> SaveMessageToDataBase(String sqlStatement) async {
    final url = Uri.parse('http://${ServerManager().IpAddress}:8080/GetData?sql=${Uri.encodeQueryComponent(sqlStatement)}');
    //final Uri url = Uri.parse('$serverAddress');
    final response = await http.get(url);

    if (response.statusCode == 200) {

    } else {
      print('Lỗi khi gọi API: ${response.statusCode}');
    }

  }
  void InitMessageInRoom()  {
      //intit own client name
      clientName = ServerManager().user!.userName;
      List<Messages> mss = List.from( ServerManager().messages!);
      if(ServerManager().messages!.length > 0)
        {
          List<Message> list_message_inroom = [];
          for (Messages data in ServerManager().messages!)
          {
            if(data.conversation_id == widget.id_room)
              {
                Message temp;
                String? name = ServerManager().getNameUser(data.sender_id);
                if(data.content != null && data.content.isNotEmpty)
                  {
                    temp = Message(MessageType.text, data.content, null, senderName: name!, timestamp: data.sent_at!,avatar: ServerManager().getAvatarUser(data.sender_id));
                  }
                else
                  {
                    temp = Message(MessageType.image, null, data.image ,senderName: name!, timestamp: data.sent_at!, avatar: ServerManager().getAvatarUser(data.sender_id));
                  }

                list_message_inroom.add(temp);
              }
          }
          messages = List.from(list_message_inroom);
        }

  }


  @override
  void initState() {
    super.initState();
    ServerManager().OnRoomNumber = widget.id_room;
    InitMessageInRoom();
    ServerManager().registerChatRoomCallback(_onChatRoomReload);
    //channel = IOWebSocketChannel.connect('ws://${widget.ipAddress}:9090');


    _loadMessages();

  }
  void _onChatRoomReload(dynamic data) {
      if (data is List<int>) {

      }  else if (data is String) {
        // Xử lý dữ liệu nhận được từ server là JSON
        try {
          final jsonData = jsonDecode(data);
          final avatar_sender = jsonData['userId'];
          final type = jsonData['type'];
          final content = jsonData['content'];
          final roomId = jsonData['roomId'];

          // Check if the message is for the current room
          if (roomId == widget.id_room.toString()) {
            if (type == 'text') {
              final message = Message(
                MessageType.text,
                content as String,
                null,
                senderName: 'Receiver',
                timestamp: DateTime.now(),
                avatar: ServerManager().getAvatarUser(avatar_sender),
              );
              setState(() {
                messages.add(message);
              });
            } else if (type == 'image') {
              final imageBytes = base64Decode(content as String);
              final message = Message(
                MessageType.image,
                null,
                imageBytes,
                senderName: 'Receiver',
                timestamp: DateTime.now(),
                avatar: ServerManager().getAvatarUser(avatar_sender),
              );
              setState(() {
                messages.add(message);
              });
            } else {
              print('Received unexpected data format: $type');
            }

            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            print('Received message from another room.');
          }
        } catch (e) {
          print('Error parsing JSON: $e');
        }
      }

  }
  Future<void> sendMessage(String message, PickedFile? image) async {
    if (message.isEmpty && image == null) return;
    final data = {
      'userId': ServerManager().user!.id,
      'type': 'text', // Hoặc 'image' nếu bạn muốn gửi tin nhắn hình ảnh
      'roomId': '${widget.id_room}',
      'content': message,
    };
    if (image != null) {
      final bytes = File(image.path).readAsBytesSync();
      data['type'] = 'image';
      data['content'] = base64Encode(bytes);
      ServerManager().channel?.sink.add(json.encode(data));
      final formattedMessage = Message(MessageType.image, null, bytes, senderName: clientName, timestamp: DateTime.now(), avatar: ServerManager().getAvatarUser(ServerManager().user!.id));
      final response = await http.post(
        Uri.parse('http://${ServerManager().IpAddress}:8080/updateImageMesseges'),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        // Avatar updated successfully, set the avatar for the user
        setState(() {
          messages.add(formattedMessage);
        });
      } else {
        // Handle the case where avatar update failed
        print('Error updating avatar: ${response.statusCode}');
      }
     String sql = "INSERT INTO Message (conversation_id, sender_user_id, content, img) VALUES (${widget.id_room}, ${ServerManager().user!.id}, NULL, ${base64Encode(bytes)})";
      //SaveMessageToDataBase(sql);
    } else {
      final ms = json.encode(data);
      ServerManager().channel?.sink.add(ms);
      final formattedMessage = Message(MessageType.text, message,null ,senderName: clientName, timestamp: DateTime.now(), avatar: ServerManager().getAvatarUser(ServerManager().user!.id));
      setState(() {
        messages.add(formattedMessage);
      });

      String sql = "INSERT INTO Message (conversation_id, sender_user_id, content, img) VALUES (${widget.id_room}, ${ServerManager().user!.id}, N'${message.toString()}',NULL)";
      SaveMessageToDataBase(sql);
    }

    _textController.clear();
    setState(() {
      _pickedImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sent message: ${image != null ? "Sent an image" : message}')),
    );
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      _pickedImage = pickedImage;
    });
  }

  bool isSentMessage(Message message) {
    return message.senderName == clientName;
  }

  String _formatTimestamp(DateTime timestamp) {
    final formattedTime = '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  Widget _buildAvatar(String senderName) {
    return CircleAvatar(
      child: Text(senderName[0]), // Hiển thị chữ cái đầu của tên người gửi như avatar
      backgroundColor: Colors.blue, // Màu nền của avatar
    );
  }

  Widget _buildMessageItem(Message message) {
    final isSent = isSentMessage(message);
    final bgColor = isSent ? Colors.blue : Colors.grey[300];
    final align = isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isSent
        ? BorderRadius.only(
      topLeft: Radius.circular(12.0),
      bottomLeft: Radius.circular(12.0),
      bottomRight: Radius.circular(12.0),
    )
        : BorderRadius.only(
      topRight: Radius.circular(12.0),
      bottomLeft: Radius.circular(12.0),
      bottomRight: Radius.circular(12.0),
    );

    if (message.type == MessageType.image) {
      final imageBytes = message.image;
      return GestureDetector(
        onTap: () => _onImageTap(context, base64Encode(message.image as List<int>) ), // Pass the base64 image to the function
        child: Container(
          alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isSent) // Nếu căn trái (không gửi tin nhắn), thêm khung avatar trước text
                Container(
                  margin: EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundImage: MemoryImage(message.avatar as Uint8List), // Thay bằng ảnh đại diện của bạn
                  ),
                ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: radius,
                ),
                child: Column(
                  crossAxisAlignment: align,
                  children: [
                    Image.memory(imageBytes as Uint8List, height: 150, width: 150),
                    SizedBox(height: 4),
                    Text(
                      _formatTimestamp(message.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.black),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
              if (isSent) // Nếu căn phải (gửi tin nhắn), thêm khung avatar sau text
                Container(
                  margin: EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    backgroundImage: MemoryImage(message.avatar as Uint8List), // Thay bằng ảnh đại diện của bạn
                  ),
                ),
            ],
          ),
        ),
      );
    } else if (message.type == MessageType.text) {
      return Container(
        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isSent) // Nếu căn trái (không gửi tin nhắn), thêm khung avatar trước text
              Container(
                margin: EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundImage: MemoryImage(message.avatar as Uint8List), // Thay bằng ảnh đại diện của bạn
                ),
              ),
            Flexible( // Sử dụng Flexible để giới hạn không gian của Container cha
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20.0), // Đặt bán kính bo tròn là 20.0 (có thể thay đổi theo ý muốn)
                ),
                child: Column(
                  crossAxisAlignment: align,
                  children: [
                    Text(
                      message.content as String,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      textAlign: align == CrossAxisAlignment.end ? TextAlign.end : TextAlign.start,
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatTimestamp(message.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.black),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ),
            if (isSent) // Nếu căn phải (gửi tin nhắn), thêm khung avatar sau text
              Container(
                margin: EdgeInsets.only(left: 8.0),
                child: CircleAvatar(
                  backgroundImage: MemoryImage(message.avatar as Uint8List), // Thay bằng ảnh đại diện của bạn
                ),
              ),
          ],
        ),
      );


    } else {
      return Container();
    }
  }

  void _onImageTap(BuildContext context, String base64Image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewScreen(context, base64Image), // Pass the BuildContext
      ),
    );
  }


  Widget _buildImageThumbnail() {
    if (_pickedImage != null) {
      return SizedBox(
        height: 40,
        width: 40,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(File(_pickedImage!.path)),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.clear, color: Colors.white, size: 20),
                onPressed: () {
                  setState(() {
                    _pickedImage = null;
                  });
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  void _loadMessages() {
    // Simulate loading your list of messages
    List<Message> messages = this.messages; // Replace this with your actual loading logic

    // After loading messages, scroll to the end
    WidgetsBinding.instance?.addPostFrameCallback((_) {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // or use animateTo for smooth scrolling
    // _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: Scaffold(
        appBar:AppBar(
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatsScreen(OwnListConversation: Frame10().GetConverSation()),
                    ),
                  );
                  // Xử lý sự kiện khi nhấn nút trở về
                },
              ),
              Expanded(child: Container()), // Khoảng trống giữa IconButton và Text
              Text(ServerManager().getNameRoom(widget.id_room) as String), // Văn bản 'Title' nằm bên phải
            ],
          ),
        ),

        body:
        Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageItem(message);
                },
              ),
            ),
            Container(

              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Nhập nội dung...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      final message = _textController.text;
                      sendMessage(message, _pickedImage);
                    },
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.image, color: Colors.blue),
                    onPressed: _pickImage,
                  ),
                  _buildImageThumbnail(),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

enum MessageType {
  text,
  image,
}

class Message {
  MessageType type;
  String? content;
  Uint8List? image;
  String senderName;
  DateTime timestamp;
  Uint8List? avatar;
  Message(this.type, this.content, this.image,{required this.senderName, required this.timestamp, required this.avatar});
}
