// ignore_for_file: file_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/ViewsOfStories.dart';
import 'package:sizer/sizer.dart';
import 'package:story_view/story_view.dart';

class ViewStory extends StatefulWidget {
  final Users user;
  final List<Story> currentUsersStory;
  final StoryController? controller;
  final void Function()? rebuilt;
  final VoidCallback? oncomplete;

  const ViewStory(
      {super.key,
      required this.user,
      required this.currentUsersStory,
      this.rebuilt,
      this.controller,
      this.oncomplete});

  @override
  State<ViewStory> createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory>
    with AutomaticKeepAliveClientMixin {
  late StoryController controller;
  late Users user;
  late List<Story> currentUsersStory;
  List<StoryItem> storyItems = [];
  int currentIndex = 0;
  Rebuilt built = Rebuilt();

  @override
  void dispose() {
    Rebuilt().value = null;
    super.dispose();
    controller.dispose();
  }

  void moveController() {
    int unseen = unSeenStoryIndex();
    for (var i = 0; i < unseen; i++) {
      controller.next();
    }
  }

  int unSeenStoryIndex() {
    int i = 0;
    for (Story s in currentUsersStory) {
      if (!s.views.contains(user.userId)) {
        return i;
      }
      i++;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    currentUsersStory = widget.currentUsersStory;
    if (widget.controller == null) {
      controller = StoryController();
    } else {
      controller = widget.controller!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      moveController();
    });
    for (var story in currentUsersStory) {
      storyItems.add(StoryItem.pageImage(
        imageFit: BoxFit.contain,
        url: story.storyImageLoc,
        controller: controller,
        caption: story.content == null
            ? null
            : Text(
                story.content!,
                softWrap: true,
                style: const TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
        duration: const Duration(
          seconds: 6,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        int sensitivity = 10;
        if (details.delta.dy > sensitivity) {
          Navigator.pop(context);
        } else if (details.delta.dy < -sensitivity) {
          // Up Swipe
        }
      },
      child: Stack(
        children: [
          StoryView(
            indicatorHeight: IndicatorHeight.small,
            storyItems: storyItems,
            controller: controller,
            onComplete: () {
              if (currentUsersStory[0].userId ==
                  FirebaseAuth.instance.currentUser!.uid) {
                Navigator.of(context).pop();
              }
              if (widget.oncomplete != null) {
                widget.oncomplete!();
              }
            },
            onStoryShow: (storyItem, index) async {
              currentIndex = index;
              var story = currentUsersStory.elementAt(index);
              StoryCollection().addStory(story: story);
              built.set(story: story);

              if (!story.views.contains(user.userId)) {
                DataBase().addView(story, user).then((value) {
                  if (value) {
                    print('bottom rebuilt');
                    if (widget.rebuilt != null) {
                      print('bottom rebuilt in');
                      widget.rebuilt!();
                    }
                  }
                });
              }
            },
          ),
          Container(
              padding: const EdgeInsets.only(
                top: 48,
                left: 16,
                right: 16,
              ),
              child: ValueListenableBuilder(
                  valueListenable: built,
                  builder: (context, value, child) {
                    DateTime now = DateTime.now();
                    var durationHour =
                        now.difference(value!.uploadDate).inHours;
                    var durationMin =
                        now.difference(value.uploadDate).inMinutes;
                    return SizedBox(
                      height: 7.5.h,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey,
                              backgroundImage: value.profileLoc == null
                                  ? const AssetImage('assets/blankprofile.png')
                                      as ImageProvider
                                  : NetworkImage(value.profileLoc!)),
                          SizedBox(
                            width: 2.6.w,
                          ),
                          Text(
                            value.userName,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                                color: Colors.white),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 3.w),
                            child: durationHour > 0
                                ? Text(
                                    '${durationHour}h',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w100,
                                      fontSize: 15,
                                      decoration: TextDecoration.none,
                                      color: Color.fromARGB(255, 234, 231, 231),
                                    ),
                                  )
                                : Text(
                                    '${durationMin}m',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w100,
                                      fontSize: 15,
                                      decoration: TextDecoration.none,
                                      color: Color.fromARGB(255, 191, 190, 190),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    );
                  })),
          currentUsersStory[0].userId == user.userId
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child: IconButton(
                      onPressed: () {
                        controller.pause();
                        showModalBottomSheet(
                            isScrollControlled: true,
                            useRootNavigator: true,
                            backgroundColor:
                                const Color.fromARGB(255, 34, 38, 41),
                            context: context,
                            builder: (context) {
                              return CustomViewSheet(
                                  story: currentUsersStory
                                      .elementAt(currentIndex));
                            }).then((value) => controller.play());
                      },
                      icon: const Icon(Icons.visibility)))
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Rebuilt extends ValueNotifier<Story?> {
  Rebuilt() : super(null);

  void set({required Story story}) {
    value = story;
    notifyListeners();
  }
}
