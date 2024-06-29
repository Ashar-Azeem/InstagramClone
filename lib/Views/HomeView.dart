// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mysocialmediaapp/Views/visitingProfileView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';

class HomeView extends StatefulWidget {
  final Users user;
  const HomeView({super.key, required this.user});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  late List<bool> seeMore;
  late Users ownerUser;
  DataBase db = DataBase();
  List<Posts> documents = [];
  @override
  void initState() {
    super.initState();
    seeMore = List.filled(100, false);
    ownerUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 7),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/logo.svg',
                        color: primaryColor,
                        height: 36,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/messageIcon.png',
                          height: 30,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ];
          },
          body: FutureBuilder(
            future: DataBase().getStories(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  {
                    var data = snapshot.data as List<String>;
                    return ListView(children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height / 7,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    InkWell(
                                      child: Container(
                                          padding: const EdgeInsets.all(3.5),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              10,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                //Change the color of unseen stories
                                                color: const Color.fromARGB(
                                                    255, 61, 61, 65),
                                                width: 3,
                                              )),
                                          child: const CircleAvatar(
                                            backgroundColor: Colors.orange,
                                            radius: 20,
                                          )),
                                    ),
                                    Text(data[index])
                                  ],
                                );
                              },
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 10, right: 5),
                        child: FirestorePagination(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          limit: 10,
                          onEmpty: const Center(
                            child: Text('Start following people to get posts'),
                          ),
                          bottomLoader: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          initialLoader: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          query: FirebaseFirestore.instance
                              .collection('posts')
                              .where('userId', whereIn: ownerUser.following)
                              .orderBy('uploadDateTime'),
                          itemBuilder: (context, snapshot, index) {
                            var post = getObject(snapshot);
                            return SizedBox(
                              width: screenWidth,
                              height: seeMore[index] == false
                                  ? screenHeight - 150
                                  : screenHeight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: Container(
                                                width: 48.0,
                                                height: 48.0,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors
                                                          .white, // Border color
                                                      width:
                                                          1.0, // Border width
                                                    )),
                                                child: post.profLoc == null
                                                    ? const CircleAvatar(
                                                        backgroundColor:
                                                            Colors.black,
                                                        backgroundImage: AssetImage(
                                                            'assets/blankprofile.png'),
                                                        radius: 30,
                                                      )
                                                    : CircleAvatar(
                                                        backgroundColor:
                                                            Colors.black,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                post.profLoc!),
                                                        radius: 30,
                                                      ),
                                              ),
                                            ),
                                            TextButton(
                                                onPressed: () async {
                                                  Users user1 = await DataBase()
                                                      .getUser(post.userId,
                                                          false) as Users;
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              VisitingProfileView(
                                                                  user: user1,
                                                                  ownerUser:
                                                                      ownerUser)));
                                                },
                                                child: Text(
                                                    "  ${post.userName}",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500)))
                                          ],
                                        ),
                                      ]),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 7),
                                    child: Container(
                                        width: screenWidth,
                                        height: screenHeight - 380,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                          image: DecorationImage(
                                            image: NetworkImage(post.postLoc),
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: const Icon(
                                                    Icons
                                                        .favorite_border_outlined,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        post.totalLikes > 3
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
                                          "   ${post.totalLikes} people liked your post",
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 6),
                                              child: Text(
                                                post.userName,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13.5,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            post.content!.length > 28
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        (post.content!).substring(
                                                            0,
                                                            38 -
                                                                post.userName
                                                                    .length),
                                                      ),
                                                      IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              seeMore[index] =
                                                                  true;
                                                            });
                                                          },
                                                          icon: const Icon(
                                                              Icons.more_horiz,
                                                              color:
                                                                  Colors.white,
                                                              size: 20))
                                                    ],
                                                  )
                                                : Text(post.content!),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 6),
                                                child: Text(
                                                  post.userName,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              TextField(
                                                enabled: false,
                                                controller:
                                                    TextEditingController(
                                                        text: post.content),
                                                decoration:
                                                    const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        labelStyle: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15),
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
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    )),
                                              )
                                            ]),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 10, top: 6),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${post.totalComments}l Comments",
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            post.uploadDateTime
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
                          },
                        ),
                      ),
                    ]);
                  }
                default:
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Posts getObject(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  String postId = snapshot.id;
  String userId = data['userId'] as String;
  String userName = data['userName'] as String;
  String? profileLoc = data['profileLoc'] as String?;
  String postLoc = data['postLoc'] as String;
  String? content = data['content'] as String?;
  int totalLikes = data['totalLikes'] as int;
  int totalComments = data['totalComments'] as int;
  Timestamp firebaseDate = data['uploadDateTime'] as Timestamp;

  DateTime dartDate = firebaseDate.toDate();

  Posts post = Posts(postId, totalLikes, totalComments, userId, userName,
      profileLoc, postLoc, content, dartDate);

  return post;
}
