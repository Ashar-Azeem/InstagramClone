// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/ViewsOfStories.dart';
import 'package:sizer/sizer.dart';
import 'package:story_view/story_view.dart';

class ViewStory extends StatefulWidget {
  final Users user;
  final List<Story> currentUsersStory;
  final void Function()? rebuilt;

  const ViewStory(
      {super.key,
      required this.user,
      required this.currentUsersStory,
      this.rebuilt});

  @override
  State<ViewStory> createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {
  StoryController controller = StoryController();
  late Users user;
  late List<Story> currentUsersStory;
  List<StoryItem> storyItems = [];
  int currentIndex = 0;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    Rebuilt().value = null;
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
          seconds: 10,
        ),
      ));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        moveController();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Navigator.of(context).pop();
            },
            onStoryShow: (storyItem, index) async {
              currentIndex = index;
              var story = currentUsersStory.elementAt(index);

              Rebuilt().set(story: story);
              if (!story.views.contains(user.userId)) {
                DataBase().addView(story, user).then((value) {
                  if (value) {
                    if (widget.rebuilt != null) {
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
                  valueListenable: Rebuilt(),
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
}

class Rebuilt extends ValueNotifier<Story?> {
  Rebuilt._sharedInstance() : super(null);
  static final Rebuilt _shared = Rebuilt._sharedInstance();
  factory Rebuilt() => _shared;

  void set({required Story story}) {
    value = story;
    notifyListeners();
  }
}
