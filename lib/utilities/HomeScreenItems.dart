import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/Views/visitingProfileView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/heartAnimation.dart';

class HomeScreenItems extends StatefulWidget {
  final Posts post;
  final Users ownerUser;
  final double screenHeight;
  final double screenWwidth;
  final List<bool> seeMore;
  final int index;

  const HomeScreenItems(
      {super.key,
      required this.post,
      required this.ownerUser,
      required this.screenHeight,
      required this.screenWwidth,
      required this.seeMore,
      required this.index});

  @override
  State<HomeScreenItems> createState() => _HomeScreenItemsState();
}

class _HomeScreenItemsState extends State<HomeScreenItems> {
  late Posts post;
  late Users ownerUser;
  late double screenWidth;
  late double screenHeight;
  late List<bool> seeMore;
  late int index;
  bool isHeartAnimating = false;
  @override
  void initState() {
    super.initState();
    post = widget.post;
    ownerUser = widget.ownerUser;
    screenWidth = widget.screenWwidth;
    screenHeight = widget.screenHeight;
    seeMore = widget.seeMore;
    index = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    bool isLiked = post.likesList.contains(ownerUser.userId);
    return SizedBox(
      width: screenWidth,
      height: seeMore[index] == false ? screenHeight - 150 : screenHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 1.0, // Border width
                        )),
                    child: post.profLoc == null
                        ? const CircleAvatar(
                            backgroundColor: Colors.black,
                            backgroundImage:
                                AssetImage('assets/blankprofile.png'),
                            radius: 30,
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.black,
                            backgroundImage: NetworkImage(post.profLoc!),
                            radius: 30,
                          ),
                  ),
                ),
                TextButton(
                    onPressed: () async {
                      Users user1 =
                          await DataBase().getUser(post.userId, false) as Users;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VisitingProfileView(
                                  user: user1, ownerUser: ownerUser)));
                    },
                    child: Text("  ${post.userName}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500)))
              ],
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: GestureDetector(
              child: Stack(alignment: Alignment.center, children: [
                Container(
                    width: screenWidth,
                    height: screenHeight - 380,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      image: DecorationImage(
                        image: NetworkImage(post.postLoc),
                        fit: BoxFit.cover,
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
                    post.totalLikes += 1;
                    post.likesList.add(ownerUser.userId);
                  }
                });
                if (!isLiked) {
                  await DataBase().addLike(post, ownerUser);
                  isLiked = true;
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          onPressed: () async {
                            if (post.likesList.contains(ownerUser.userId)) {
                              setState(() {
                                isLiked = false;
                                post.likesList.remove(ownerUser.userId);
                                post.totalLikes -= 1;
                              });
                              await DataBase().removeLike(post, ownerUser);
                            } else {
                              setState(() {
                                isLiked = true;
                                post.likesList.add(ownerUser.userId);
                                post.totalLikes += 1;
                              });
                              await DataBase().addLike(post, ownerUser);
                            }
                          },
                          icon: post.likesList.contains(ownerUser.userId)
                              ? const Icon(
                                  Icons.favorite,
                                  size: 32,
                                  color: Color.fromARGB(255, 230, 29, 15),
                                )
                              : const Icon(
                                  Icons.favorite_border_outlined,
                                  size: 32,
                                  color: Colors.white,
                                )),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.mode_comment_outlined,
                            color: Colors.white,
                            size: 30,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 30,
                          ))
                    ]),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            post.totalLikes > 3
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage:
                              AssetImage('assets/blankprofile.png'),
                        ),
                        CircleAvatar(
                            radius: 10,
                            backgroundImage:
                                AssetImage('assets/blankprofile.png')),
                        CircleAvatar(
                            radius: 10,
                            backgroundImage:
                                AssetImage('assets/blankprofile.png'))
                      ])
                : const Text(""),
            post.totalLikes == 1
                ? Text(
                    "   ${post.totalLikes} Like",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w400),
                  )
                : Text(
                    "   ${post.totalLikes} Likes",
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
                      padding: const EdgeInsets.only(left: 10, right: 6),
                      child: Text(
                        post.userName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    post.content!.length > 28
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                (post.content!)
                                    .substring(0, 38 - post.userName.length),
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      seeMore[index] = true;
                                    });
                                  },
                                  icon: const Icon(Icons.more_horiz,
                                      color: Colors.white, size: 20))
                            ],
                          )
                        : Text(post.content!),
                  ],
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 6),
                    child: Text(
                      post.userName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextField(
                    enabled: false,
                    controller: TextEditingController(text: post.content),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.white)),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
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
                          style: TextStyle(color: Colors.grey),
                        )),
                  )
                ]),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 6),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text(
                "${post.totalComments} Comments",
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
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text(
                post.uploadDateTime.toString().substring(0, 11),
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
  }
}
