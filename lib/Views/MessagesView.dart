import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/Views/SearchBar.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sizer/sizer.dart';

class MessagesView extends StatefulWidget {
  final Users user;
  const MessagesView({super.key, required this.user});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  late Users ownerUser;
  @override
  void initState() {
    super.initState();
    ownerUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        int sensitivity = 12;
        if (details.delta.dx > sensitivity) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          forceMaterialTransparency: true,
          title: Text(
            ownerUser.userName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 1.h, bottom: 5.w),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(92.w, 5.5.h),
                        backgroundColor: const Color.fromARGB(255, 21, 24, 30),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      onPressed: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen:
                              (SearchBarView(messaging: true, user: ownerUser)),
                          withNavBar: false,
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
              ),
              Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: const Text(
                  'Messages',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return SizedBox(
                        width: 92.w,
                        height: 9.2.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage:
                                  AssetImage('assets/blankprofile.png'),
                              radius: 7.5.w,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 3.w),
                              child: Text(
                                index.toString(),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            )
                          ],
                        ));
                  },
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
