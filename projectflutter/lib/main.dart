import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
void main() => runApp(ChatApp());


class ChatApp extends StatefulWidget {
  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  final WebSocketChannel channel = IOWebSocketChannel.connect('ws://192.168.1.43:9090');
  final TextEditingController _textController = TextEditingController();
  List<String> messages = []; // Danh sách lưu trữ các tin nhắn
  String clientName = ''; // Tên client
  List<String> chatSamples = [];
  String selectedChatSample = '';
  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

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
    final url = Uri.parse('http://192.168.0.107:8080/data');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<String> chatSamples = List<String>.from(data['chat_samples']);
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