// ignore_for_file: file_names

import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/Views/ViewPost.dart';
import 'package:mysocialmediaapp/Views/visitingProfileView.dart';

import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:mysocialmediaapp/utilities/utilities.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:sizer/sizer.dart';

class ChatView extends StatefulWidget {
  final Chats chat;
  final Users user;

  const ChatView({super.key, required this.chat, required this.user});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  List<Messages> messeges = [];
  Messages? currentMessage;
  late Users ownerUser;
  Messages? previousMessage;
  int maxLines = 3;
  bool loading = false;
  late Chats chat;
  int userNumber = 1;
  DataBase db = DataBase();

  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    ownerUser = widget.user;
    if (chat.user1UserId != FirebaseAuth.instance.currentUser!.uid) {
      userNumber = 2;
      var temp = chat.user1Name;
      chat.user1Name = chat.user2Name;
      chat.user2Name = temp;

      var temp1 = chat.user1UserName;
      chat.user1UserName = chat.user2UserName;
      chat.user2UserName = temp1;

      var temp2 = chat.user1UserId;
      chat.user1UserId = chat.user2UserId;
      chat.user2UserId = temp2;

      var temp3 = chat.user1ProfileLoc;
      chat.user1ProfileLoc = chat.user2ProfileLoc;
      chat.user2ProfileLoc = temp3;
    }
  }

  void performUpdate() async {
    await db.updateSeen(chat, userNumber);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          forceMaterialTransparency: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: chat.user2ProfileLoc == null
                    ? const AssetImage('assets/blankprofile.png')
                        as ImageProvider
                    : NetworkImage(chat.user2ProfileLoc!),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: SizedBox(
                  width: 50.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.user2Name,
                        softWrap: true,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(chat.user2UserName,
                          softWrap: true,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Color.fromARGB(255, 220, 209, 209)))
                    ],
                  ),
                ),
              )
            ],
          )),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: ListView(
            reverse: true,
            children: [
              chat.chatId != null
                  ? StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chat.chatId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var chat = getChatObject(snapshot.data!);
                          if (chat.user1UserId ==
                              FirebaseAuth.instance.currentUser!.uid) {
                            if (chat.user2Seen) {
                              return Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 5.w),
                                    child: const Text('Seen'),
                                  ));
                            } else {
                              return const SizedBox.shrink();
                            }
                          } else {
                            if (chat.user1Seen) {
                              return Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 5.w),
                                    child: const Text('Seen'),
                                  ));
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    )
                  : const SizedBox.shrink(),
              Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 4.w),
                  child: chat.chatId == null
                      ? const Center(
                          child: Text("No Messages"),
                        )
                      : FirestorePagination(
                          isLive: true,
                          shrinkWrap: true,
                          reverse: true,
                          viewType: ViewType.list,
                          onEmpty: const Text('No Messages'),
                          initialLoader: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeCap: StrokeCap.round,
                              strokeWidth: 2,
                            ),
                          ),
                          bottomLoader: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          limit: 15,
                          query: FirebaseFirestore.instance
                              .collection('messeges')
                              .where('chatId', isEqualTo: chat.chatId)
                              .orderBy('time', descending: true),
                          itemBuilder: (context, snapshot, index) {
                            previousMessage = currentMessage;
                            currentMessage = getMyObject(snapshot);
                            messeges.insert(index, currentMessage!);
                            if (index == 0) {
                              previousMessage = null;
                              if (currentMessage!.senderUserId !=
                                  FirebaseAuth.instance.currentUser!.uid) {
                                performUpdate();
                              }
                            }

                            if (currentMessage!.senderUserId ==
                                chat.user2UserId) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 1.h),
                                    child: SizedBox(
                                      width: 90.w,
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 3.w),
                                              child: CircleAvatar(
                                                backgroundColor: Colors.grey,
                                                backgroundImage: chat
                                                            .user2ProfileLoc ==
                                                        null
                                                    ? const AssetImage(
                                                            'assets/blankprofile.png')
                                                        as ImageProvider
                                                    : NetworkImage(
                                                        chat.user2ProfileLoc!,
                                                      ),
                                                radius: 13,
                                              ),
                                            ),
                                            currentMessage!.content == null &&
                                                    currentMessage!.imageLoc ==
                                                        null
                                                ? Container(
                                                    alignment: Alignment.center,
                                                    width: 50.w,
                                                    height: 20.w,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 51, 47, 58),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: const Text(
                                                      'Post Unavailable',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white),
                                                    ),
                                                  )
                                                : (currentMessage!.content ==
                                                        null
                                                    ? InkWell(
                                                        onTap: () async {
                                                          if (ownerUser
                                                                  .userId ==
                                                              messeges[index]
                                                                  .postUserId) {
                                                            return;
                                                          }

                                                          if (ownerUser
                                                                  .following
                                                                  .contains(messeges[
                                                                          index]
                                                                      .postUserId) ||
                                                              !messeges[index]
                                                                  .isPrivatePost!) {
                                                            Posts post = await db
                                                                .getPost(messeges[
                                                                        index]
                                                                    .postId!) as Posts;

                                                            List<Posts> posts =
                                                                [post];
                                                            PersistentNavBarNavigator.pushNewScreen(
                                                                context,
                                                                screen: (ViewPost(
                                                                    posts:
                                                                        posts,
                                                                    index1: 0,
                                                                    personal:
                                                                        false,
                                                                    user:
                                                                        ownerUser)),
                                                                withNavBar:
                                                                    true,
                                                                pageTransitionAnimation:
                                                                    PageTransitionAnimation
                                                                        .cupertino);
                                                          } else {
                                                            Users user = await db
                                                                .getUser(messeges[
                                                                        index]
                                                                    .postUserId!) as Users;

                                                            PersistentNavBarNavigator.pushNewScreen(
                                                                context,
                                                                screen: (VisitingProfileView(
                                                                    user: user,
                                                                    ownerUser:
                                                                        ownerUser,
                                                                    rebuilt:
                                                                        null)),
                                                                withNavBar:
                                                                    true,
                                                                pageTransitionAnimation:
                                                                    PageTransitionAnimation
                                                                        .cupertino);
                                                          }
                                                        },
                                                        child: Container(
                                                          height: 89.w,
                                                          width: 63.w,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                36, 34, 40),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 2.w),
                                                            child: Column(
                                                              children: [
                                                                Stack(
                                                                    children: [
                                                                      Container(
                                                                          width: 60
                                                                              .w,
                                                                          height: 80
                                                                              .w,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: const Color.fromARGB(
                                                                                255,
                                                                                38,
                                                                                38,
                                                                                38),
                                                                            image:
                                                                                DecorationImage(
                                                                              image: NetworkImage(currentMessage!.imageLoc!),
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          )),
                                                                      !ownerUser.following.contains(messeges[index].postUserId) &&
                                                                              messeges[index].isPrivatePost! &&
                                                                              ownerUser.userId != messeges[index].postUserId
                                                                          ? Positioned.fill(
                                                                              child: ClipRect(
                                                                                child: BackdropFilter(
                                                                                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                                                                  child: Container(
                                                                                    alignment: Alignment.center,
                                                                                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                                                                                    child: Icon(
                                                                                      Icons.lock_person_outlined,
                                                                                      size: 10.w,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : const SizedBox.shrink()
                                                                    ]),
                                                                const Text(
                                                                  'View Post',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          195,
                                                                          233,
                                                                          249),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w200),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Flexible(
                                                        fit: FlexFit.loose,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                55, 55, 57),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius.circular(max(
                                                                  60.1 -
                                                                      currentMessage!
                                                                          .content!
                                                                          .length,
                                                                  10)),
                                                              topRight: Radius.circular(max(
                                                                  60.1 -
                                                                      currentMessage!
                                                                          .content!
                                                                          .length,
                                                                  10)),
                                                              bottomRight: Radius
                                                                  .circular(max(
                                                                      60.1 -
                                                                          currentMessage!
                                                                              .content!
                                                                              .length,
                                                                      10)),
                                                              bottomLeft:
                                                                  Radius.zero,
                                                            ),
                                                          ),
                                                          child: Text(
                                                              currentMessage!
                                                                  .content!,
                                                              softWrap: true,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16)),
                                                        ),
                                                      )),
                                          ]),
                                    ),
                                  ),
                                  previousMessage != null &&
                                          !isSameDay(previousMessage!.time,
                                              currentMessage!.time)
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              top: 2.h, bottom: 2.h),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              previousMessage!.time
                                                  .toString()
                                                  .substring(0, 10),
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 188, 188, 191)),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 30.w, bottom: 1.h),
                                    child: SizedBox(
                                        width: 90.w,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child:
                                              currentMessage!.content == null &&
                                                      currentMessage!
                                                              .imageLoc ==
                                                          null
                                                  ? (Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 50.w,
                                                      height: 20.w,
                                                      decoration: BoxDecoration(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 51, 47, 58),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: const Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        'Post Unavailable',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ))
                                                  : (currentMessage!.content ==
                                                          null
                                                      ? (InkWell(
                                                          onTap: () async {
                                                            if (ownerUser
                                                                    .userId ==
                                                                messeges[index]
                                                                    .postUserId) {
                                                              return;
                                                            }

                                                            if (ownerUser
                                                                    .following
                                                                    .contains(messeges[
                                                                            index]
                                                                        .postUserId) ||
                                                                !messeges[index]
                                                                    .isPrivatePost!) {
                                                              Posts post = await db
                                                                  .getPost(messeges[
                                                                          index]
                                                                      .postId!) as Posts;

                                                              List<Posts>
                                                                  posts = [
                                                                post
                                                              ];
                                                              PersistentNavBarNavigator.pushNewScreen(
                                                                  context,
                                                                  screen: (ViewPost(
                                                                      posts:
                                                                          posts,
                                                                      index1: 0,
                                                                      personal:
                                                                          false,
                                                                      user:
                                                                          ownerUser)),
                                                                  withNavBar:
                                                                      true,
                                                                  pageTransitionAnimation:
                                                                      PageTransitionAnimation
                                                                          .cupertino);
                                                            } else {
                                                              Users user = await db
                                                                  .getUser(messeges[
                                                                          index]
                                                                      .postUserId!) as Users;

                                                              PersistentNavBarNavigator.pushNewScreen(
                                                                  context,
                                                                  screen: (VisitingProfileView(
                                                                      user:
                                                                          user,
                                                                      ownerUser:
                                                                          ownerUser,
                                                                      rebuilt:
                                                                          null)),
                                                                  withNavBar:
                                                                      true,
                                                                  pageTransitionAnimation:
                                                                      PageTransitionAnimation
                                                                          .cupertino);
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 90.w,
                                                            width: 76.w,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  36, 34, 40),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 3.w),
                                                              child: Column(
                                                                children: [
                                                                  Stack(
                                                                      children: [
                                                                        Container(
                                                                            width:
                                                                                60.w,
                                                                            height: 80.w,
                                                                            decoration: BoxDecoration(
                                                                              color: const Color.fromARGB(255, 38, 38, 38),
                                                                              image: DecorationImage(
                                                                                image: NetworkImage(currentMessage!.imageLoc!),
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            )),
                                                                        !ownerUser.following.contains(messeges[index].postUserId) &&
                                                                                messeges[index].isPrivatePost! &&
                                                                                ownerUser.userId != messeges[index].postUserId
                                                                            ? Positioned.fill(
                                                                                child: ClipRect(
                                                                                  child: BackdropFilter(
                                                                                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                                                                    child: Container(
                                                                                      alignment: Alignment.center,
                                                                                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                                                                                      child: Icon(
                                                                                        Icons.lock_person_outlined,
                                                                                        size: 10.w,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : const SizedBox.shrink()
                                                                      ]),
                                                                  const Text(
                                                                    'View Post',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            195,
                                                                            233,
                                                                            249),
                                                                        fontWeight:
                                                                            FontWeight.w200),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ))
                                                      : Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                124, 32, 181),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius.circular(max(
                                                                  60.1 -
                                                                      currentMessage!
                                                                          .content!
                                                                          .length,
                                                                  10)),
                                                              topRight: Radius.circular(max(
                                                                  60.1 -
                                                                      currentMessage!
                                                                          .content!
                                                                          .length,
                                                                  10)),
                                                              bottomLeft: Radius
                                                                  .circular(max(
                                                                      60.1 -
                                                                          currentMessage!
                                                                              .content!
                                                                              .length,
                                                                      10)),
                                                              bottomRight:
                                                                  Radius.zero,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            currentMessage!
                                                                .content!,
                                                            softWrap: true,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                        )),
                                        )),
                                  ),
                                  previousMessage != null &&
                                          !isSameDay(previousMessage!.time,
                                              currentMessage!.time)
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              top: 2.h, bottom: 2.h),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                                previousMessage!.time
                                                    .toString()
                                                    .substring(0, 10),
                                                style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 188, 188, 191))),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              );
                            }
                          },
                        )),
            ],
          )),
          Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.w),
                      color: const Color.fromARGB(255, 36, 38, 44)),
                  alignment: Alignment.center,
                  width: 96.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(1.w),
                        child: ValueListenableBuilder(
                            valueListenable: ProfilePicture(),
                            builder: (context, value, child) {
                              chat.user1ProfileLoc = value;
                              return value == null
                                  ? CircleAvatar(
                                      backgroundColor: Colors.black,
                                      radius: 2.8.h,
                                      backgroundImage: const AssetImage(
                                          'assets/blankprofile.png'),
                                    )
                                  : CircleAvatar(
                                      radius: 2.8.h,
                                      backgroundColor: Colors.black,
                                      backgroundImage: NetworkImage(value),
                                    );
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 3.w, right: 0),
                        child: SizedBox(
                          width: 62.w,
                          child: TextField(
                            maxLines: 5,
                            expands: false,
                            minLines: 1,
                            cursorColor: Colors.white,
                            style:
                                const TextStyle(fontWeight: FontWeight.normal),
                            controller: controller,
                            onTap: () {
                              setState(() {});
                            },
                            autocorrect: false,
                            enableSuggestions: true,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Message...'),
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            var text = controller.text;

                            if (text.isNotEmpty) {
                              setState(() {
                                loading = true;
                              });
                              var text = controller.text;
                              controller.text = '';
                              DataBase()
                                  .sendMessage(chat, userNumber, text, null,
                                      null, null, null)
                                  .then((value) {
                                if (value) {
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                    "Some thing happened!",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  )));
                                }
                                setState(() {
                                  loading = false;
                                });
                              });
                              await notification(chat, text);
                            }
                          },
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: blueColor,
                                  strokeWidth: 1,
                                  strokeCap: StrokeCap.round,
                                )
                              : const Text(
                                  'Send',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor),
                                ))
                    ],
                  ),
                ),
              ))
        ],
      )),
      resizeToAvoidBottomInset: true,
    );
  }
}

Messages getMyObject(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  String chatId = data['chatId'] as String;
  String senderUserId = data['senderUserId'] as String;
  String receicerUserId = data['receiverId'] as String;
  String? content = data['message'];
  Timestamp time = data['time'] as Timestamp;
  String? imageLoc = data['imageLoc'];
  String? postId = data['postId'];
  String? postUserId = data['postUserId'];
  DateTime timeDart = time.toDate();
  bool? isPrivatePost = data['isPrivatePost'];

  return Messages(
      chatId: chatId,
      senderUserId: senderUserId,
      receicerUserId: receicerUserId,
      content: content,
      imageLoc: imageLoc,
      postId: postId,
      time: timeDart,
      postUserId: postUserId,
      isPrivatePost: isPrivatePost);
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
