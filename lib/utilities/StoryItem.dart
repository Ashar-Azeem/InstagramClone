import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:mysocialmediaapp/Views/AddStoryView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/PageViewStorySlider.dart';
import 'package:mysocialmediaapp/utilities/ViewStory.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sizer/sizer.dart';

class StoryItem extends StatefulWidget {
  final Users user;

  final List<Story> stories;
  final List<List<Story>>? allStoriesList;
  final void Function()? rebuilt;
  const StoryItem({
    super.key,
    required this.stories,
    required this.user,
    required this.allStoriesList,
    this.rebuilt,
  });

  @override
  State<StoryItem> createState() => _StoryItemState();
}

class _StoryItemState extends State<StoryItem> {
  late List<Story> stories;
  late Users user;
  late List<List<Story>>? allStoriesList;

  @override
  void initState() {
    super.initState();
    stories = widget.stories;
    user = widget.user;
    allStoriesList = widget.allStoriesList;
  }

  void rebuilt() {
    setState(() {});
  }

  bool checkSeen(List<Story> story) {
    for (Story s in story) {
      if (!s.views.contains(user.userId)) {
        return false;
      }
    }
    return true;
  }

  void changeProfile(List<Story> userStories, String? newUrl) {
    for (Story s in userStories) {
      s.profileLoc = newUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: stories.isEmpty ? 1.h : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Container(
                padding: const EdgeInsets.all(3.7),
                //width is user to assign space between each item
                width: 25.w,
                //size of one item
                height: stories.isEmpty ? 20.5.w : 22.w,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: stories.isEmpty
                        ? null
                        : GradientBoxBorder(
                            gradient: checkSeen(stories)
                                ? const LinearGradient(colors: [
                                    Color.fromARGB(255, 61, 61, 65),
                                    Color.fromARGB(255, 61, 61, 65)
                                  ])
                                : const LinearGradient(colors: [
                                    Colors.yellow,
                                    Colors.red,
                                    Color.fromARGB(255, 255, 76, 243),
                                    // Colors.red,
                                  ]),
                            width: 3.5,
                          )),
                child: ValueListenableBuilder(
                    valueListenable: ProfilePicture(),
                    builder: (context, value, child) {
                      return GestureDetector(
                        child: stories.isEmpty
                            ? Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage: value == null
                                          ? const AssetImage(
                                                  'assets/blankprofile.png')
                                              as ImageProvider
                                          : NetworkImage(value),
                                      radius: 20.5.w,
                                    ),
                                    Positioned(
                                      left: 12.w,
                                      top: 4.4.h,
                                      child: IconButton(
                                          onPressed: () {
                                            PersistentNavBarNavigator
                                                .pushNewScreen(
                                              context,
                                              screen: (AddStoryView(
                                                user: user,
                                                stories: stories,
                                              )),
                                              withNavBar: false,
                                              pageTransitionAnimation:
                                                  PageTransitionAnimation
                                                      .slideRight,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.add_circle,
                                            color: Colors.white,
                                          )),
                                    )
                                  ])
                            : CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: stories[0].profileLoc == null
                                    ? const AssetImage(
                                            'assets/blankprofile.png')
                                        as ImageProvider
                                    : (stories[0].userId == user.userId
                                        ? NetworkImage(value!)
                                        : NetworkImage(stories[0].profileLoc!)),
                              ),
                        onTap: () {
                          if (stories.isEmpty) {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: (AddStoryView(
                                user: user,
                                stories: stories,
                              )),
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.slideRight,
                            );
                          } else if (allStoriesList == null) {
                            //if the profile picture is changed we have to update the user's profile in the stories section of current user
                            if (stories[0].profileLoc != value) {
                              changeProfile(stories, value);
                            }
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: (ViewStory(
                                user: user,
                                currentUsersStory: stories,
                                rebuilt: rebuilt,
                              )),
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.fade,
                            );
                          } else {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: (StoryTransitions(
                                  rebuilt: widget.rebuilt,
                                  allStories: allStoriesList!,
                                  currentStoryUserId: stories[0].userId,
                                  user: user)),
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.fade,
                            );
                          }
                        },
                      );
                    })),
          ),
          stories.isEmpty
              ? const Text(
                  'Your Story',
                  style: TextStyle(fontSize: 12.3, color: Colors.white),
                )
              : (stories[0].userId == FirebaseAuth.instance.currentUser!.uid
                  ? const Text(
                      'Your Story',
                      style: TextStyle(fontSize: 12.3, color: Colors.white),
                    )
                  : Text(
                      stories[0].userName,
                      style:
                          const TextStyle(fontSize: 12.3, color: Colors.white),
                    ))
        ],
      ),
    );
  }
}
