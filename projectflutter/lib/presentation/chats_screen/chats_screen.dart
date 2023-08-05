import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:projectflutter/ServerManager.dart';
import 'package:projectflutter/Views/Login.dart';
import 'package:projectflutter/core/app_export.dart';
import 'package:projectflutter/models/conversation.dart';
import 'package:projectflutter/models/messages.dart';
import 'package:projectflutter/models/user.dart';
import 'package:projectflutter/presentation/details/page.dart';

import '../../main.dart';
import 'models/chat_model.dart';
import 'widgets/chats_item_widget.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatsScreen extends StatefulWidget {
  final List<Conversation> OwnListConversation;

  const ChatsScreen({super.key, required this.OwnListConversation});
  @override
  _ChatsScreen createState() => _ChatsScreen();
}

class _ChatsScreen extends State<ChatsScreen> {

  TextEditingController _nameRoom = TextEditingController();

  @override
  void initState() {
    super.initState();
    //ServerManager().isOnChatScreen = true;
    ServerManager().registerChatRoomReloadCallback(() { reloadChatRoomIfNeeded();});
  }
  // Hàm để cập nhật danh sách cuộc trò chuyện
  void fetchAndSaveConversation() {
    String newsql = "Select * from Conversation";
    Frame10().InitRooms(newsql);
    Future.delayed(Duration(seconds: 2), () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatsScreen(OwnListConversation: Frame10().GetConverSation())
        ),
      );
    });
  }

  void reloadChatRoomIfNeeded() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatsScreen(OwnListConversation: Frame10().GetConverSation())
        ),
      );
    });
  }

  @override
  void dispose() {
    //ServerManager().isOnChatScreen = false; // Gỡ bỏ lắng nghe stream
    super.dispose();
  }
    Future<int> CreateNewConversation(String sqlStatement) async {
      final url = Uri.parse('http://${ServerManager().IpAddress}:8080/updateConversation?sql=${Uri.encodeQueryComponent(sqlStatement)}');
      //final Uri url = Uri.parse('$serverAddress');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        //final List<dynamic> jsonList = json.decode(response.body);
        fetchAndSaveConversation();

      } else {
        print('Lỗi khi gọi API: ${response.statusCode}');
      }
      return -1;
    }

  Future<void> InitPublicConversation() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Nhập tên phòng"),
        content: TextField(
          controller: _nameRoom,
          decoration: InputDecoration(
            hintText: "tên phòng",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              String newUsername = _nameRoom.text.trim();
              setState(() {
                if (newUsername.isNotEmpty) {
                  String sqlStatement = "INSERT INTO Conversation (conversation_name, user_id, IsPrivate) VALUES(N'${newUsername}', ${ServerManager().user?.id}, 0)";
                  CreateNewConversation(sqlStatement);
                  // Update the username in ServerManager().user and UI
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.pop(context); // Close the input dialog
                  });
                }
              });
            },
            child: Text("Xác nhận"),
          ),
        ],
      ),
    );
  }
  Future<void> InitPrivateConversation(int id_participation, String name_participation) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tạo cuộc trò truyện với ${name_participation}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                String sqlStatement = "INSERT INTO Conversation (conversation_name, user_id, participant_id, IsPrivate) VALUES(N'private', ${ServerManager().user?.id}, ${id_participation},1)";
                CreateNewConversation(sqlStatement);
                // Update the username in ServerManager().user and UI
                Future.delayed(Duration(seconds: 1), () {
                  Navigator.pop(context); // Close the input dialog
                });

              });
            },
            child: Text("Xác nhận"),
          ),
        ],
      ),
    );
  }
  Future<void> HasInitPrivateConversation(int id_room, String name_participation) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cuộc trò truyện với ${name_participation} đã tồn tại rồi"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                String sqlupdate = 'select * from Message';
                Frame10().InitMessage(sqlupdate);
                Future.delayed(Duration(seconds: 1), () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChatApp(id_room: id_room,)));
                });
              });
            },
            child: Text("Xác nhận"),
          ),
        ],
      ),
    );
  }

  Future<void> showClients() async {
    final selectedClient = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Chọn người trò truyện"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: ServerManager().list_user?.length,
            itemBuilder: (context, index) {
              User? client = ServerManager().list_user?[index];
              return ListTile(
                leading: Image.memory((ServerManager().getAvatarUser(client!.id) == null ? ServerManager().img_default : ServerManager().getAvatarUser(client!.id)) as Uint8List),
                title: Text(client!.userName),
                trailing: ElevatedButton(
                  onPressed: () {

                    Frame10().InitRooms('select * from Conversation');

                    Future.delayed(Duration(seconds: 2), () {
                      for(var i in ServerManager().conversation!)
                      {
                        if(i.is_private == true)
                          {
                            if(i.user_id == ServerManager().user?.id)
                            {
                              if(i.participant_id == client.id)
                              {
                                HasInitPrivateConversation(i.id, client.userName);

                              }
                              else
                              {
                                InitPrivateConversation(client.id, client.userName);
                              }
                            }
                            else if(i.participant_id == ServerManager().user?.id)
                            {
                              if(i.user_id == client.id)
                              {
                                HasInitPrivateConversation(i.id, client.userName);



                              }
                              else
                              {
                                InitPrivateConversation(client.id, client.userName);
                              }
                            }
                          }

                      }
                    });

                    Navigator.of(context).pop();
                     // Đóng dialog
                  },
                  child: Text("Chat"),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
              ColorConstant.fromHex('#EDE7FF'),
              ColorConstant.fromHex('#E5EBFF'),
            ])),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                top: getVerticalSize(
                  71,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Chats",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: ColorConstant.gray900,
                      fontSize: getFontSize(
                        34,
                      ),
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Image.asset('assets/images/multiPeople.png'),
                    onPressed: () {
                      showClients();
                    },
                  ),
                  TextButton.icon(
                    onPressed: () {
                      InitPublicConversation();

                    },
                    icon: SvgPicture.asset(
                      ImageConstant.imgIconplus,
                      fit: BoxFit.contain,
                      color: Colors.black,
                    ),
                    label: SizedBox.shrink(), // Ẩn label để chỉ hiển thị icon
                    style: TextButton.styleFrom(
                      primary: Colors.transparent, // Đặt màu chữ của nút là trong suốt
                      padding: EdgeInsets.zero, // Xóa khoảng trống trong nút
                      shape: CircleBorder(), // Đặt hình dạng nút là hình tròn
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            const Gap(15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: ColorConstant.deepPurpleA200,
                borderRadius: BorderRadius.circular(getHorizontalSize(12)),
                boxShadow: [
                  BoxShadow(
                    color: ColorConstant.deepPurpleA20066,
                    spreadRadius: getHorizontalSize(
                      1,
                    ),
                    blurRadius: getHorizontalSize(
                      1,
                    ),
                    offset: const Offset(
                      0,
                      1,
                    ),
                  ),
                ],
              ),

            ),
            ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,

              itemCount: widget.OwnListConversation.length,
              itemBuilder: (context, index) {
                var temjson = widget.OwnListConversation[index].toJson(); //ServerManager().conversation?[index].toJson();
                final item = ChatModel.fromJson(temjson!); //ServerManager().conversation![index].toJson()
                return ChatsItemWidget(item);
              },
            ),
          ],
        ),
      ),
      //menu bar
      bottomNavigationBar: Material(
        elevation: 5,
        child: Container(
          height: getVerticalSize(
            83,
          ),
          width: size.width,
          color: ColorConstant.whiteA700E5,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                top: getVerticalSize(
                  24,
                ),
                bottom: getVerticalSize(
                  24,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [

                  IconButton(
                    icon: SvgPicture.asset(ImageConstant.imgIcon3, color: Colors.black,),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Profile()),
                      );
                    },
                  ),

            ],
          ),

        ),
      ),
    ),
    ),
    );
  }
}


