// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';

import 'package:flutter/material.dart';

import 'package:mysocialmediaapp/Views/ViewPost.dart';
import 'package:mysocialmediaapp/Views/visitingProfileView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/state.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:sizer/sizer.dart';

class NotificationView extends StatefulWidget {
  final Users user;
  const NotificationView({super.key, required this.user});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  late Users user;
  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.only(left: 4.w, right: 2.w),
              child: FirestorePagination(
                isLive: true,
                initialLoader: const Center(
                    child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeAlign: 2,
                )),
                bottomLoader: const Center(
                    child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeAlign: 2,
                )),
                onEmpty: const Center(
                  child: Text('No notifications!'),
                ),
                query: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('receiverId', isEqualTo: user.userId)
                    .orderBy('time', descending: true),
                itemBuilder: (context, snapshot, index) {
                  Notifications notification = getNotificationObject(snapshot);
                  if (notification.isLikeNotification) {
                    return InkWell(
                      onTap: () async {
                        var post =
                            await DataBase().getPost(notification.postId!);
                        List<Posts> posts = [post!];
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: (ViewPost(
                                posts: posts,
                                index1: 0,
                                personal: true,
                                user: user)),
                            withNavBar: true,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino);
                      },
                      child: SizedBox(
                        width: 90.w,
                        height: 10.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: notification.senderProfileLoc ==
                                      null
                                  ? const AssetImage('assets/blankprofile.png')
                                      as ImageProvider
                                  : NetworkImage(
                                      notification.senderProfileLoc!),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 4.w, right: 1.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 60.w,
                                    child: Text(
                                      "${notification.senderUserName} liked your post",
                                      softWrap: true,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 1.w),
                                    child: Text(
                                      notification.time
                                          .toString()
                                          .substring(0, 16),
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 209, 208, 208),
                                          fontSize: 13),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 38, 38, 38),
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                    image: NetworkImage(notification.postLoc!),
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  } else if (notification.isCommentNotification) {
                    return InkWell(
                      onTap: () async {
                        var post =
                            await DataBase().getPost(notification.postId!);
                        List<Posts> posts = [post!];
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: (ViewPost(
                                posts: posts,
                                index1: 0,
                                personal: true,
                                user: user)),
                            withNavBar: true,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino);
                      },
                      child: SizedBox(
                        width: 90.w,
                        height: 12.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: notification.senderProfileLoc ==
                                      null
                                  ? const AssetImage('assets/blankprofile.png')
                                      as ImageProvider
                                  : NetworkImage(
                                      notification.senderProfileLoc!),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 4.w, right: 2.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 60.w,
                                    child: Text(
                                      "${notification.senderUserName} commented on your post:",
                                      softWrap: true,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60.w,
                                    child: Text(
                                      notification.comment!,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 1.w),
                                    child: Text(
                                      notification.time
                                          .toString()
                                          .substring(0, 16),
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 209, 208, 208),
                                          fontSize: 13),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 38, 38, 38),
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                    image: NetworkImage(notification.postLoc!),
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  } else if (notification.isFollowerNotification) {
                    return InkWell(
                      onTap: () async {
                        var newuser = await DataBase()
                            .getUser(notification.senderId, false);
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: (VisitingProfileView(
                                user: newuser!,
                                ownerUser: user,
                                rebuilt: null)),
                            withNavBar: true,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino);
                      },
                      child: SizedBox(
                        width: 90.w,
                        height: 10.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: notification.senderProfileLoc ==
                                      null
                                  ? const AssetImage('assets/blankprofile.png')
                                      as ImageProvider
                                  : NetworkImage(
                                      notification.senderProfileLoc!),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 4.w, right: 1.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 60.w,
                                    child: Text(
                                      "${notification.senderUserName} started following you",
                                      softWrap: true,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 1.w),
                                    child: Text(
                                      notification.time
                                          .toString()
                                          .substring(0, 16),
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 209, 208, 208),
                                          fontSize: 13),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return InkWell(
                      onTap: () async {
                        var newuser = await DataBase()
                            .getUser(notification.senderId, false);
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: (VisitingProfileView(
                                user: newuser!,
                                ownerUser: user,
                                rebuilt: null)),
                            withNavBar: true,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino);
                      },
                      child: SizedBox(
                        width: 90.w,
                        height: 10.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: notification.senderProfileLoc ==
                                      null
                                  ? const AssetImage('assets/blankprofile.png')
                                      as ImageProvider
                                  : NetworkImage(
                                      notification.senderProfileLoc!),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 4.w, right: 1.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 32.w,
                                    child: Text(
                                      notification.senderUserName,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 1.w),
                                    child: Text(
                                      notification.time
                                          .toString()
                                          .substring(0, 16),
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 209, 208, 208),
                                          fontSize: 13),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                var newuser = await DataBase()
                                    .getUser(notification.senderId, false);

                                await confirmingARequest(user, newuser!);
                              },
                              child: Container(
                                height: 10.w,
                                width: 20.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Confirm',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 2.w),
                              child: InkWell(
                                onTap: () async {
                                  var newuser = await DataBase()
                                      .getUser(notification.senderId, false);

                                  DataBase().deleteNotification(
                                      null, newuser!, user, false, false, true);
                                },
                                child: Container(
                                  height: 10.w,
                                  width: 20.w,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 78, 77, 96),
                                    border:
                                        Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              ))),
    );
  }
}

Notifications getNotificationObject(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

  var senderId = data['senderId'];
  var receiverId = data['receiverId'];
  var senderUserName = data['senderUserName'];
  var senderProfileLoc = data['senderProfileLoc'];
  var postLoc = data['postLoc'];
  var time = data['time'] as Timestamp;
  var comment = data['comment'];
  var isCommentNotification = data['isCommentNotification'];
  var isFollowerNotification = data['isFollowerNotification'];
  var isLikeNotification = data['isLikeNotification'];
  var isRequestNotification = data['isRequestNotification'];
  var postId = data['postId'];

  Notifications notification = Notifications(
      receiverId: receiverId,
      isLikeNotification: isLikeNotification,
      isCommentNotification: isCommentNotification,
      isFollowerNotification: isFollowerNotification,
      isRequestNotification: isRequestNotification,
      senderId: senderId,
      senderProfileLoc: senderProfileLoc,
      senderUserName: senderUserName,
      time: time.toDate(),
      postId: postId,
      postLoc: postLoc,
      comment: comment);

  return notification;
}
