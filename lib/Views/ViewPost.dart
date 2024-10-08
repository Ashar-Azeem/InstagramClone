import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mysocialmediaapp/Views/visitingProfileView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/services/firebase.dart';
import 'package:mysocialmediaapp/utilities/ModalBottomSheet.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:mysocialmediaapp/utilities/heartAnimation.dart';
import 'package:mysocialmediaapp/utilities/shareModalSheet.dart';
import 'package:mysocialmediaapp/utilities/state.dart';
import 'package:mysocialmediaapp/utilities/utilities.dart';
import 'package:sizer/sizer.dart';

class ViewPost extends StatefulWidget {
  final Users user;
  final List<Posts> posts;
  final int index1;
  final bool personal;
  final Future<void> Function()? rebuilt;
  const ViewPost(
      {super.key,
      required this.posts,
      required this.index1,
      required this.personal,
      required this.user,
      this.rebuilt});

  @override
  State<ViewPost> createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  late Users user;
  bool isHeartAnimating = false;
  bool loading = false;
  late List<bool> seeMore;
  late List<Posts> posts;
  late int index1;
  late double size;
  late List<int> count;
  late ScrollController _controller;
  late bool personalCheck;
  @override
  void initState() {
    super.initState();
    user = widget.user;
    posts = widget.posts;
    seeMore = List.filled(posts.length, false);
    count = List.filled(posts.length, 0);
    personalCheck = widget.personal;
    index1 = widget.index1;
    _controller = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.jumpTo(
          index1 * size,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    size = screenHeight - 160;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          forceMaterialTransparency: true,
          title: personalCheck
              ? const Text(
                  "Posts",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )
              : const Text(
                  "Explore",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )),
      body: loading == true
          ? const LinearProgressIndicator(
              color: blueColor,
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: _controller,
                  itemCount: (posts.length),
                  itemBuilder: (context, index) {
                    int totalComments = posts[index].totalComments;
                    String userName = posts[index].userName;
                    bool isLiked = posts[index].likesList.contains(user.userId);
                    return SizedBox(
                      width: screenWidth,
                      height: seeMore[index] == false
                          ? screenHeight - 150
                          : screenHeight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48.0,
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  Colors.white, // Border color
                                              width: 1.0, // Border width
                                            )),
                                        child: posts[index].profLoc == null
                                            ? const CircleAvatar(
                                                backgroundColor: Colors.black,
                                                backgroundImage: AssetImage(
                                                    'assets/blankprofile.png'),
                                                radius: 30,
                                              )
                                            : CircleAvatar(
                                                backgroundColor: Colors.black,
                                                backgroundImage: NetworkImage(
                                                    posts[index].profLoc!),
                                                radius: 30,
                                              ),
                                      ),
                                      personalCheck
                                          ? Text(
                                              "  ${posts[index].userName}",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          : InkWell(
                                              onTap: () async {
                                                if (posts[index].userId ==
                                                    user.userId) {
                                                  return;
                                                }
                                                Users newuser = await DataBase()
                                                        .getUser(
                                                            posts[index].userId)
                                                    as Users;
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            VisitingProfileView(
                                                              user: newuser,
                                                              ownerUser:
                                                                  widget.user,
                                                              rebuilt: widget
                                                                  .rebuilt,
                                                            )));
                                              },
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(top: 2.h),
                                                child: SizedBox(
                                                  height: 10.w,
                                                  child: Text(
                                                      "  ${posts[index].userName}",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                              )),
                                      posts[index].userName == 'ashar' ||
                                              posts[index].userName == 'vaneeza'
                                          ? Padding(
                                              padding:
                                                  EdgeInsets.only(left: 2.w),
                                              child: const Icon(
                                                Icons.verified,
                                                color: blueColor,
                                                size: 15,
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                  AuthService().getUser()!.uid ==
                                          posts[index].userId
                                      ? PopupMenuButton<String>(
                                          color: Colors.white,
                                          onSelected: (String result) async {
                                            setState(() {
                                              loading = true;
                                            });
                                            if (result == 'delete') {
                                              DataBase()
                                                  .deletePost(
                                                      posts[index].postId,
                                                      posts[index].postLoc)
                                                  .then((value) {
                                                setState(() {
                                                  loading = false;
                                                });
                                                if (value == true) {
                                                  PostsCollection().removePost(
                                                      post: posts[index]);

                                                  setState(() {
                                                    posts.removeAt(index);
                                                  });
                                                }
                                              });
                                            }
                                          },
                                          itemBuilder: (context) {
                                            return <PopupMenuEntry<String>>[
                                              const PopupMenuItem(
                                                value: "delete",
                                                child: ListTile(
                                                    leading: Icon(
                                                      Icons.delete,
                                                      color: Colors.black,
                                                    ),
                                                    title: Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    )),
                                              ),
                                            ];
                                          },
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(
                                              right: (screenWidth / 100) * 3.5),
                                          child: InkWell(
                                              onTap: () async {
                                                DataBase db = DataBase();
                                                Users otherUser =
                                                    await db.getUser(
                                                            posts[index].userId)
                                                        as Users;
                                                if (widget.user.following
                                                    .contains(
                                                        posts[index].userId)) {
                                                  removeRelationship(otherUser,
                                                          widget.user, db)
                                                      .then((value) {
                                                    if (value) {
                                                      setState(() {
                                                        //Updates the UI
                                                      });
                                                    }
                                                  });
                                                } else {
                                                  addRelationship(otherUser,
                                                          widget.user, db)
                                                      .then((value) {
                                                    if (value) {
                                                      setState(() {
                                                        //updates the UI
                                                      });
                                                    }
                                                  });
                                                }
                                              },
                                              child: Container(
                                                height: 33,
                                                width: 110,
                                                decoration: BoxDecoration(
                                                  color: mobileBackgroundColor,
                                                  border: Border.all(
                                                      color: Colors.white),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Center(
                                                    child: widget.user.following
                                                            .contains(
                                                                posts[index]
                                                                    .userId)
                                                        ? const Text(
                                                            "Following",
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
                                                          )),
                                              )),
                                        ),
                                ]),
                          ),
                          const Divider(
                            height: 0.5,
                            thickness: 0.5,
                            indent: null,
                            endIndent: null,
                            color: Colors.white,
                          ),
                          GestureDetector(
                            child:
                                Stack(alignment: Alignment.center, children: [
                              Container(
                                  width: screenWidth,
                                  height: screenHeight - 380,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(0),
                                    image: DecorationImage(
                                      image: NetworkImage(posts[index].postLoc),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  )),
                              Opacity(
                                opacity: isHeartAnimating ? 1 : 0,
                                child: HeartAnimationWidget(
                                    isAnimating: isHeartAnimating,
                                    duration: const Duration(milliseconds: 750),
                                    onEnd: () {
                                      setState(() {
                                        isHeartAnimating = false;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                      size: 100,
                                    )),
                              )
                            ]),
                            onDoubleTap: () async {
                              setState(() {
                                isHeartAnimating = true;
                                if (!isLiked) {
                                  posts[index].totalLikes += 1;
                                  posts[index].likesList.add(user.userId);
                                }
                              });
                              if (!isLiked) {
                                count[index]++;

                                if (count[index] <= 3) {
                                  await DataBase().addLike(posts[index], user);
                                  if (count[index] <= 1) {
                                    sendLikeNotification(user, posts[index]);
                                  }
                                }
                                isLiked = true;
                                if (widget.rebuilt != null) {
                                  await widget.rebuilt!();
                                }
                              }
                            },
                          ),
                          const Divider(
                            height: 0.5,
                            thickness: 0.5,
                            indent: null,
                            endIndent: null,
                            color: Colors.white,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          count[index]++;
                                          if (posts[index]
                                              .likesList
                                              .contains(user.userId)) {
                                            setState(() {
                                              isLiked = false;
                                              posts[index]
                                                  .likesList
                                                  .remove(user.userId);
                                              posts[index].totalLikes -= 1;
                                            });
                                            if (count[index] <= 3) {
                                              await DataBase().removeLike(
                                                  posts[index], user);
                                              DataBase().deleteNotification(
                                                  posts[index],
                                                  user,
                                                  null,
                                                  true,
                                                  false,
                                                  false);
                                            }
                                          } else {
                                            setState(() {
                                              isHeartAnimating = true;
                                              isLiked = true;
                                              posts[index]
                                                  .likesList
                                                  .add(user.userId);
                                              posts[index].totalLikes += 1;
                                            });
                                            if (count[index] <= 3) {
                                              await DataBase()
                                                  .addLike(posts[index], user);

                                              if (count[index] <= 1) {
                                                sendLikeNotification(
                                                    user, posts[index]);
                                              }
                                            }
                                          }
                                          if (widget.rebuilt != null) {
                                            await widget.rebuilt!();
                                          }
                                        },
                                        icon: posts[index]
                                                .likesList
                                                .contains(user.userId)
                                            ? const Icon(
                                                Icons.favorite,
                                                size: 32,
                                                color: Color.fromARGB(
                                                    255, 230, 29, 15),
                                              )
                                            : const Icon(
                                                Icons.favorite_border_outlined,
                                                size: 32,
                                                color: Colors.white,
                                              )),
                                    IconButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            useRootNavigator: true,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 34, 38, 41),
                                            context: context,
                                            builder: (context) {
                                              return CustomBottomSheet(
                                                screenHeight: screenHeight,
                                                screenWidth: screenWidth,
                                                ownerUser: user,
                                                post: posts[index],
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.mode_comment_outlined,
                                          color: Colors.white,
                                          size: 30,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            useSafeArea: false,
                                            showDragHandle: true,
                                            isScrollControlled: true,
                                            useRootNavigator: true,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 34, 38, 41),
                                            context: context,
                                            builder: (context) {
                                              return ShareBottomSheet(
                                                  ownerUser: user,
                                                  post: posts[index]);
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.send,
                                          color: Colors.white,
                                          size: 30,
                                        ))
                                  ]),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                posts[index].totalLikes > 3
                                    ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                            CircleAvatar(
                                              radius: 10,
                                              backgroundImage: AssetImage(
                                                  'assets/blankprofile.png'),
                                            ),
                                            CircleAvatar(
                                                radius: 10,
                                                backgroundImage: AssetImage(
                                                    'assets/blankprofile.png')),
                                            CircleAvatar(
                                                radius: 10,
                                                backgroundImage: AssetImage(
                                                    'assets/blankprofile.png'))
                                          ])
                                    : const Text(""),
                                posts[index].totalLikes == 1
                                    ? Text(
                                        "   ${posts[index].totalLikes} Like",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400),
                                      )
                                    : Text(
                                        "   ${posts[index].totalLikes} Likes",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400),
                                      )
                              ]),
                          const SizedBox(
                            height: 3,
                          ),
                          seeMore[index] == false
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 6),
                                      child: Text(
                                        userName,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    posts[index].content!.length > 28
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                (posts[index].content!)
                                                    .substring(
                                                        0,
                                                        38 -
                                                            posts[index]
                                                                .userName
                                                                .length),
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      seeMore[index] = true;
                                                    });
                                                  },
                                                  icon: const Icon(
                                                      Icons.more_horiz,
                                                      color: Colors.white,
                                                      size: 20))
                                            ],
                                          )
                                        : Text(posts[index].content!),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 6),
                                        child: Text(
                                          userName,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      TextField(
                                        enabled: false,
                                        controller: TextEditingController(
                                            text: posts[index].content),
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelStyle:
                                                TextStyle(color: Colors.white)),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 15),
                                        maxLines: null,
                                      ),
                                      Center(
                                        child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                seeMore[index] = false;
                                              });
                                            },
                                            child: const Text(
                                              'Show less',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            )),
                                      )
                                    ]),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 6),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "$totalComments Comments",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ]),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    posts[index]
                                        .uploadDateTime
                                        .toString()
                                        .substring(0, 11),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
    );
  }
}
