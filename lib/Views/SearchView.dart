import 'package:flutter/material.dart';
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
  DataBase db = DataBase();
  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double oneContainerWidth = (screenWidth - 4 / 3);
    return Scaffold(
        body: CustomScrollView(
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
        FutureBuilder(
          future: db.getForYouPagePosts(user),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                {
                  if (snapshot.hasData) {
                    List<Posts> posts = snapshot.data as List<Posts>;
                    posts.sort(
                        (a, b) => b.uploadDateTime.compareTo(a.uploadDateTime));
                    return SliverPadding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 3,
                                mainAxisSpacing: 3),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewPost(
                                            posts: posts, index1: index),
                                      ));
                                },
                                child: Container(
                                    width: oneContainerWidth,
                                    height: oneContainerWidth,
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 38, 38, 38),
                                      borderRadius: BorderRadius.circular(0),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          posts[index].postLoc,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    )));
                          },
                          childCount: posts.length,
                        ),
                      ),
                    );
                  } else {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Icon(Icons.error),
                      ),
                    );
                  }
                }
              default:
                return const SliverToBoxAdapter(
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Colors.white,
                  )),
                );
            }
          },
        )
      ],
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
