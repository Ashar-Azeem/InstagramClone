import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mysocialmediaapp/Views/visitingProfileView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:mysocialmediaapp/utilities/state.dart';

class FollowersAndFollowingView extends StatefulWidget {
  final Users user;
  final String choice;

  const FollowersAndFollowingView(
      {super.key, required this.user, required this.choice});

  @override
  State<FollowersAndFollowingView> createState() =>
      _FollowersAndFollowingViewState();
}

class _FollowersAndFollowingViewState extends State<FollowersAndFollowingView> {
  late Users user;
  late String choice;
  late List<String> list;
  bool rebuilt = false;
  @override
  void initState() {
    super.initState();
    user = widget.user;
    choice = widget.choice;
    assignList(widget.choice);
  }

  void assignList(String choice) {
    if (choice == "followers") {
      list = user.followers;
    } else {
      list = user.following;
    }
  }

  void updateChoice(String newChoice, List<String> newList) {
    setState(() {
      choice = newChoice;
      list = newList;
      rebuilt = !rebuilt;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          user.userName,
          style: const TextStyle(
              fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    if (choice == 'following') {
                      updateChoice('followers', user.followers);
                    }
                  },
                  child: Text("${user.followers.length} Followers",
                      style: TextStyle(
                        fontSize: choice == 'followers' ? 17 : 15,
                        fontWeight: choice == 'followers'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: Colors.white,
                      )),
                ),
                TextButton(
                    onPressed: () {
                      if (choice == 'followers') {
                        updateChoice('following', user.following);
                      }
                    },
                    child: Text("${user.following.length} Following",
                        style: TextStyle(
                          fontSize: choice == 'following' ? 17 : 15,
                          color: Colors.white,
                          fontWeight: choice == 'following'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        )))
              ],
            ),
            const Divider(),
            Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: FirestorePagination(
                  //Rebuilts the widget if the value of the variable is changed
                  key: ValueKey(rebuilt),
                  onEmpty: Center(
                    child: Text('No $choice'),
                  ),
                  initialLoader: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  limit: 15,
                  shrinkWrap: true,
                  bottomLoader: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  query: FirebaseFirestore.instance
                      .collection('users')
                      .where(FieldPath.documentId, whereIn: list)
                      .orderBy(FieldPath.documentId),
                  itemBuilder: (context, snapshot, index) {
                    Users fUser = getObject(snapshot);
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VisitingProfileView(
                                    user: fUser,
                                    ownerUser: user,
                                  )),
                        );
                      },
                      child: SizedBox(
                        height: 85,
                        width: MediaQuery.of(context).size.width - 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            fUser.imageLoc == null
                                ? const CircleAvatar(
                                    radius: 33,
                                    backgroundColor:
                                        Color.fromARGB(255, 38, 38, 38),
                                    backgroundImage:
                                        AssetImage('assets/blankprofile.png'),
                                  )
                                : CircleAvatar(
                                    radius: 33,
                                    backgroundColor:
                                        const Color.fromARGB(255, 38, 38, 38),
                                    backgroundImage:
                                        NetworkImage(fUser.imageLoc!),
                                  ),
                            const SizedBox(
                              width: 17,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 2.9,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      fUser.userName,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                    Text(
                                      fUser.name,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width / 50),
                              child: InkWell(
                                onTap: () async {
                                  var db = DataBase();
                                  if (choice == 'followers' &&
                                      !user.following.contains(fUser.userId)) {
                                    await addRelationship(fUser, user, db);
                                    rebuilt = !rebuilt;
                                  } else {
                                    //Forwards to messaging...
                                  }
                                },
                                child: Container(
                                  height: 33,
                                  width: MediaQuery.of(context).size.width / 4,
                                  decoration: BoxDecoration(
                                    color: mobileBackgroundColor,
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Center(
                                      child: (choice == 'following' ||
                                              user.following
                                                  .contains(fUser.userId)
                                          ? const Text(
                                              "Message",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : const Text(
                                              "Follow",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ))),
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              color: Colors.white,
                              onSelected: (String result) async {
                                if (result == 'remove') {
                                  var db = DataBase();
                                  if (choice == 'followers') {
                                    await removeFollower(fUser, user, db);
                                    setState(() {
                                      list = user.followers;
                                      rebuilt = !rebuilt;
                                    });
                                  } else {
                                    await removeRelationship(fUser, user, db);
                                    setState(() {
                                      list = user.following;
                                      rebuilt = !rebuilt;
                                    });
                                  }
                                }
                              },
                              itemBuilder: (context) {
                                return <PopupMenuEntry<String>>[
                                  const PopupMenuItem(
                                    value: "remove",
                                    child: ListTile(
                                        leading: Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                        ),
                                        title: Text(
                                          'Remove',
                                          style: TextStyle(color: Colors.black),
                                        )),
                                  ),
                                ];
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ))
          ],
        ),
      )),
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
      public: null);

  return user;
}
