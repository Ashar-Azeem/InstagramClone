import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/services/SendingNotification.dart';
import 'package:mysocialmediaapp/utilities/utilities.dart';
import 'package:sizer/sizer.dart';

class ShareBottomSheet extends StatefulWidget {
  final Users ownerUser;
  final Posts post;

  const ShareBottomSheet({
    super.key,
    required this.ownerUser,
    required this.post,
  });

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  String checkText = '';
  bool loading = false;
  String prevText = '';
  DataBase db = DataBase();
  late Users ownerUser;
  late Posts post;
  final FocusNode _focusNode = FocusNode();
  TextEditingController text = TextEditingController();
  late double screenHeight;
  @override
  void initState() {
    super.initState();
    ownerUser = widget.ownerUser;
    post = widget.post;
    screenHeight = 58.h;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          screenHeight = 89.h;
        });
      } else {
        setState(() {
          screenHeight = 58.h;
        });
      }
    });
  }

  @override
  void dispose() {
    text.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        height: screenHeight,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 6.w, right: 6.w, bottom: 3.h),
              child: Container(
                width: 90.w,
                height: 4.5.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 62, 69, 74),
                ),
                child: TextField(
                  focusNode: _focusNode,
                  onChanged: (value) async {
                    if (prevText.length < text.text.length) {
                      await db.sendRetreivedUsers(text.text);
                      setState(() {
                        checkText = text.text;
                      });
                    } else if (text.text.isEmpty) {
                      await db.sendRetreivedUsers(text.text);
                      setState(() {
                        checkText = text.text;
                      });
                    }

                    prevText = text.text;
                  },
                  cursorColor: Colors.white,
                  enableSuggestions: false,
                  autocorrect: false,
                  controller: text,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search',
                      contentPadding: EdgeInsets.symmetric(vertical: 1.2.h),
                      prefixIcon: const Icon(Icons.search)),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  checkText.isEmpty
                      ? FirestorePagination(
                          viewType: ViewType.grid,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                  childAspectRatio: 0.945),
                          shrinkWrap: true,
                          onEmpty: const Center(child: Text('Search')),
                          initialLoader: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          bottomLoader: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          isLive: true,
                          limit: 10,
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

                            if (chat.user1UserId == ownerUser.userId) {
                              profileLoc = chat.user2ProfileLoc;
                              userName = chat.user2Name;
                            } else {
                              profileLoc = chat.user1ProfileLoc;
                              userName = chat.user1Name;
                            }
                            return InkWell(
                              onTap: () async {
                                setState(() {
                                  loading = true;
                                });
                                if (chat.user1UserId == ownerUser.userId) {
                                  await DataBase().sendMessage(
                                      chat, 1, null, post.postLoc, post.postId);

                                  await sendNotification(
                                      chat.user2FCMToken,
                                      'Message',
                                      '${ownerUser.userName} send you a post',
                                      null);
                                } else {
                                  await DataBase().sendMessage(
                                      chat, 2, null, post.postLoc, post.postId);

                                  await sendNotification(
                                      chat.user1FCMToken,
                                      'Message',
                                      '${ownerUser.userName} send you a post',
                                      null);
                                }
                                setState(() {
                                  loading = false;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color.fromARGB(
                                        255, 133, 131, 131),
                                    backgroundImage: profileLoc == null
                                        ? const AssetImage(
                                                'assets/blankprofile.png')
                                            as ImageProvider
                                        : NetworkImage(profileLoc),
                                    radius: 10.w,
                                  ),
                                  Text(
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    userName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            );
                          })
                      : StreamBuilder(
                          stream: db.usersStream,
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                              case ConnectionState.active:
                                {
                                  if (snapshot.hasData) {
                                    final users = snapshot.data as List<Users>;
                                    return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: users.length,
                                        itemBuilder: (context, index) {
                                          String? ImageLoc =
                                              users[index].imageLoc;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20, right: 10, top: 20),
                                            child: InkWell(
                                              onTap: () async {
                                                setState(() {
                                                  loading = true;
                                                });
                                                Chats? chat;
                                                DataBase()
                                                    .getChat(ownerUser.userId,
                                                        ownerUser.userId)
                                                    .then((value) async {
                                                  if (value == null) {
                                                    chat = Chats(
                                                        user1UserId:
                                                            ownerUser.userId,
                                                        user1UserName:
                                                            ownerUser.userName,
                                                        user1Name:
                                                            ownerUser.name,
                                                        user1FCMToken:
                                                            ownerUser.token,
                                                        user1ProfileLoc:
                                                            ownerUser.imageLoc,
                                                        user2UserId:
                                                            users[index].userId,
                                                        user2UserName:
                                                            users[index]
                                                                .userName,
                                                        user2Name:
                                                            users[index].name,
                                                        user2FCMToken:
                                                            users[index].token,
                                                        user2ProfileLoc:
                                                            users[index]
                                                                .imageLoc,
                                                        user1Seen: true,
                                                        user2Seen: false,
                                                        date: DateTime.now());

                                                    await DataBase()
                                                        .sendMessage(
                                                            chat!,
                                                            1,
                                                            null,
                                                            post.postLoc,
                                                            post.postId);

                                                    await sendNotification(
                                                        users[index].token,
                                                        'Message',
                                                        '${ownerUser.userName} send you a post',
                                                        null);
                                                  } else {
                                                    chat = value;
                                                    if (chat!.user1UserId ==
                                                        ownerUser.userId) {
                                                      await DataBase()
                                                          .sendMessage(
                                                              chat!,
                                                              1,
                                                              null,
                                                              post.postLoc,
                                                              post.postId);

                                                      await sendNotification(
                                                          chat!.user2FCMToken,
                                                          'Message',
                                                          '${ownerUser.userName} send you a post',
                                                          null);
                                                    } else {
                                                      await DataBase()
                                                          .sendMessage(
                                                              chat!,
                                                              2,
                                                              null,
                                                              post.postLoc,
                                                              post.postId);

                                                      await sendNotification(
                                                          chat!.user1FCMToken,
                                                          'Message',
                                                          '${ownerUser.userName} send you a post',
                                                          null);
                                                    }
                                                  }
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                });
                                              },
                                              child: SizedBox(
                                                height: 70,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    50,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    ImageLoc == null
                                                        ? const CircleAvatar(
                                                            radius: 33,
                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    38,
                                                                    38,
                                                                    38),
                                                            backgroundImage:
                                                                AssetImage(
                                                                    'assets/blankprofile.png'),
                                                          )
                                                        : CircleAvatar(
                                                            radius: 33,
                                                            backgroundColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    38,
                                                                    38,
                                                                    38),
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    ImageLoc),
                                                          ),
                                                    const SizedBox(
                                                      width: 17,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            users[index]
                                                                .userName,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14),
                                                          ),
                                                          Text(
                                                            users[index].name,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  } else {
                                    return const Text("");
                                  }
                                }

                              default:
                                {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  );
                                }
                            }
                          })
                ],
              ),
            ),
          ],
        ),
      ),
      if (loading)
        Positioned.fill(
            child: Container(
          color: Colors.transparent,
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

Comments getObject(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  String postId = data['postId'] as String;
  String userId = data['userId'] as String;
  String userName = data['userName'] as String;
  String? profileLoc = data['profileLoc'] as String?;
  String content = data['content'] as String;
  Timestamp firebaseDate = data['uploadDate'] as Timestamp;

  DateTime dartDate = firebaseDate.toDate();

  Comments comment =
      Comments(postId, userId, userName, profileLoc, dartDate, content);

  return comment;
}
