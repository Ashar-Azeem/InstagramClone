import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:sizer/sizer.dart';

class CustomBottomSheet extends StatefulWidget {
  final double screenWidth;
  final Users ownerUser;
  final Posts post;
  final double screenHeight;

  const CustomBottomSheet(
      {super.key,
      required this.screenWidth,
      required this.ownerUser,
      required this.post,
      required this.screenHeight});

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  bool loading = false;
  late double screenWidth;
  late double screenHeight;
  late Users ownerUser;
  late Posts post;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    screenHeight = widget.screenHeight;
    screenWidth = widget.screenWidth;
    ownerUser = widget.ownerUser;
    post = widget.post;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (screenHeight / 100) * 95.5,
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
                "Comments",
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
                FirestorePagination(
                  shrinkWrap: true,
                  onEmpty: const Center(child: Text('No Comments')),
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
                  limit: 20,
                  query: FirebaseFirestore.instance
                      .collection('comments')
                      .where('postId', isEqualTo: post.postId)
                      .orderBy('uploadDate', descending: true),
                  itemBuilder: (context, snapshot, index) {
                    var comment = getObject(snapshot);
                    var heightOfBox = comment.content.length ~/ 10;
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 14,
                          right: 14,
                          bottom: comment.content.length > 35 ? 8 : 0),
                      child: SizedBox(
                        height:
                            comment.content.length > 105 ? heightOfBox.h : 10.h,
                        width: 90.w,
                        child: Row(
                          children: [
                            comment.profileLoc == null
                                ? const Align(
                                    alignment: Alignment.topLeft,
                                    child: CircleAvatar(
                                        backgroundColor: Colors.black,
                                        backgroundImage: AssetImage(
                                            'assets/blankprofile.png')),
                                  )
                                : Align(
                                    alignment: Alignment.topLeft,
                                    child: CircleAvatar(
                                        backgroundColor: Colors.black,
                                        backgroundImage:
                                            NetworkImage(comment.profileLoc!)),
                                  ),
                            Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment.userName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          comment.uploadDateTime
                                              .toString()
                                              .substring(0, 11),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 70.w,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        comment.content,
                                        softWrap: true,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Column(
                children: [
                  const Divider(),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 10,
                        right: 8,
                        bottom: 10 + MediaQuery.of(context).viewInsets.bottom),
                    child: SizedBox(
                      width: screenWidth - 10,
                      height: 6.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ownerUser.imageLoc == null
                              ? const CircleAvatar(
                                  backgroundColor: Colors.black,
                                  backgroundImage:
                                      AssetImage('assets/blankprofile.png'),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.black,
                                  backgroundImage:
                                      NetworkImage(ownerUser.imageLoc!),
                                ),
                          Padding(
                            padding: const EdgeInsets.only(left: 13, right: 0),
                            child: SizedBox(
                              width: (screenWidth / 100) * 68,
                              child: TextField(
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal),
                                controller: controller,
                                autocorrect: false,
                                enableSuggestions: true,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText:
                                        'Add a comment for ${post.userName}'),
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                var text = controller.text;
                                controller.text = '';

                                if (text.isNotEmpty) {
                                  setState(() {
                                    loading = true;
                                  });
                                  Comments comment = Comments(
                                      post.postId,
                                      ownerUser.userId,
                                      ownerUser.userName,
                                      ownerUser.imageLoc,
                                      DateTime.now(),
                                      text);
                                  DataBase()
                                      .insertComments(comment)
                                      .then((value) {
                                    setState(() {
                                      loading = false;
                                      post.totalComments += 1;
                                    });
                                  });
                                }
                              },
                              icon: loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : const Icon(
                                      Icons.send_sharp,
                                      size: 25,
                                      color: Colors.white,
                                    ))
                        ],
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}

Comments getObject(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  String postId = data['postId'] as String;
  String userId = data['userId'] as String;
  String userName = data['userName'] as String;
  String? profileLoc = data['profileLoc'] as String?;
  String content = data['content'] as String;
  Timestamp firebaseDate = data['uploadDate'] as Timestamp;

  DateTime dartDate = firebaseDate.toDate();

  Comments comment =
      Comments(postId, userId, userName, profileLoc, dartDate, content);

  return comment;
}
