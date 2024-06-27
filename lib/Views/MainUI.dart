import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/Views/AddpostView.dart';
import 'package:mysocialmediaapp/Views/HomeView.dart';
import 'package:mysocialmediaapp/Views/NotificationView.dart';
import 'package:mysocialmediaapp/Views/ProfileView.dart';
import 'package:mysocialmediaapp/Views/SearchView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

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
      const NotificationView(),
      ProfileView(user: user)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: db.getUser(FirebaseAuth.instance.currentUser!.uid, true),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            user = snapshot.data as Users;
            //Assign value to valuenotifier so that they could be used in UI
            ProfilePicture().set(location: user.imageLoc);
            Following().updateFollowing(user.following);
            initList();
            return ValueListenableBuilder(
                valueListenable: ProfilePicture(),
                builder: (context, value, child) {
                  final imageLocation = value;
                  return PersistentTabView(context,
                      screens: navigation,
                      controller: pageController,
                      navBarStyle: NavBarStyle.style6,
                      hideNavigationBarWhenKeyboardShows: true,
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
                            icon: const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 30,
                        )),
                        customNavigationBarItem(
                            icon: Icons.abc,
                            label: "",
                            avatarImage: imageLocation)
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

  PersistentBottomNavBarItem customNavigationBarItem({
    required IconData icon,
    required String label,
    required String? avatarImage,
  }) {
    return avatarImage != null
        ? PersistentBottomNavBarItem(
            icon: Container(
              width: 35.0,
              height: 35.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white, // Border color
                    width: 1.0, // Border width
                  )),
              child: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: NetworkImage(avatarImage),
                radius: 14,
              ),
            ),
          )
        : PersistentBottomNavBarItem(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/blankprofile.png'),
              radius: 15,
            ),
          );
  }
}
