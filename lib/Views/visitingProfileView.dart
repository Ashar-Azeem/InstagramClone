import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/VisitingProfileViewItems.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:sizer/sizer.dart';

class VisitingProfileView extends StatefulWidget {
  final Users ownerUser;
  final Users user;
  final Future<void> Function()? rebuilt;
  const VisitingProfileView(
      {super.key,
      required this.user,
      required this.ownerUser,
      required this.rebuilt});

  @override
  State<VisitingProfileView> createState() => _VisitingProfileViewState();
}

class _VisitingProfileViewState extends State<VisitingProfileView> {
  DataBase db = DataBase();
  late List<Posts> posts;
  String totalPosts = "0";
  late Users ownerUser;
  late Users user;

  @override
  void initState() {
    user = widget.user;
    ownerUser = widget.ownerUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double oneContainerWidth = (screenWidth - 4 / 3);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              user.userName,
              style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            user.userName == 'ashar' || user.userName == 'vaneeza'
                ? Padding(
                    padding: EdgeInsets.only(left: 2.w),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 15,
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: FutureBuilder(
            future: db.isRequested(ownerUser, user),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  {
                    if (snapshot.hasData) {
                      bool isRequested = snapshot.data!;
                      return VisitingProfileViewItems(
                          user: user,
                          ownerUser: ownerUser,
                          isRequested: isRequested,
                          rebuilt: widget.rebuilt,
                          oneContainerWidth: oneContainerWidth);
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeCap: StrokeCap.round,
                        ),
                      );
                    }
                  }
                default:
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeCap: StrokeCap.round,
                    ),
                  );
              }
            }),
      )),
    );
  }
}
