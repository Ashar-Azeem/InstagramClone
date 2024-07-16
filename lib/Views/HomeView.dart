// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mysocialmediaapp/Views/AddStoryView.dart';
import 'package:mysocialmediaapp/Views/MessagesView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/HomeScreenItems.dart';
import 'package:mysocialmediaapp/utilities/StoriesList.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:mysocialmediaapp/utilities/utilities.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sizer/sizer.dart';

class HomeView extends StatefulWidget {
  final Users user;

  const HomeView({super.key, required this.user});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isHeartAnimating = false;
  late List<bool> seeMore;
  late Users ownerUser;
  DataBase db = DataBase();
  List<Posts> documents = [];
  List<Story> userStories = [];
  List<List<Story>> data = [];

  @override
  void initState() {
    super.initState();
    seeMore = List.filled(100, false);
    ownerUser = widget.user;
  }

  List<Story> seperateOwnerUserStories(List<List<Story>> total) {
    for (List<Story> s in total) {
      if (s[0].userId == ownerUser.userId) {
        total.remove(s);
        return s;
      }
    }

    return [];
  }

  Future<void> refresh() async {
    var user = await db.getUser(ownerUser.userId, true);
    setState(() {
      ownerUser = user!;
      data.clear();
      userStories.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    data.clear();
    userStories.clear();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = 100.w;
    var screenHeight = 100.h;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        int sensitivity = 10;
        if (details.delta.dx > sensitivity) {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: (AddStoryView(
              user: ownerUser,
              stories: userStories,
            )),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.slideRight,
          );
          // Right Swipe
        } else if (details.delta.dx < -sensitivity) {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: (MessagesView(
              user: ownerUser,
            )),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
          //Left Swipe
        }
      },
      child: Scaffold(
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
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('chats')
                                .where(Filter.or(
                                    Filter('user1UserId',
                                        isEqualTo: ownerUser.userId),
                                    Filter('user2UserId',
                                        isEqualTo: ownerUser.userId)))
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<DocumentSnapshot> documents =
                                    snapshot.data!.docs;
                                for (var d in documents) {
                                  var chat = getChatObject(d);
                                  if (chat.user1UserId == ownerUser.userId) {
                                    if (!chat.user1Seen) {
                                      return Stack(
                                          alignment: Alignment.centerRight,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                PersistentNavBarNavigator
                                                    .pushNewScreen(
                                                  context,
                                                  screen: (MessagesView(
                                                    user: ownerUser,
                                                  )),
                                                  withNavBar: false,
                                                  pageTransitionAnimation:
                                                      PageTransitionAnimation
                                                          .cupertino,
                                                );
                                              },
                                              icon: Image.asset(
                                                'assets/messageIcon.png',
                                                height: 30,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.circle,
                                              color: Colors.red,
                                              size: 13.5,
                                            )
                                          ]);
                                    }
                                  } else {
                                    if (!chat.user2Seen) {
                                      return Stack(
                                          alignment: Alignment.centerRight,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                PersistentNavBarNavigator
                                                    .pushNewScreen(
                                                  context,
                                                  screen: (MessagesView(
                                                    user: ownerUser,
                                                  )),
                                                  withNavBar: false,
                                                  pageTransitionAnimation:
                                                      PageTransitionAnimation
                                                          .cupertino,
                                                );
                                              },
                                              icon: Image.asset(
                                                'assets/messageIcon.png',
                                                height: 30,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.circle,
                                              color: Colors.red,
                                              size: 13.5,
                                            )
                                          ]);
                                    }
                                  }
                                }
                                return IconButton(
                                  onPressed: () {
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: (MessagesView(
                                        user: ownerUser,
                                      )),
                                      withNavBar: false,
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  icon: Image.asset(
                                    'assets/messageIcon.png',
                                    height: 30,
                                  ),
                                );
                              } else {
                                return IconButton(
                                  onPressed: () {
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: (MessagesView(
                                        user: ownerUser,
                                      )),
                                      withNavBar: false,
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  icon: Image.asset(
                                    'assets/messageIcon.png',
                                    height: 30,
                                  ),
                                );
                              }
                            }),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: ScaffoldMessenger(
              child: RefreshIndicator(
                color: Colors.white,
                onRefresh: refresh,
                child: Column(children: [
                  FutureBuilder(
                      future: DataBase().getStories(ownerUser),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            {
                              data = snapshot.data as List<List<Story>>;

                              userStories = seperateOwnerUserStories(data);

                              return Expanded(
                                child: ListView(children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.only(top: 5, bottom: 2.h),
                                      child: StoriesRow(
                                          data: data,
                                          userStories: userStories,
                                          ownerUser: ownerUser)),
                                  FirestorePagination(
                                      isLive: true,
                                      shrinkWrap: true,
                                      viewType: ViewType.list,
                                      onEmpty: const Text('No Posts Available'),
                                      initialLoader: const SizedBox.shrink(),
                                      bottomLoader: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      limit: 12,
                                      query: ownerUser.following.isNotEmpty
                                          ? FirebaseFirestore.instance
                                              .collection('posts')
                                              .where('userId',
                                                  whereIn: ownerUser.following)
                                              .orderBy('uploadDateTime',
                                                  descending: true)
                                          : FirebaseFirestore.instance
                                              .collection('posts')
                                              .orderBy('uploadDateTime',
                                                  descending: true)
                                              .where(FieldPath.documentId,
                                                  whereIn:
                                                      ownerUser.publicPosts!),
                                      itemBuilder: (context, snapshot, index) {
                                        var post = getObject(snapshot);
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 6, right: 6),
                                          child: HomeScreenItems(
                                            post: post,
                                            ownerUser: ownerUser,
                                            screenHeight: screenHeight,
                                            screenWwidth: screenWidth,
                                            seeMore: seeMore,
                                            index: index,
                                            rebuilt: refresh,
                                            stories: data,
                                          ),
                                        );
                                      })
                                ]),
                              );
                            }

                          default:
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            );
                        }
                      }),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
  List<String> likesList = List<String>.from(data['likesList']);

  DateTime dartDate = firebaseDate.toDate();

  Posts post = Posts(postId, totalLikes, totalComments, userId, userName,
      profileLoc, postLoc, content, dartDate, likesList);

  return post;
}
