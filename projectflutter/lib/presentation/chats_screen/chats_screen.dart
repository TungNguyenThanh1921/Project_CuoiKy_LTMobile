import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:projectflutter/ServerManager.dart';
import 'package:projectflutter/core/app_export.dart';
import 'package:projectflutter/models/conversation.dart';
import 'package:projectflutter/models/messages.dart';
import 'package:projectflutter/models/user.dart';
import 'package:projectflutter/presentation/details/page.dart';

import 'models/chat_model.dart';
import 'widgets/chats_item_widget.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

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
                  SvgPicture.asset(
                    ImageConstant.imgFrame242,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
            ),
            const Gap(12),
            SizedBox(
              height: getVerticalSize(
                40,
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search by chats',
                  hintStyle: TextStyle(
                    fontSize: getFontSize(
                      16.0,
                    ),
                    color: ColorConstant.bluegray400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      getHorizontalSize(
                        8,
                      ),
                    ),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(
                      left: getHorizontalSize(
                        16,
                      ),
                      right: getHorizontalSize(
                        10,
                      ),
                    ),
                    child: SizedBox(
                      height: getSize(
                        20,
                      ),
                      width: getSize(
                        20,
                      ),
                      child: SvgPicture.asset(
                        ImageConstant.imgIconSearch,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: getSize(
                      20,
                    ),
                    minHeight: getSize(
                      20,
                    ),
                  ),
                  filled: true,
                  fillColor: ColorConstant.whiteA700,
                  isDense: true,
                  contentPadding: EdgeInsets.only(
                    top: getVerticalSize(
                      11.375,
                    ),
                    bottom: getVerticalSize(
                      11.375,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: ColorConstant.bluegray400,
                  fontSize: getFontSize(
                    16.0,
                  ),
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
              itemCount: ServerManager().conversation?.length,
              itemBuilder: (context, index) {
                List<Conversation>? ls = ServerManager().conversation;
                User? us = ServerManager().user;
                List<Messages>? ms = ServerManager().messages;
                var temjson = ServerManager().conversation?[index].toJson();
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
                  Icon(Icons.home), // Ví dụ, thay thế bằng Icon hoặc widget khác tương tự
                  Icon(Icons.settings), // Ví dụ, thay thế bằng Icon hoặc widget khác tương tự
                  Icon(Icons.notifications), // Ví dụ, thay thế bằng Icon hoặc widget khác tương tự
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Profile()),
                      );
                    },
                    child: Icon(Icons.details), // Ví dụ, thay thế bằng Icon hoặc widget khác tương tự
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
