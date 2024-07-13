import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mysocialmediaapp/Views/ChatView.dart';
import 'package:mysocialmediaapp/Views/SearchBar.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:mysocialmediaapp/utilities/utilities.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sizer/sizer.dart';

class MessagesView extends StatefulWidget {
  final Users user;
  const MessagesView({super.key, required this.user});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  late Users ownerUser;

  bool loading = false;
  @override
  void initState() {
    super.initState();
    ownerUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
        onHorizontalDragUpdate: (details) {
          // Note: Sensitivity is integer used when you don't want to mess up vertical drag
          int sensitivity = 12;
          if (details.delta.dx > sensitivity) {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            forceMaterialTransparency: true,
            title: Text(
              ownerUser.userName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 1.h, bottom: 5.w),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(92.w, 5.5.h),
                          backgroundColor:
                              const Color.fromARGB(255, 21, 24, 30),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        onPressed: () async {
                          Chats? chat;
                          Users? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchBarView(
                                    user: ownerUser, messaging: true)),
                          );

                          if (result != null) {
                            setState(() {
                              loading = true;
                            });
                            DataBase()
                                .getChat(ownerUser.userId, result.userId)
                                .then((value) {
                              if (value == null) {
                                chat = Chats(
                                    user1UserId: ownerUser.userId,
                                    user1UserName: ownerUser.userName,
                                    user1Name: ownerUser.name,
                                    user1ProfileLoc: ownerUser.imageLoc,
                                    user2UserId: result.userId,
                                    user2UserName: result.userName,
                                    user2Name: result.name,
                                    user2ProfileLoc: result.imageLoc,
                                    user1Seen: true,
                                    user2Seen: false,
                                    date: DateTime.now());
                              } else {
                                chat = value;
                              }
                              setState(() {
                                loading = false;
                              });

                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: (ChatView(
                                  chat: chat!,
                                )),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 17),
                                child: Text(
                                  'Search',
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.grey.shade400),
                                ))
                          ],
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: const Text(
                    'Messages',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h),
                    child: FirestorePagination(
                      shrinkWrap: true,
                      isLive: true,
                      viewType: ViewType.list,
                      onEmpty: const Center(child: Text('No Messages')),
                      initialLoader: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeCap: StrokeCap.round,
                          strokeWidth: 2,
                        ),
                      ),
                      query: FirebaseFirestore.instance
                          .collection('chats')
                          .where(Filter.or(
                              Filter('user1UserId',
                                  isEqualTo: ownerUser.userId),
                              Filter('user2UserId',
                                  isEqualTo: ownerUser.userId)))
                          .orderBy('time', descending: true),
                      itemBuilder: (context, snapshot, index) {
                        var chat = getChatObject(snapshot);
                        String? profileLoc;
                        String userName;
                        int personalNumber;
                        if (chat.user1UserId == ownerUser.userId) {
                          personalNumber = 1;
                          profileLoc = chat.user2ProfileLoc;
                          userName = chat.user2Name;
                        } else {
                          personalNumber = 2;
                          profileLoc = chat.user1ProfileLoc;
                          userName = chat.user1Name;
                        }
                        return InkWell(
                          onTap: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: (ChatView(
                                chat: chat,
                              )),
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: SizedBox(
                              width: 92.w,
                              height: 9.2.h,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white, // Border color
                                          width: 1.0, // Border width
                                        )),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage: profileLoc == null
                                          ? const AssetImage(
                                                  'assets/blankprofile.png')
                                              as ImageProvider
                                          : NetworkImage(profileLoc),
                                      radius: 7.5.w,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 4.w),
                                    child: SizedBox(
                                      width: 45.w,
                                      child: Text(
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        userName,
                                        style: const TextStyle(
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  personalNumber == 1
                                      ? Padding(
                                          padding: EdgeInsets.only(left: 15.w),
                                          child: !chat.user1Seen
                                              ? const Icon(
                                                  Icons.circle,
                                                  color: blueColor,
                                                  size: 15,
                                                )
                                              : const SizedBox.shrink())
                                      : Padding(
                                          padding: EdgeInsets.only(left: 15.w),
                                          child: !chat.user2Seen
                                              ? const Icon(
                                                  Icons.circle,
                                                  color: blueColor,
                                                  size: 15,
                                                )
                                              : const SizedBox.shrink())
                                ],
                              )),
                        );
                      },
                    ))
              ],
            ),
          )),
        ),
      ),
      if (loading)
        Positioned.fill(
            child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Container(
              height: 17.w,
              width: 38.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
                color: const Color.fromARGB(255, 37, 37, 39),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeCap: StrokeCap.round,
                        strokeWidth: 2,
                      ),
                    ),
                    const Text(
                      'Loading...',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          decoration: TextDecoration.none),
                    )
                  ],
                ),
              ),
            ),
          ),
        )),
    ]);
  }
}
