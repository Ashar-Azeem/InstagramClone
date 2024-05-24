import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/services/firebase.dart';
import 'package:mysocialmediaapp/utilities/color.dart';

class ViewPost extends StatefulWidget {
  final List<Posts> posts;
  final int index1;
  const ViewPost({super.key, required this.posts, required this.index1});

  @override
  State<ViewPost> createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  bool loading = false;
  late List<bool> seeMore;
  late List<Posts> posts;
  late int index1;
  late double size;
  late ScrollController _controller;
  @override
  void initState() {
    super.initState();
    posts = widget.posts;
    seeMore = List.generate(posts.length, (index) => false);
    index1 = widget.index1;
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex();
    });
  }

  void _scrollToIndex() {
    _controller.jumpTo(
      index1 * size,
    );
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
          title: const Text(
            "Posts",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                    int totalLikes = posts[index].totalLikes;
                    int totalComments = posts[index].totalComments;
                    String userName = posts[index].userName;
                    return SizedBox(
                      width: screenWidth,
                      height: seeMore[index] == false
                          ? screenHeight - 150
                          : screenHeight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48.0,
                                      height: 48.0,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white, // Border color
                                            width: 1.0, // Border width
                                          )),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black,
                                        backgroundImage:
                                            NetworkImage(posts[index].profLoc!),
                                        radius: 30,
                                      ),
                                    ),
                                    Text(
                                      "  ${posts[index].userName}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
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
                                                .deletePost(posts[index].postId,
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
                                    : const SizedBox.shrink()
                              ]),
                          Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Container(
                                width: screenWidth,
                                height: screenHeight - 380,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(0),
                                  image: DecorationImage(
                                    image: NetworkImage(posts[index].postLoc),
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
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
                                Text(
                                  "   $totalLikes people liked your post",
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
