import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projectflutter/core/app_export.dart';
import 'package:projectflutter/models/user.dart';
import 'package:projectflutter/presentation/details/widgets/action.dart';
import 'package:projectflutter/presentation/details/widgets/category.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../ServerManager.dart';
class Profile extends StatefulWidget {
  @override
  _DetailsPage createState() => _DetailsPage();
}

class _DetailsPage extends State<Profile>{
  TextEditingController _nameController = TextEditingController();

  Future<void> updateUserName(String sqlStatement) async {
      final url = Uri.parse('http://${ServerManager().IpAddress}:8080/GetData?sql=${Uri.encodeQueryComponent(sqlStatement)}');
      final response = await http.get(url);

      if (response.statusCode == 200) {

      } else {
        print('Error calling API: ${response.statusCode}');

      }

  }
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Get the image file and convert it to bytes (Uint8List)
      File imageFile = File(pickedFile.path);
      Uint8List imageBytes = await imageFile.readAsBytes();

      // Call the method to update the avatar on the server
      if (imageBytes != null) {
        await updateAvatar(imageBytes);

        // Update the UI with the new avatar after successful update on the server
        setState(() {
          ServerManager().user?.image = imageBytes;
        });
      }
    }
  }


  Future<void> updateAvatar(Uint8List imageBytes) async {
    String base64Image = base64Encode(imageBytes);
    String sqlStatement =
        "UPDATE Users SET avatar = '$base64Image' WHERE email = '${ServerManager().user?.email}'";

    final url = Uri.parse('http://${ServerManager().IpAddress}:8080/GetData?sql=${Uri.encodeQueryComponent(sqlStatement)}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Avatar updated successfully
    } else {
      print('Error calling API: ${response.statusCode}');
    }
  }

  Future<void> _showNameInputDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter New Name"),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "New Name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String newUsername = _nameController.text.trim();
              setState(() {
                if (newUsername.isNotEmpty) {
                  String sqlStatement =
                      "UPDATE Users SET username = '$newUsername' WHERE email = '${ServerManager().user?.email}'";
                  updateUserName(sqlStatement);
                  // Update the username in ServerManager().user and UI
                  User userTemp = User(id: ServerManager().user!.id, userName: newUsername, email: ServerManager().user!.email, password: ServerManager().user!.password, image: ServerManager().user!.image);
                  ServerManager().InitUser(userTemp);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Username updated successfully!"),
                    ),
                  );
                  Navigator.pop(context); // Close the input dialog
                }
              });
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    Uint8List? userImage = ServerManager().user?.image;
    //getImageBytesFromAssets('assets/images/default_image.jpg');
    Uint8List? imagepath = ServerManager().img_default;
    if(userImage != null )
    {
      imagepath = userImage;// 'data:image/jpeg;base64,${base64Encode(userImage)}' as Uint8List?;
    }
    if(imagepath == null)
      {
        Container();
      }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent, // Make the app bar transparent
        elevation: 0, // Remove the shadow from the app bar
        // You can also add other app bar settings like title, actions, etc. if needed.
      ),
      body: Stack(
        children: [
          Stack(
            alignment: Alignment.topLeft,
            children: [
              GestureDetector(
                onTap: _pickImageFromGallery, // Call _pickImageFromGallery when tapped
                child: Image.memory(
                  imagepath!,
                  height: getSize(375),
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                width: size.width,
                margin: EdgeInsets.only(
                  top: getVerticalSize(
                    56,
                  ),
                ),
                padding: EdgeInsets.only(
                  left: getHorizontalSize(
                    20,
                  ),
                  right: getHorizontalSize(
                    20,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        CupertinoIcons.chevron_left,
                        color: ColorConstant.whiteA700,
                        size: 20,
                      ),
                    ),
                    SizedBox(
                      height: getSize(22),
                      width: getSize(22),
                      child: SvgPicture.asset(
                        ImageConstant.imgIconshare,
                        color: Colors.white,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: getSize(
                500,
              ),
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                margin: const EdgeInsets.symmetric(),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(
                  getHorizontalSize(16),
                ))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        GestureDetector(
                        onTap: _showNameInputDialog,
                        child: Text(
                          ServerManager().user!.userName,// Ten user
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: ColorConstant.gray900,
                              fontSize: getFontSize(
                                32,
                              ),
                              fontFamily: 'General Sans',
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                          const Gap(8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: getSize(
                                      14,
                                    ),
                                    width: getSize(
                                      14,
                                    ),
                                    child: SvgPicture.asset(
                                      ImageConstant.imgIconuser,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: getHorizontalSize(
                                        2,
                                      ),
                                    ),
                                    child: Text(
                                      "4",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: ColorConstant.bluegray400,
                                        fontSize: getFontSize(
                                          14,
                                        ),
                                        fontFamily: 'General Sans',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(
                                    height: getSize(
                                      14,
                                    ),
                                    width: getSize(
                                      14,
                                    ),
                                    child: SvgPicture.asset(
                                      ImageConstant.imgIconeye,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: getHorizontalSize(
                                        2,
                                      ),
                                    ),
                                    child: Text(
                                      "2 482",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: ColorConstant.bluegray400,
                                        fontSize: getFontSize(
                                          14,
                                        ),
                                        fontFamily: 'General Sans',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Gap(10),
                          Text(
                            "Angel baby ngoài đời thực nè. 😽.🐈💜.",
                            maxLines: null,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: ColorConstant.gray900,
                              fontSize: getFontSize(
                                16,
                              ),
                              fontFamily: 'General Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 0),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: [
                        {'animal': '🐈', 'text': 'Yêu mèo'},
                        {'animal': '🌿', 'text': 'Thích cây'},
                        {'animal': '👾', 'text': 'hehe'}
                      ].map<Widget>((e) => Category(e)).toList()),
                    ),
                    const Gap(15),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                              ColorConstant.fromHex('#ECE9FF'),
                              Colors.grey.shade100
                            ])),
                        child: const ActionList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
