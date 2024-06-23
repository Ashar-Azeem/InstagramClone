import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/Views/AddpostView.dart';
import 'package:mysocialmediaapp/Views/HomeView.dart';
import 'package:mysocialmediaapp/Views/NotificationView.dart';
import 'package:mysocialmediaapp/Views/ProfileView.dart';
import 'package:mysocialmediaapp/Views/SearchView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';

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
  PageController pageController = PageController();

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
      ProfileView(
        user: user,
      )
    ];
  }

  void onTap(int i) {
    pageController.jumpToPage(i);
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
            return Scaffold(
                body: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: navigation,
                ),
                bottomNavigationBar: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: ProfilePicture(),
                      builder: (context, value, child) {
                        final imageLocation = value;
                        return BottomNavigationBar(
                            onTap: onTap,
                            selectedFontSize: 4.0,
                            unselectedFontSize: 4.0,
                            items: [
                              const BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.home_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  label: '',
                                  backgroundColor: mobileBackgroundColor),
                              const BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  label: '',
                                  backgroundColor: mobileBackgroundColor),
                              const BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.add_box_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  label: '',
                                  backgroundColor: mobileBackgroundColor),
                              const BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.favorite_border,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  label: '',
                                  backgroundColor: mobileBackgroundColor),
                              customNavigationBarItem(
                                  icon: Icons.abc,
                                  label: "",
                                  avatarImage: imageLocation)
                            ]);
                      },
                    )));

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

BottomNavigationBarItem customNavigationBarItem({
  required IconData icon,
  required String label,
  required String? avatarImage,
}) {
  return avatarImage != null
      ? BottomNavigationBarItem(
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
          label: label,
        )
      : BottomNavigationBarItem(
          icon: const CircleAvatar(
            backgroundImage: AssetImage('assets/blankprofile.png'),
            radius: 15,
          ),
          label: label,
        );
}
