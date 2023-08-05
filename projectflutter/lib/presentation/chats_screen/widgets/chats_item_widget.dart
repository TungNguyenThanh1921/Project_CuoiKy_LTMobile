import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:projectflutter/Views/Login.dart';
import 'package:projectflutter/core/app_export.dart';
import 'package:projectflutter/main.dart';
import 'package:projectflutter/presentation/chat_inner_screen/chat_inner_screen.dart';
import 'package:projectflutter/presentation/chats_screen/models/chat_model.dart';
import 'package:projectflutter/presentation/chats_screen/widgets/stacked_widgets.dart';
import 'package:projectflutter/presentation/details/page.dart';

class ChatsItemWidget extends StatelessWidget {
  final ChatModel item;
  const ChatsItemWidget(this.item, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () => Navigator.push(
      //     context, MaterialPageRoute(builder: (_) => const DetailsPage())),
      child: Container(
        margin: EdgeInsets.only(
          top: getVerticalSize(6.0),
          bottom: getVerticalSize(6.0),
        ),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: ColorConstant.whiteA700,
          borderRadius: BorderRadius.circular(
            getHorizontalSize(
              12,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.memory(
                  item.image as Uint8List,
                  height: getSize(
                    64,
                  ),
                  width: getSize(
                    64,
                  ),
                  fit: BoxFit.fill,
                ),
                const Gap(8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: ColorConstant.gray900,
                            fontSize: getFontSize(
                              16,
                            ),
                            fontFamily: 'General Sans',
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: getVerticalSize(
                          2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  right: getHorizontalSize(
                                    10,
                                  ),
                                ),
                                child: Text(
                                  item.name,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: ColorConstant.gray900,
                                    fontSize: getFontSize(
                                      14,
                                    ),
                                    fontFamily: 'General Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      item.date.hour.toString() +' : '+ item.date.minute.toString(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: ColorConstant.bluegray400,
                        fontSize: getFontSize(
                          14,
                        ),
                        fontFamily: 'General Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                  ],
                ),
              ],
            ),
            const Gap(16),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [

                const Spacer(),
                //nut Join
                InkWell(
                  onTap: () {
                    String sqlupdate = 'select * from Message';
                    Frame10().InitMessage(sqlupdate);
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChatApp(id_room: item.id_room,)));
                    });
                  },


                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                      left: getHorizontalSize(
                        16,
                      ),
                      top: getVerticalSize(
                        8,
                      ),
                      right: getHorizontalSize(
                        16,
                      ),
                      bottom: getVerticalSize(
                        8,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(
                        getHorizontalSize(
                          50,
                        ),
                      ),
                    ),

                    child: Text(
                      'Join',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getFontSize(
                          14,
                        ),
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
