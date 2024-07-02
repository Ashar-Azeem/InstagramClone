import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/Views/F&FView.dart';
import 'package:mysocialmediaapp/Views/ViewPost.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:mysocialmediaapp/utilities/state.dart';

class VisitingProfileView extends StatefulWidget {
  final Users ownerUser;
  final Users user;
  const VisitingProfileView(
      {super.key, required this.user, required this.ownerUser});

  @override
  State<VisitingProfileView> createState() => _VisitingProfileViewState();
}

class _VisitingProfileViewState extends State<VisitingProfileView> {
  DataBase db = DataBase();
  late List<Posts> posts;
  String totalPosts = "0";
  late Users ownerUser;
  late Users user;

  @override
  void initState() {
    user = widget.user;
    ownerUser = widget.ownerUser;
    super.initState();
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
    double screenWidth = MediaQuery.of(context).size.width;
    double oneContainerWidth = (screenWidth - 4 / 3);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          user.userName,
          style: const TextStyle(
              fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
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
                          backgroundImage:
                              AssetImage('assets/blankprofile.png'),
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
                      onTap: () {
                        if (checkFollowers(ownerUser.following)) {
                          removeRelationship(user, ownerUser, db).then((value) {
                            if (value) {
                              setState(() {
                                //Updates the UI
                              });
                            }
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
                        child: !checkFollowers(ownerUser.following)
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
                          onTap: () {},
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
                                padding:
                                    const EdgeInsets.only(left: 6, right: 6),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 3,
                                          mainAxisSpacing: 4),
                                  itemCount: posts.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
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
                                              ),
                                            ));
                                      },
                                      child: Container(
                                          width: oneContainerWidth,
                                          height: oneContainerWidth,
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 38, 38, 38),
                                            borderRadius:
                                                BorderRadius.circular(0),
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
                                color: blueColor,
                                minHeight: 2,
                              );
                            }
                          }
                        default:
                          {
                            return const LinearProgressIndicator(
                              color: blueColor,
                              minHeight: 2,
                            );
                          }
                      }
                    })
          ],
        ),
      )),
    );
  }
}
