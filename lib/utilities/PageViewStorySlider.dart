import 'package:flutter/cupertino.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/ViewStory.dart';
import 'package:story_view/controller/story_controller.dart';

class StoryTransitions extends StatefulWidget {
  final List<List<Story>> allStories;
  final String currentStoryUserId;
  final Users user;
  final void Function()? rebuilt;
  const StoryTransitions({
    super.key,
    required this.allStories,
    required this.currentStoryUserId,
    required this.user,
    this.rebuilt,
  });

  @override
  State<StoryTransitions> createState() => _StoryTransitionsState();
}

class _StoryTransitionsState extends State<StoryTransitions> {
  late List<StoryController> controllers = [];
  late List<List<Story>> allStories;
  late String currentStoryUserId;
  late Users user;
  late List<Widget> views = [];
  late PageController controller;
  int currentIndex = 0;

  void initializeListAndController() {
    int count = 0;
    for (List<Story> ls in allStories) {
      views.add(ViewStory(
          user: user,
          currentUsersStory: ls,
          rebuilt: widget.rebuilt,
          controller: controllers[count],
          oncomplete: () {
            return onComplete();
          }));
      if (currentStoryUserId == ls[0].userId) {
        controller = PageController(initialPage: count);
        currentIndex = count;
      }

      count++;
    }
  }

  void onComplete() {
    int index = currentIndex + 1;
    if (index < allStories.length) {
      controller.animateToPage(index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutQuint);
    } else if (index == allStories.length) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    allStories = widget.allStories;
    currentStoryUserId = widget.currentStoryUserId;
    user = widget.user;
    for (var i = 0; i < allStories.length; i++) {
      controllers.add(StoryController());
    }
    initializeListAndController();
  }

  @override
  void dispose() {
    controller.dispose();
    for (var i = 0; i < controllers.length; i++) {
      controllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      onPageChanged: (value) {
        currentIndex = value;
        for (var i = 0; i < controllers.length; i++) {
          if (i == value) {
            controllers[i].play();
          } else {
            controllers[i].pause();
          }
        }
      },
      children: views,
    );
  }
}
