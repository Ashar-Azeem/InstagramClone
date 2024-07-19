import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mysocialmediaapp/Views/ChatView.dart';
import 'package:mysocialmediaapp/Views/visitingProfileView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:mysocialmediaapp/utilities/const.dart';
import 'package:mysocialmediaapp/utilities/state.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:sizer/sizer.dart';

class FollowersAndFollowingView extends StatefulWidget {
  final Users user;
  final Users visitingUser;
  final String choice;

  const FollowersAndFollowingView(
      {super.key,
      required this.user,
      required this.choice,
      required this.visitingUser});

  @override
  State<FollowersAndFollowingView> createState() =>
      _FollowersAndFollowingViewState();
}

class _FollowersAndFollowingViewState extends State<FollowersAndFollowingView> {
  late Users user;
  late Users visitingUser;
  late String choice;
  late List<String> list;
  bool rebuilt = false;
  bool planB = false;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    user = widget.user;
    visitingUser = widget.visitingUser;
    choice = widget.choice;
    assignList(widget.choice);

    if (list.length > 30) {
      planB = true;
    }
  }

  void assignList(String choice) {
    if (choice == "followers") {
      list = visitingUser.followers;
    } else {
      list = visitingUser.following;
    }
  }

  void updateChoice(String newChoice, List<String> newList) {
    setState(() {
      choice = newChoice;
      list = newList;
      if (list.length > 30) {
        planB = true;
      } else {
        planB = false;
      }
      rebuilt = !rebuilt;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          visitingUser.userName,
          style: const TextStyle(
              fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Stack(children: [
        SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      if (choice == 'following') {
                        updateChoice('followers', visitingUser.followers);
                      }
                    },
                    child: Text("${visitingUser.followers.length} Followers",
                        style: TextStyle(
                          fontSize: choice == 'followers' ? 17 : 15,
                          fontWeight: choice == 'followers'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Colors.white,
                        )),
                  ),
                  TextButton(
                      onPressed: () {
                        if (choice == 'followers') {
                          updateChoice('following', visitingUser.following);
                        }
                      },
                      child: Text("${visitingUser.following.length} Following",
                          style: TextStyle(
                            fontSize: choice == 'following' ? 17 : 15,
                            color: Colors.white,
                            fontWeight: choice == 'following'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          )))
                ],
              ),
              const Divider(),
              list.isEmpty
                  ? Center(
                      child: Text('No $choice'),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: FirestorePagination(
                        //Rebuilts the widget if the value of the variable is changed
                        key: ValueKey(rebuilt),
                        onEmpty: Center(
                          child: Text('No $choice'),
                        ),
                        initialLoader: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),

                        limit: 15,
                        shrinkWrap: true,
                        bottomLoader: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        isLive: true,
                        query: planB
                            ? FirebaseFirestore.instance
                                .collection('users')
                                .orderBy('userName', descending: true)
                            : FirebaseFirestore.instance
                                .collection('users')
                                .orderBy('userName', descending: true)
                                .where(FieldPath.documentId, whereIn: list),
                        itemBuilder: (context, snapshot, index) {
                          Users fUser = getObject(snapshot);
                          if (list.contains(fUser.userId)) {
                            return InkWell(
                              onTap: () {
                                if (fUser.userId == user.userId) {
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VisitingProfileView(
                                            user: fUser,
                                            ownerUser: user,
                                            rebuilt: null,
                                          )),
                                );
                              },
                              child: SizedBox(
                                height: 85,
                                width: MediaQuery.of(context).size.width - 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    fUser.imageLoc == null
                                        ? const CircleAvatar(
                                            radius: 33,
                                            backgroundColor:
                                                Color.fromARGB(255, 38, 38, 38),
                                            backgroundImage: AssetImage(
                                                'assets/blankprofile.png'),
                                          )
                                        : CircleAvatar(
                                            radius: 33,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 38, 38, 38),
                                            backgroundImage:
                                                NetworkImage(fUser.imageLoc!),
                                          ),
                                    const SizedBox(
                                      width: 17,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.9,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  fUser.userName,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14),
                                                ),
                                                fUser.userName == name1 ||
                                                        fUser.userName == name2
                                                    ? Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 2.w),
                                                        child: const Icon(
                                                          Icons.verified,
                                                          color: blueColor,
                                                          size: 15,
                                                        ),
                                                      )
                                                    : const SizedBox.shrink(),
                                              ],
                                            ),
                                            Text(
                                              fUser.name,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              50),
                                      child: fUser.userId == user.userId
                                          ? const SizedBox.shrink()
                                          : InkWell(
                                              onTap: () async {
                                                var db = DataBase();
                                                if (!user.following
                                                    .contains(fUser.userId)) {
                                                  await addRelationship(
                                                      fUser, user, db);
                                                  setState(() {
                                                    rebuilt = !rebuilt;
                                                  });
                                                } else {
                                                  setState(() {
                                                    loading = true;
                                                  });
                                                  Chats? chat;
                                                  Users result = await db
                                                          .getUser(fUser.userId)
                                                      as Users;

                                                  db
                                                      .getChat(result.userId,
                                                          user.userId)
                                                      .then((value) {
                                                    if (value == null) {
                                                      chat = Chats(
                                                          user1UserId:
                                                              user.userId,
                                                          user1UserName:
                                                              user.userName,
                                                          user1Name: user.name,
                                                          user1FCMToken:
                                                              user.token,
                                                          user1ProfileLoc:
                                                              user.imageLoc,
                                                          user2UserId:
                                                              result.userId,
                                                          user2UserName:
                                                              result.userName,
                                                          user2Name:
                                                              result.name,
                                                          user2FCMToken:
                                                              result.token,
                                                          user2ProfileLoc:
                                                              result.imageLoc,
                                                          user1Seen: true,
                                                          user2Seen: false,
                                                          date: DateTime.now());
                                                    } else {
                                                      chat = value;
                                                    }
                                                    setState(() {
                                                      loading = false;
                                                    });

                                                    PersistentNavBarNavigator
                                                        .pushNewScreen(
                                                      context,
                                                      screen: (ChatView(
                                                        chat: chat!,
                                                        user: user,
                                                      )),
                                                      withNavBar: false,
                                                      pageTransitionAnimation:
                                                          PageTransitionAnimation
                                                              .cupertino,
                                                    );
                                                  });
                                                }
                                              },
                                              child: Container(
                                                height: 33,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4,
                                                decoration: BoxDecoration(
                                                  color: mobileBackgroundColor,
                                                  border: Border.all(
                                                      color: Colors.white),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Center(
                                                    child: (user.following
                                                            .contains(
                                                                fUser.userId)
                                                        ? const Text(
                                                            "Message",
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        : const Text(
                                                            "Follow",
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ))),
                                              ),
                                            ),
                                    ),
                                    user.following.contains(fUser.userId)
                                        ? PopupMenuButton<String>(
                                            color: Colors.white,
                                            onSelected: (String result) async {
                                              if (result == 'remove') {
                                                var db = DataBase();
                                                if (user.userId ==
                                                    visitingUser.userId) {
                                                  if (choice == 'followers') {
                                                    await removeFollower(
                                                        fUser, user, db);
                                                    setState(() {
                                                      list = visitingUser
                                                          .followers;
                                                      rebuilt = !rebuilt;
                                                    });
                                                  } else {
                                                    await removeRelationship(
                                                        fUser, user, db);
                                                    setState(() {
                                                      list = visitingUser
                                                          .following;
                                                      rebuilt = !rebuilt;
                                                    });
                                                  }
                                                } else if (user.userId !=
                                                        visitingUser.userId &&
                                                    user.following.contains(
                                                        fUser.userId)) {
                                                  await removeRelationship(
                                                      fUser, user, db);
                                                }
                                              }
                                            },
                                            itemBuilder: (context) {
                                              return <PopupMenuEntry<String>>[
                                                const PopupMenuItem(
                                                  value: "remove",
                                                  child: ListTile(
                                                      leading: Icon(
                                                        Icons.delete,
                                                        color: Colors.black,
                                                      ),
                                                      title: Text(
                                                        'Remove',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      )),
                                                ),
                                              ];
                                            },
                                          )
                                        : const SizedBox.shrink()
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ))
            ],
          ),
        )),
        if (loading)
          Positioned.fill(
              child: Container(
            alignment: Alignment.center,
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
                            color: Colors.white, fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ))
      ]),
    );
  }
}

Users getObject(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  String name = data['name'] as String;
  String userName = data['userName'] as String;
  String? profileLocation = data['profileLocation'] as String?;
  List<String> followers = List<String>.from(data['followers']);
  List<String> following = List<String>.from(data['following']);
  bool isPrivate = data['privateAccount'] as bool;
  String token = data['token'];
  bool isVerified = data['isVerified'];
  Users user = Users(
      id: snapshot.id,
      n: name,
      un: userName,
      loc: profileLocation,
      f1: followers,
      f2: following,
      isPriv: isPrivate,
      FCMtoken: token,
      isverified: isVerified);

  return user;
}
