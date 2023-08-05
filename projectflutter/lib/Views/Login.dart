import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:projectflutter/ServerManager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectflutter/Views/Register.dart';
import 'package:projectflutter/main.dart';
import 'package:projectflutter/models/conversation.dart';
import 'package:projectflutter/models/messages.dart';

import 'package:projectflutter/models/user.dart';
import 'package:projectflutter/presentation/chats_screen/chats_screen.dart';
void main() {
  runApp(Login());
}

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        body: Frame10(),
      ),
    );
  }
}
Future<Uint8List> readImageAsBytes(File imageFile) async {
  return await imageFile.readAsBytes();
}
String encodeImageToVarBinary(Uint8List imageBytes) {
  return base64Encode(imageBytes);
}


class Frame10 extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Future<bool> CheckLogin(String sqlStatement) async {
    final url = Uri.parse('http://${ServerManager().IpAddress}:8080/GetData?sql=${Uri.encodeQueryComponent(sqlStatement)}');
    //final Uri url = Uri.parse('$serverAddress');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      if(jsonList == null || jsonList.isEmpty)
      {
        return false;
      }
      else {
        List<User> dataList = [];
        for (var jsonRow in jsonList) {
            User data = User.fromJson(jsonRow);
          dataList.add(data);
        }
        ServerManager().InitUser(dataList[0]);
        return true;
      }
    } else {
      print('Lỗi khi gọi API: ${response.statusCode}');
    }
    return false;
  }

  Future<void> InitRooms(String sqlStatement) async {
    final url = Uri.parse('http://${ServerManager().IpAddress}:8080/GetData?sql=${Uri.encodeQueryComponent(sqlStatement)}');
    //final Uri url = Uri.parse('$serverAddress');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
        List<Conversation> dataList = [];
        for (var jsonRow in jsonList)
        {
          Conversation data = Conversation.fromJson(jsonRow);

          dataList.add(data);
        }
        ServerManager().InitConversation(dataList);
    } else {
      print('Lỗi khi gọi API: ${response.statusCode}');
    }

  }

  Future<void> InitMessage(String sqlStatement) async {
    final url = Uri.parse('http://${ServerManager().IpAddress}:8080/GetData?sql=${Uri.encodeQueryComponent(sqlStatement)}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
        List<Messages> dataList = [];
        for (var jsonRow in jsonList) {
          Messages data = Messages.fromJson(jsonRow);
          dataList.add(data);
        }
        ServerManager().InitMessages(dataList);
    } else {
      print('Lỗi khi gọi API: ${response.statusCode}');
    }

  }

  Future<void> InitListUser(String sqlStatement) async {
    final url = Uri.parse('http://${ServerManager().IpAddress}:8080/GetData?sql=${Uri.encodeQueryComponent(sqlStatement)}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      List<User> dataList = [];
      for (var jsonRow in jsonList) {
        User data = User.fromJson(jsonRow);
        dataList.add(data);
      }
      ServerManager().InitListUser(dataList);
    } else {
      print('Lỗi khi gọi API: ${response.statusCode}');
    }

  }

  List<Conversation> GetConverSation()
  {
    List<Conversation> templist = [];
    for (var data in ServerManager().conversation!)
      {
        if(data.is_private)
          {
            if(ServerManager().user?.id == data.user_id || ServerManager().user?.id == data.participant_id)
              {
                templist.add(data);
              }
          }
        else
          {
            templist.add(data);
          }
      }
    return templist;

  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth,
      height: screenHeight,
      color: Colors.white,
      child:  Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://static.vecteezy.com/system/resources/previews/000/561/500/original/chat-app-logo-icon-vector.jpg"),
                    fit: BoxFit.cover, // Thay đổi BoxFit tại đây
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Container(
                width: 300,
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: (screenWidth - 300) / 2),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                width: 300,
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: (screenWidth - 300) / 2),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      String sql_initRoom = 'select * from Conversation';
                      InitRooms(sql_initRoom);
                      String sql_initMessage = 'select * from Message';
                      InitMessage(sql_initMessage);
                      String sql_initUser = 'select user_id, username, email, password, avatar from Users';
                      InitListUser(sql_initUser);
                      Future.delayed(Duration(seconds: 2), () {
                        String sql = "select user_id, username, email, password, avatar from Users where email = '${emailController.text.trim()}' and password = '${passwordController.text.trim()}'";
                        CheckLogin(sql).then((isLoggedIn) {
                          if(isLoggedIn == true)
                          {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatsScreen(OwnListConversation: GetConverSation())
                              ),
                            );
                          }
                        });
                      });


                      // Thêm hành động khi người dùng nhấn nút vào đây
                    },
                    style: TextButton.styleFrom(

                      primary: Colors.black, // Màu chữ của nút
                      backgroundColor: Color(0xFF0066A6), // Màu nền của nút
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.03),
                      ),
                      minimumSize: Size(screenWidth * 0.35, screenHeight * 0.06), // Kích thước tối thiểu của nút
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // builder: (context) => ChatApp(ipAddress: ipAddress),
                            builder: (context) => IPAddressScreen()
                        ),
                      );

                      // Thêm hành động khi người dùng nhấn nút vào đây
                    },
                    style: TextButton.styleFrom(

                      primary: Colors.black, // Màu chữ của nút
                      backgroundColor: Color(0xFF00B0DF), // Màu nền của nút
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.03),
                      ),
                      minimumSize: Size(screenWidth * 0.35, screenHeight * 0.06), // Kích thước tối thiểu của nút
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Container(
                width: screenWidth * 0.5,
                child: Align(
                  alignment: Alignment.center,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'Sign in now',
                          style: TextStyle(
                            color: Color(0xFF0066A6),
                            fontSize: 10,
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // builder: (context) => ChatApp(ipAddress: ipAddress),
                                    builder: (context) => Register()
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
