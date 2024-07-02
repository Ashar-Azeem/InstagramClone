// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mysocialmediaapp/Views/visitingProfileView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/HomeScreenItems.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:mysocialmediaapp/utilities/heartAnimation.dart';

class HomeView extends StatefulWidget {
  final Users user;

  const HomeView({super.key, required this.user});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  bool rebuilt = false;
  bool isHeartAnimating = false;
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
          body: Column(children: [
            FutureBuilder(
                future: DataBase().getStories(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      {
                        var data = snapshot.data as List<String>;
                        return Expanded(
                          child: ListView(children: [
                            Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 7,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: data.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: [
                                              InkWell(
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.5),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            4,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            10,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          //Change the color of unseen stories
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 61, 61, 65),
                                                          width: 3,
                                                        )),
                                                    child: const CircleAvatar(
                                                      backgroundColor:
                                                          Colors.orange,
                                                      radius: 20,
                                                    )),
                                              ),
                                              Text(data[index])
                                            ],
                                          );
                                        }))),
                            FirestorePagination(
                                shrinkWrap: true,
                                viewType: ViewType.list,
                                onEmpty: const Text(
                                    'No Exploring data is available at the moment'),
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
                                limit: 12,
                                query: FirebaseFirestore.instance
                                    .collection('posts')
                                    .where('userId',
                                        whereIn: ownerUser.following)
                                    .orderBy('uploadDateTime',
                                        descending: true),
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
                                        index: index),
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
  List<String> likesList = List<String>.from(data['likesList']);

  DateTime dartDate = firebaseDate.toDate();

  Posts post = Posts(postId, totalLikes, totalComments, userId, userName,
      profileLoc, postLoc, content, dartDate, likesList);

  return post;
}
