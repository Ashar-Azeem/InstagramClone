// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/Views/AddpostView.dart';
import 'package:mysocialmediaapp/Views/HomeView.dart';
import 'package:mysocialmediaapp/Views/NotificationView.dart';
import 'package:mysocialmediaapp/Views/ProfileView.dart';
import 'package:mysocialmediaapp/Views/SearchView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

class MainUI extends StatefulWidget {
  const MainUI({super.key});

  @override
  State<MainUI> createState() => _MainUIState();
}

class _MainUIState extends State<MainUI> {
  bool newDP = false;
  int currentPage = 0;
  static late Users user;
  static final DataBase db = DataBase();
  PersistentTabController pageController =
      PersistentTabController(initialIndex: 0);

  late List<Widget> navigation;

  @override
  void dispose() {
    PostsCollection().clear();
    Following().clear();
    super.dispose();
  }

  void initList() {
    navigation = [
      HomeView(user: user),
      SearchView(user: user),
      AddPostView(user: user),
      NotificationView(user: user),
      ProfileView(user: user)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: db.getUser(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            user = snapshot.data as Users;
            //Assign value to valuenotifier so that they could be used in UI
            ProfilePicture().set(location: user.imageLoc);
            Following().updateFollowing(user.following);
            Followers().updateFollowers(user.followers);
            initList();
            return ValueListenableBuilder(
                valueListenable: ProfilePicture(),
                builder: (context, value, child) {
                  final imageLocation = value;
                  return PersistentTabView(context, screens: navigation,
                      onWillPop: (p0) {
                    if (pageController.index == 0) {
                      SystemNavigator.pop();
                    } else if (pageController.index > 0 &&
                        pageController.index < 5) {
                      pageController.jumpToTab(0);
                    }
                    return Future(() => false);
                  },
                      handleAndroidBackButtonPress: false,
                      controller: pageController,
                      navBarStyle: NavBarStyle.style6,
                      hideNavigationBarWhenKeyboardAppears: true,
                      decoration: const NavBarDecoration(
                          border: Border(
                              top: BorderSide(width: 1, color: Colors.grey))),
                      backgroundColor: mobileBackgroundColor,
                      items: [
                        PersistentBottomNavBarItem(
                          icon: const Icon(
                            Icons.home_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        PersistentBottomNavBarItem(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        PersistentBottomNavBarItem(
                          icon: const Icon(
                            Icons.add_box_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        PersistentBottomNavBarItem(
                          icon: const Icon(Icons.favorite),
                          activeColorPrimary: Colors.white,
                          activeColorSecondary: Colors.red,
                          iconSize: 30,
                        ),
                        PersistentBottomNavBarItem(
                            icon: Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 116, 116, 116),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageLocation == null
                                        ? const AssetImage(
                                                'assets/blankprofile.png')
                                            as ImageProvider
                                        : NetworkImage(imageLocation),
                                    fit: BoxFit.fitWidth,
                                  ),
                                )),
                            iconSize: 30)
                      ]);
                });

          default:
            {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            }
        }
      },
    );
  }
}
