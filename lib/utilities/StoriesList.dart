import 'package:flutter/cupertino.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/StoryItem.dart';
import 'package:sizer/sizer.dart';

class StoriesRow extends StatefulWidget {
  final List<List<Story>> data;
  final List<Story> userStories;
  final Users ownerUser;
  const StoriesRow(
      {super.key,
      required this.data,
      required this.userStories,
      required this.ownerUser});

  @override
  State<StoriesRow> createState() => _StoriesRowState();
}

class _StoriesRowState extends State<StoriesRow> {
  late List<List<Story>> data;
  late List<Story> userStories;
  late Users ownerUser;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    userStories = widget.userStories;
    ownerUser = widget.ownerUser;
  }

  void rebuilt() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 13.5.h,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: data.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ValueListenableBuilder(
                    valueListenable: StoryCollection(),
                    builder: (context, value, child) {
                      return StoryItem(
                        stories: userStories,
                        user: ownerUser,
                        allStoriesList: null,
                      );
                    });
              }
              var followingStories = data[index - 1];

              return StoryItem(
                stories: followingStories,
                user: ownerUser,
                allStoriesList: data,
                rebuilt: rebuilt,
              );
            }));
  }
}
