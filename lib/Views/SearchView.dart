import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mysocialmediaapp/Views/SearchBar.dart';
import 'package:mysocialmediaapp/Views/ViewPost.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';

class SearchView extends StatefulWidget {
  final Users user;
  const SearchView({super.key, required this.user});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with AutomaticKeepAliveClientMixin {
  late Users user;
  int loaderController = 0;
  DataBase db = DataBase();
  List<Posts> documents = [];
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 18;
  int currentPosition = 0;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });
    // Determine the range of document IDs to fetch
    int endPosition = currentPosition + documentLimit;
    if (endPosition > user.publicPosts!.length) {
      endPosition = user.publicPosts!.length;
      hasMore = false;
    }
    List<String> docIdsToFetch =
        user.publicPosts!.sublist(currentPosition, endPosition);

    List<Posts> fetchedPosts = [];
    fetchedPosts = await db.getForYouPagePosts(docIdsToFetch);
    print(fetchedPosts.length);
    setState(() {
      documents.addAll(fetchedPosts);
      isLoading = false;
      currentPosition = endPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
        body: NotificationListener(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _fetchPosts();
          return true;
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchBarView(
                                user: user,
                              )));
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
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 0.945),
              delegate: SliverChildBuilderDelegate((context, index) {
                loaderController = index + 1;
                if (index == documents.length) {
                  return const SizedBox();
                }
                if (index > documents.length) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }
                return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewPost(
                              posts: documents,
                              index1: index,
                              personal: false,
                              user: user,
                            ),
                          ));
                    },
                    child: Container(
                        decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 38, 38, 38),
                      borderRadius: BorderRadius.circular(0),
                      image: DecorationImage(
                        image: NetworkImage(
                          documents[index].postLoc,
                        ),
                        fit: BoxFit.cover,
                      ),
                    )));
              }, childCount: documents.length + (hasMore ? 2 : 0)),
            ),
          ),
        ],
      ),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
