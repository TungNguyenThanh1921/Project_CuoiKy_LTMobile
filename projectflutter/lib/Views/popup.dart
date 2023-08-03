import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Popup
{
  showAlertDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Thông báo"),
          content: Text(content),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng popup khi người dùng nhấn OK
              },
            ),
          ],
        );
      },
    );
  }

}