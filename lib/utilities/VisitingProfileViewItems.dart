import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/Views/ChatView.dart';
import 'package:mysocialmediaapp/Views/F&FView.dart';
import 'package:mysocialmediaapp/Views/ViewPost.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/services/SendingNotification.dart';
import 'package:mysocialmediaapp/utilities/state.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class VisitingProfileViewItems extends StatefulWidget {
  final bool isRequested;
  final Users user;
  final Users ownerUser;
  final Future<void> Function()? rebuilt;
  final double oneContainerWidth;
  const VisitingProfileViewItems(
      {super.key,
      required this.user,
      required this.ownerUser,
      required this.isRequested,
      this.rebuilt,
      required this.oneContainerWidth});

  @override
  State<VisitingProfileViewItems> createState() =>
      _VisitingProfileViewItemsState();
}

class _VisitingProfileViewItemsState extends State<VisitingProfileViewItems> {
  DataBase db = DataBase();
  late Users user;
  late Users ownerUser;
  List<Posts> posts = [];
  String totalPosts = '0';
  late bool isRequested;
  late double oneContainerWidth;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    ownerUser = widget.ownerUser;
    isRequested = widget.isRequested;
    oneContainerWidth = widget.oneContainerWidth;
  }

  bool isVisibility() {
    if (checkFollowers(ownerUser.following)) {
      return true;
    } else if (!user.isPrivate) {
      return true;
    } else {
      return false;
    }
  }

  bool checkFollowers(List<String> following) {
    for (int i = 0; i < following.length; i++) {
      if (following[i] == user.userId) {
        return true;
      }
    }
    return false;
  }

  void rebuiltProfileView() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            user.imageLoc == null
                ? Container(
                    width: 85.0,
                    height: 85.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 1.0, // Border width
                        )),
                    child: const CircleAvatar(
                      backgroundColor: Colors.black,
                      backgroundImage: AssetImage('assets/blankprofile.png'),
                      radius: 45,
                    ),
                  )
                : Container(
                    width: 85.0,
                    height: 85.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 1.0, // Border width
                        )),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      backgroundImage: NetworkImage(user.imageLoc!),
                      radius: 45,
                    ),
                  ),
            InkWell(
              onTap: () {},
              child: Column(
                children: [
                  FutureBuilder(
                    future: db.totalPostForVisitingProfile(user.userId),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.done:
                          totalPosts = snapshot.data!.toString();
                          {
                            return Text(
                              totalPosts,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            );
                          }
                        default:
                          {
                            return Text(
                              totalPosts,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            );
                          }
                      }
                    },
                  ),
                  const Text(
                    "Posts",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FollowersAndFollowingView(
                            user: ownerUser,
                            visitingUser: user,
                            choice: 'followers')));
              },
              child: Column(
                children: [
                  Text(
                    (user.followers.length).toString(),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const Text(
                    "Followers",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FollowersAndFollowingView(
                            user: ownerUser,
                            visitingUser: user,
                            choice: 'following')));
              },
              child: Column(
                children: [
                  Text(
                    (user.following.length).toString(),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const Text(
                    "Following",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  )
                ],
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 13, top: 10),
                child: Text(
                  user.name,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ))
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        Row(
            mainAxisAlignment: checkFollowers(ownerUser.following)
                ? MainAxisAlignment.spaceAround
                : MainAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () async {
                    if (checkFollowers(ownerUser.following)) {
                      removeRelationship(user, ownerUser, db).then((value) {
                        if (value) {
                          setState(() {
                            //Updates the UI
                          });
                        }
                      });
                    } else {
                      if (user.isPrivate && !isRequested) {
                        Notifications notification = Notifications(
                            receiverId: user.userId,
                            isLikeNotification: false,
                            isCommentNotification: false,
                            isFollowerNotification: false,
                            isRequestNotification: true,
                            senderId: ownerUser.userId,
                            senderProfileLoc: ownerUser.imageLoc,
                            senderUserName: ownerUser.userName,
                            time: DateTime.now(),
                            postId: null,
                            postLoc: null,
                            comment: null);
                        isRequested = true;
                        db.insertNotification(notification).then((value) {
                          setState(() {
                            isRequested = true;
                          });
                        });
                        await sendNotification(
                            user.token,
                            'Request',
                            "${ownerUser.userName} has sended you a following request",
                            null);
                      } else if (isRequested) {
                        db
                            .deleteNotification(
                                null, ownerUser, user, false, false, true)
                            .then((value) {
                          setState(() {
                            print('heheh');
                            isRequested = false;
                          });
                        });
                      } else {
                        addRelationship(user, ownerUser, db).then((value) {
                          if (value) {
                            setState(() {
                              //updates the UI
                            });
                          }
                        });
                      }
                    }
                  },
                  child: Container(
                    height: 30,
                    width: checkFollowers(ownerUser.following)
                        ? 175
                        : (MediaQuery.of(context).size.width) - 30,
                    decoration: BoxDecoration(
                      color: !checkFollowers(ownerUser.following)
                          ? Colors.blue
                          : const Color.fromARGB(255, 38, 38, 38),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: isRequested
                        ? const Center(
                            child: Text(
                              "Requested",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : !checkFollowers(ownerUser.following)
                            ? const Center(
                                child: Text(
                                  "Follow",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : const Center(
                                child: Text(
                                  "Following",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                  )),
              !checkFollowers(ownerUser.following)
                  ? const SizedBox.shrink()
                  : InkWell(
                      onTap: () async {
                        Chats? chat =
                            await db.getChat(user.userId, ownerUser.userId);
                        if (chat == null) {
                          chat = Chats(
                              user1UserId: ownerUser.userId,
                              user1UserName: ownerUser.userName,
                              user1Name: ownerUser.name,
                              user1FCMToken: ownerUser.token,
                              user1ProfileLoc: ownerUser.imageLoc,
                              user2UserId: user.userId,
                              user2UserName: user.userName,
                              user2Name: user.name,
                              user2FCMToken: user.token,
                              user2ProfileLoc: user.imageLoc,
                              user1Seen: true,
                              user2Seen: false,
                              date: DateTime.now());

                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: (ChatView(
                              chat: chat,
                            )),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        } else {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: (ChatView(
                              chat: chat,
                            )),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        }
                      },
                      child: Container(
                        height: 30,
                        width: 175,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 38, 38, 38),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Center(
                          child: Text(
                            "Message",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ))
            ]),
        const Padding(
          padding: EdgeInsets.only(top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.grid_on_sharp,
                size: 30,
              )
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ),
        !isVisibility()
            ? Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(children: [
                  Container(
                    height: 105,
                    width: 105,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 60,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          offset: Offset(-4, 4),
                          blurRadius: 100,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 15),
                    child: Text(
                      "This account is private",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 25,
                        shadows: [
                          Shadow(
                            color: Color.fromARGB(255, 238, 238, 238),
                            offset: Offset(2, 2),
                            blurRadius: 60,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text("Follow this account to see their posts")
                ]),
              )
            : FutureBuilder(
                future: db.getPosts(user.userId, false),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      {
                        if (snapshot.hasData) {
                          posts = snapshot.data as List<Posts>;

                          return Padding(
                            padding: const EdgeInsets.only(left: 6, right: 6),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 3,
                                      mainAxisSpacing: 4),
                              itemCount: posts.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewPost(
                                            posts: posts,
                                            index1: index,
                                            personal: false,
                                            user: ownerUser,
                                            rebuilt: widget.rebuilt,
                                          ),
                                        ));
                                  },
                                  child: Container(
                                      width: oneContainerWidth,
                                      height: oneContainerWidth,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 38, 38, 38),
                                        borderRadius: BorderRadius.circular(0),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            posts[index].postLoc,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                );
                              },
                            ),
                          );
                        } else {
                          return const LinearProgressIndicator(
                            color: Colors.white,
                            minHeight: 2,
                          );
                        }
                      }
                    default:
                      {
                        return const LinearProgressIndicator(
                          color: Colors.white,
                          minHeight: 2,
                        );
                      }
                  }
                })
      ],
    );
  }
}
