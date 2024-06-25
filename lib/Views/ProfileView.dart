import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysocialmediaapp/Views/ViewPost.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/services/firebase.dart';
import 'package:mysocialmediaapp/utilities/const.dart';
import 'package:mysocialmediaapp/utilities/state.dart';
import 'package:mysocialmediaapp/utilities/utilities.dart';

class ProfileView extends StatefulWidget {
  final Users user;
  const ProfileView({super.key, required this.user});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with AutomaticKeepAliveClientMixin {
  DataBase db = DataBase();
  String totalPosts = "0";
  late Users user;
  late bool isPrivate;
  bool changingPrivacyLoading = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    isPrivate = user.isPrivate;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double oneContainerWidth = (screenWidth - 4 / 3);

    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 27.0),
              child: Text(
                user.userName,
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (String result) async {
                if (result == 'logout') {
                  PostsCollection().clear();
                  Following().clear();
                  await AuthService().logout();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(LoginRoute, (route) => false);
                } else if (result == 'isprivate') {
                  changePrivacy(user, db, PostsCollection().value).then(
                    (value) async {
                      if (value == "success") {
                        setState(() {
                          user.isPrivate = !isPrivate;
                          isPrivate = !isPrivate;
                        });
                      }
                    },
                  );
                }
              },
              itemBuilder: (context) {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem(
                    value: "logout",
                    child: ListTile(
                        leading: Icon(
                          Icons.logout_outlined,
                          color: Colors.black,
                        ),
                        title: Text(
                          'Logout',
                          style: TextStyle(color: Colors.black),
                        )),
                  ),
                  PopupMenuItem(
                      value: "isprivate",
                      child: ListTile(
                          leading: isPrivate
                              ? const Icon(
                                  Icons.lock,
                                  color: Colors.black,
                                )
                              : const Icon(
                                  Icons.lock_open,
                                  color: Colors.black,
                                ),
                          title: const Text(
                            'Privacy',
                            style: TextStyle(color: Colors.black),
                          )))
                ];
              },
            )
          ]),
          FutureBuilder(
            future: db.getPosts(user.userId, true),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ValueListenableBuilder(
                                valueListenable: ProfilePicture(),
                                builder: (context, value, child) {
                                  return user.imageLoc == null
                                      ? Container(
                                          width: 85.0,
                                          height: 85.0,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors
                                                    .white, // Border color
                                                width: 1.0, // Border width
                                              )),
                                          child: const CircleAvatar(
                                            backgroundColor: Colors.black,
                                            backgroundImage: AssetImage(
                                                'assets/blankprofile.png'),
                                            radius: 45,
                                          ),
                                        )
                                      : Container(
                                          width: 85.0,
                                          height: 85.0,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors
                                                    .white, // Border color
                                                width: 1.0, // Border width
                                              )),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.black,
                                            backgroundImage:
                                                NetworkImage(value!),
                                            radius: 45,
                                          ),
                                        );
                                }),
                            InkWell(
                              onTap: () {},
                              child: Column(
                                children: [
                                  ValueListenableBuilder(
                                    valueListenable: PostsCollection(),
                                    builder: (context, value, child) {
                                      return FutureBuilder(
                                          future: db.totalPost(user.userId),
                                          builder: (context, snapshot) {
                                            switch (snapshot.connectionState) {
                                              case ConnectionState.done:
                                                totalPosts =
                                                    snapshot.data!.toString();
                                                {
                                                  return Text(
                                                    totalPosts,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  );
                                                }
                                              default:
                                                {
                                                  return Text(
                                                    totalPosts,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  );
                                                }
                                            }
                                          });
                                    },
                                  ),
                                  const Text(
                                    "Posts",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {},
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
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: Column(
                                children: [
                                  ValueListenableBuilder(
                                    valueListenable: Following(),
                                    builder: (context, value, child) {
                                      return Text(
                                        (user.following.length).toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      );
                                    },
                                  ),
                                  const Text(
                                    "Following",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
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
                                padding:
                                    const EdgeInsets.only(left: 13, top: 10),
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                  onTap: () async {
                                    Uint8List? image =
                                        await imagepicker(ImageSource.gallery);

                                    if (image != null) {
                                      updatePorfileProcess(image, user)
                                          .then((value) async {
                                        if (value != null) {
                                          user = value;
                                        }
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 175,
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 38, 38, 38),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Edit profile",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )),
                              InkWell(
                                  onTap: () {},
                                  child: Container(
                                    height: 30,
                                    width: 175,
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 38, 38, 38),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Share profile",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )),
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
                        ValueListenableBuilder(
                            valueListenable: PostsCollection(),
                            builder: (context, value, child) {
                              List<Posts> posts =
                                  List.from(PostsCollection().value);
                              posts.sort((a, b) =>
                                  b.uploadDateTime.compareTo(a.uploadDateTime));

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
                                                personal: true,
                                                user: user,
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
                            })
                      ],
                    );
                  }
                default:
                  {
                    return Column(children: [
                      SizedBox(
                        height: (MediaQuery.of(context).size.height / 2) - 120,
                      ),
                      const Center(
                          child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ))
                    ]);
                  }
              }
            },
          ),
        ]),
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
