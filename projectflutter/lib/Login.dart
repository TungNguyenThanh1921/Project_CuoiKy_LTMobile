import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:projectflutter/ServerManager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectflutter/main.dart';

import 'models/user.dart';
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

// Future<void> updateAvatarToDefault(Uint8List text) async {
//
//
//       "UPDATE Users SET avatar = '$text' WHERE user_id = ${ServerManager().user?.id}";
//   final url = Uri.parse(
//       'http://${ServerManager().IpAddress}:8080/UpdateData?sql=${Uri.encodeQueryComponent(sqlStatement)}');
//
//   final response = await http.get(url);
//
//   if (response.statusCode == 200) {
//     print('Avatar updated to default_image');
//   } else {
//     print('Error updating avatar: ${response.statusCode}');
//   }
// }

class Frame10 extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
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
            print('User ID: ${data.id}');
            print('Username: ${data.userName}');
            print('Email: ${data.email}');
            print('Password: ${data.password}');
            print('Image (base64): ${data.image}');
          dataList.add(data);


        }

        ServerManager().InitUser(dataList[0]);
        // user?.id = dataList[0].id;
        // ServerManager().user?.userName = dataList[0].userName;
        // ServerManager().user?.email = dataList[0].email;
        // ServerManager().user?.password = dataList[0].password;
        // ServerManager().user?.image = dataList[0].image;
        return true;
      }
    } else {
      print('Lỗi khi gọi API: ${response.statusCode}');
    }
    return false;
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
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
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
                      String sql = "select user_id, username, email, password, avatar from Users where username = '${usernameController.text.trim()}' and password = '${passwordController.text.trim()}'";
                      CheckLogin(sql).then((isLoggedIn) {
                        if(isLoggedIn == true)
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (context) => ChatApp(ipAddress: ipAddress),
                                builder: (context) => ChatApp()
                            ),
                          );
                        }
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
