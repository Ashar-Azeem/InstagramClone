// ignore_for_file: file_names

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/Views/SearchBar.dart';
import 'package:mysocialmediaapp/Views/ViewPost.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class SearchView extends StatefulWidget {
  final Users user;
  const SearchView({super.key, required this.user});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with AutomaticKeepAliveClientMixin {
  bool rebuilt = false;
  late Users user;
  List<Posts> documents = [];
  DataBase db = DataBase();

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  void check(Posts post) {
    for (Posts p in documents) {
      if (p.postId == post.postId) {
        return;
      }
    }
    documents.add(post);
  }

  Future<void> refresh() async {
    var user1 = await db.getUser(user.userId, true);
    setState(() {
      user = user1!;
      rebuilt = !rebuilt;
      documents = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Colors.white,
        child: SafeArea(
          child: CustomScrollView(slivers: [
            SliverAppBar(
              pinned: true,
              forceMaterialTransparency: true,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
              title: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(MediaQuery.of(context).size.width - 25,
                        ((MediaQuery.of(context).size.height) / 100) * 5),
                    backgroundColor: Colors.grey.shade900,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: (SearchBarView(messaging: false, user: user)),
                      withNavBar: true,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 17),
                          child: Text(
                            'Search',
                            style: TextStyle(
                                fontSize: 17, color: Colors.grey.shade400),
                          ))
                    ],
                  )),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              sliver: SliverToBoxAdapter(
                child: user.publicPosts == null
                    ? const Text("No Posts yet")
                    : FirestorePagination(
                        key: ValueKey(rebuilt),
                        isLive: true,
                        shrinkWrap: true,
                        viewType: ViewType.grid,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 2,
                                childAspectRatio: 0.945),
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
                        limit: 18,
                        query: FirebaseFirestore.instance
                            .collection('posts')
                            .orderBy('uploadDateTime', descending: true)
                            .where(FieldPath.documentId,
                                whereIn: user.publicPosts!),
                        itemBuilder: (context, snapshot, index) {
                          var post = getObject(snapshot);
                          check(post);
                          // if (user.following.contains(post.userId)) {
                          //   return SizedBox.shrink();
                          // }
                          return InkWell(
                              onTap: () async {
                                Posts post = documents[index];
                                List<Posts> sublist = documents
                                    .where((element) =>
                                        element.userId == post.userId)
                                    .toList();

                                var range = 12;
                                var length = sublist.length;
                                if (length < range) {
                                  for (var i = 0; i < range - length; i++) {
                                    var l = documents
                                        .where((element) =>
                                            !sublist.contains(element))
                                        .toList();
                                    var element = Random().nextInt(l.length);
                                    sublist.add(l[element]);
                                  }
                                }
                                sublist.removeWhere(
                                    (element) => element.postId == post.postId);
                                sublist.shuffle();
                                sublist.insert(0, post);

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewPost(
                                        posts: sublist,
                                        index1: 0,
                                        personal: false,
                                        user: user,
                                        rebuilt: refresh,
                                      ),
                                    ));
                              },
                              child: Material(
                                type: MaterialType.transparency,
                                child: Container(
                                    decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 38, 38, 38),
                                  borderRadius: BorderRadius.circular(0),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      post.postLoc,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )),
                              ));
                        },
                      ),
              ),
            )
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
