import 'package:flutter/material.dart';
import 'package:projectflutter/Views/Login.dart';

import 'package:projectflutter/ServerManager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectflutter/Views/popup.dart';
import 'package:projectflutter/main.dart';

import 'package:projectflutter/models/user.dart';
void main() {
  runApp(Register());
}

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration Form',
      home: RegistrationForm(),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<bool> CheckRegister(String sqlStatement) async {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Registration Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Create an account.",
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Color(0xFF26A3FE),
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {

                      // Perform registration logic here
                      String username = _usernameController.text.trim();
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();
                      // Add your registration logic here
                      String sql = "select user_id, username, email, password, avatar from Users where username = '${_usernameController.text.trim()}' and password = '${_passwordController.text.trim()}'";
                      CheckRegister(sql).then((isLoggedIn) {
                        if(isLoggedIn == true)
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (context) => ChatApp(ipAddress: ipAddress),
                                builder: (context) => Login()
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
                      'Register',
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
                            builder: (context) => Login()
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
                      'Login',
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
            ],
          ),
        ),
      ),
    );
  }
}
