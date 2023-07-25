import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatApp(ipAddress: ipAddress),
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
  final String ipAddress;
  ChatApp({required this.ipAddress});
  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {

  late final WebSocketChannel channel;
  final TextEditingController _textController = TextEditingController();
  List<String> messages = []; // Danh sách lưu trữ các tin nhắn
  String clientName = ''; // Tên client
  List<String> chatSamples = [];
  String selectedChatSample = '';
  String ipAddress = '...';
  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://${widget.ipAddress}:9090');
    channel.stream.listen((dynamic data) {
      if (data is String) {
        setState(() {
          messages.add(data);
        });
      } else if (data is Uint8List) {
        String message = utf8.decode(data);
        setState(() {
          messages.add(message);
        });
      } else {
        print('Received unexpected data type: ${data.runtimeType}');
      }
    });
    fetchData();

  }

  void sendMessage(String message) {
    final formattedMessage = '$clientName: $message'; // Thêm tên client vào tin nhắn
    channel.sink.add(formattedMessage);
    // Thêm tin nhắn mới vào danh sách và cập nhật giao diện
    setState(() {
      messages.add(formattedMessage);
    });
  }

  void fetchData() async {
    final url = Uri.parse('http://${widget.ipAddress}:8080/data');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<String> chatSamples = List<String>.from(jsonData['chat_samples']);
      setState(() {
        this.chatSamples = chatSamples;
        selectedChatSample = this.chatSamples[0];
      });
    } else {
      print('Lỗi khi gọi API: ${response.statusCode}');
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
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
                reverse: true, // Hiển thị tin nhắn mới nhất lên đầu danh sách
              ),
            ),


        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Enter a message',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  final message = _textController.text;
                  sendMessage(message);
                  _textController.clear();
                  // Hiển thị thông báo là tin nhắn đã được gửi
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sent message: $message')),
                  );
                },
              ),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedChatSample,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedChatSample = newValue!;
                    _textController.text = newValue!;
                  });
                },
                items: chatSamples.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
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
                      // Hiển thị thông báo là tên client đã được nhập
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