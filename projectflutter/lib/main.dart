import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io';
import 'package:projectflutter/ServerManager.dart';
import 'package:projectflutter/Login.dart';


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
    channel.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //channel = IOWebSocketChannel.connect('ws://${widget.ipAddress}:9090');
    ServerManager().channel?.stream.listen((dynamic data) {
      if (data is List<int>) {
        final prefix = utf8.decode(data.sublist(0, 5));
        final content = data.sublist(5);

        if (prefix == 'text ') {
          final textMessage = utf8.decode(content);
          final message = Message(MessageType.text, textMessage, senderName: 'Receiver', timestamp: DateTime.now());
          setState(() {
            messages.add(message);
          });
        } else if (prefix == 'image') {
          final message = Message(MessageType.image, base64Encode(content), senderName: 'Receiver', timestamp: DateTime.now());
          setState(() {
            messages.add(message);
          });
        } else {
          print('Received unexpected data format: $prefix');
        }
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (data is String) {
        final message = Message(MessageType.text, data, senderName: 'Receiver', timestamp: DateTime.now());
        setState(() {
          messages.add(message);
        });
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        print('Received unexpected data type: ${data.runtimeType}');
      }
    });

   // fetchData();

  }

  void sendMessage(String message, PickedFile? image) {
    if (message.isEmpty && image == null) return;

    if (image != null) {
      final bytes = File(image.path).readAsBytesSync();
      channel.sink.add(Uint8List.fromList([...utf8.encode('image'), ...bytes]));
      final formattedMessage = Message(MessageType.image, base64Encode(bytes), senderName: clientName, timestamp: DateTime.now());
      setState(() {
        messages.add(formattedMessage);
      });
    } else {
      final textMessage = 'text $message';
      channel.sink.add(utf8.encode(textMessage));
      final formattedMessage = Message(MessageType.text, message, senderName: clientName, timestamp: DateTime.now());
      setState(() {
        messages.add(formattedMessage);
      });
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

  void fetchData() async {
    final url = Uri.parse('http://${ServerManager().IpAddress}:8080/data');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<String> chatSamples = List<String>.from(jsonData['chat_samples']);
      for(int i=0; i< chatSamples.length;i++){
        if(chatSamples[i].isEmpty){
          chatSamples[i] = "";
        }
        else if(chatSamples[i] is int){
          chatSamples[i] = chatSamples[i].toString();
        }
      }
      setState(() {
        this.chatSamples = chatSamples;
        selectedChatSample = this.chatSamples[0];
      });
    } else {
      print('Lỗi khi gọi API: ${response.statusCode}');
    }
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


  Future<bool> CheckLogin() async {
    final url = Uri.parse('http://${ServerManager().IpAddress}:8080/data');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<String> chatSamples = List<String>.from(jsonData['chat_samples']);
      for(int i=0; i< chatSamples.length;i++){
        if(chatSamples[i].isEmpty){
          chatSamples[i] = "";
        }
        else if(chatSamples[i] is int){
          chatSamples[i] = chatSamples[i].toString();
        }
      }
      setState(() {
        this.chatSamples = chatSamples;
        selectedChatSample = this.chatSamples[0];
      });
    } else {
      print('Lỗi khi gọi API: ${response.statusCode}');
    }
    return true;
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
      final imageBytes = base64Decode(message.content);
      return Container(
        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
          ),
          child: Column(
            crossAxisAlignment: align,
            children: [
              Image.memory(imageBytes, height: 150, width: 150),
              SizedBox(height: 4),
              Text(
                _formatTimestamp(message.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.black),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      );
    } else if (message.type == MessageType.text) {
      return Container(
        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
          ),
          child: Column(
            crossAxisAlignment: align,
            children: [
              Text(
                message.content,
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
      );
    } else {
      return Container();
    }
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Chat App'),
        ),
        body: Column(
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
                          hintText: 'Enter a message...',
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
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          clientName = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.done),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Client name: $clientName')),
                      );
                    },
                  ),
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
  String content;
  String senderName;
  DateTime timestamp;

  Message(this.type, this.content, {required this.senderName, required this.timestamp});
}
