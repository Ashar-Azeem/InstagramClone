import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';

import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:sizer/sizer.dart';

class CustomViewSheet extends StatefulWidget {
  final Story story;

  const CustomViewSheet({super.key, required this.story});

  @override
  State<CustomViewSheet> createState() => _CustomViewSheetState();
}

class _CustomViewSheetState extends State<CustomViewSheet> {
  late Story story;

  @override
  void initState() {
    super.initState();

    story = widget.story;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: Column(
        children: [
          const Center(
            child: Icon(
              Icons.horizontal_rule_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Center(
              child: Text(
                "Viewers",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                story.views.isNotEmpty
                    ? FirestorePagination(
                        shrinkWrap: true,
                        onEmpty: const Center(child: Text('No Views')),
                        initialLoader: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        bottomLoader: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        isLive: true,
                        limit: 10,
                        query: FirebaseFirestore.instance
                            .collection('users')
                            .where(FieldPath.documentId, whereIn: story.views),
                        itemBuilder: (context, snapshot, index) {
                          var user = getObject(snapshot);
                          var heightOfBox = 7.h;
                          return Padding(
                            padding: EdgeInsets.only(
                                left: 14, right: 14, bottom: 3.h),
                            child: SizedBox(
                              height: heightOfBox,
                              width: 90.w,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  user.imageLoc == null
                                      ? CircleAvatar(
                                          backgroundColor: Colors.black,
                                          backgroundImage: const AssetImage(
                                              'assets/blankprofile.png'),
                                          radius: 7.w,
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.black,
                                          backgroundImage:
                                              NetworkImage(user.imageLoc!),
                                          radius: 7.w,
                                        ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 4.w),
                                    child: Text(
                                      user.userName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(child: Text('No Views'))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Users getObject(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  String name = data['name'] as String;
  String userName = data['userName'] as String;
  String? profileLocation = data['profileLocation'] as String?;
  List<String> followers = List<String>.from(data['followers']);
  List<String> following = List<String>.from(data['following']);
  bool isPrivate = data['privateAccount'] as bool;
  String token = data['token'];
  Users user = Users(
    id: snapshot.id,
    n: name,
    un: userName,
    loc: profileLocation,
    f1: followers,
    f2: following,
    isPriv: isPrivate,
    FCMtoken: token,
  );

  return user;
}
