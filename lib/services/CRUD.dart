import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:mysocialmediaapp/services/firebase.dart';
import 'package:mysocialmediaapp/utilities/utilities.dart';

class DataBase {
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  CollectionReference postCollection =
      FirebaseFirestore.instance.collection('posts');

  final StreamController<List<Users>> userStreamController =
      StreamController<List<Users>>.broadcast();

  Stream<List<Users>> get usersStream => userStreamController.stream;

  Future<void> sendRetreivedUsers(String userName) async {
    if (userName.isEmpty) {
      userStreamController.add([]);
    } else {
      final users = await retreiveUsers(userName) as List<Users>;
      userStreamController.add(users);
    }
  }

  Future<bool> deletePost(String postId, String loc) async {
    try {
      await postCollection.doc(postId).delete();
      await FirebaseStorage.instance.refFromURL(loc).delete();
      print('sjdjshdjsdhshdshdjshdjsdjshdjshjs');

      return true;
    } catch (e) {
      //
    }
    return false;
  }

  Future<void> updateProfileInDatabase(Users user, url) async {
    try {
      DocumentReference ref = userCollection.doc(user.userId);
      await ref.update({'profileLocation': url});

      QuerySnapshot querySnapshot =
          await postCollection.where('userId', isEqualTo: user.userId).get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        DocumentReference documentRef = postCollection.doc(documentSnapshot.id);
        await documentRef.update({'profileLoc': url});
      }

      //state management
      //Below code is to ensure that UI is changes upon updation profile picture

      //Empties the post collection list as each post would have the address of old profile picture
      PostsCollection().value = [];
      //readding the posts in PostCollection so that the UI contains updated data
      await getPosts(user.userId);
      //Triggers the UI change where ever the old profile picture is used
      ProfilePicture().set(location: url);
    } catch (e) {
      //
    }
  }

  Future<void> changeAccountSecurity(Users user) async {
    try {
      DocumentReference result = userCollection.doc(user.userId);

      if (user.isPrivate == false) {
        await result.update({'privateAccount': true});
      } else if (user.isPrivate) {
        await result.update({'privateAccount': false});
      }
    } catch (e) {
      //
    }
  }

  Future<void> updateProfilePicture(Users user, Uint8List newImage) async {
    try {
      if (user.imageLoc == null) {
        String downloadUrl =
            await uploadImageGetUrl(newImage, "profile", false);

        await updateProfileInDatabase(user, downloadUrl);
      } else {
        await FirebaseStorage.instance.refFromURL(user.imageLoc!).delete();
        String downloadUrl =
            await uploadImageGetUrl(newImage, 'profile', false);
        await updateProfileInDatabase(user, downloadUrl);
      }
    } catch (e) {
//
    }
  }

  Future<List<Users>?> retreiveUsers(String userName) async {
    try {
      List<Users> users = [];
      QuerySnapshot data = await userCollection
          .where('userName', isGreaterThanOrEqualTo: userName)
          .where('userName', isLessThan: userName + 'z')
          .get();

      for (QueryDocumentSnapshot documentSnapshot in data.docs) {
        Map<String, dynamic> data1 =
            documentSnapshot.data() as Map<String, dynamic>;
        String name = data1['name'] as String;
        String userName = data1['userName'] as String;
        String? profileLocation = data1['profileLocation'] as String?;
        List<String> followers = List<String>.from(data1['followers']);
        List<String> following = List<String>.from(data1['following']);
        bool isPrivate = data1['privateAccount'] as bool;
        String token = data1['token'];

        Users user = Users(
            id: documentSnapshot.id,
            n: name,
            un: userName,
            loc: profileLocation,
            f1: followers,
            f2: following,
            isPriv: isPrivate,
            FCMtoken: token);

        users.add(user);
      }
      return users;
    } catch (e) {
      //
    }
    return null;
  }

  Future<void> insertUser(
      String userId,
      String name,
      String userName,
      String? profileLocation,
      List<String> followers,
      List<String> following,
      String token) async {
    try {
      await userCollection.doc(userId).set({
        'name': name,
        'userName': userName,
        'profileLocation': profileLocation,
        'followers': followers,
        'following': following,
        'privateAccount': false,
        'token': token,
      });
    } catch (e) {
      //
    }
  }

  Future<void> addFollowerAndFollowing(Users user, Users ownerUser) async {
    try {
      List<String> visitedFollowers = user.followers;
      List<String> ownerFollowing = ownerUser.following;

      visitedFollowers.add(ownerUser.userId);
      ownerFollowing.add(user.userId);

      DocumentReference visitedUserRef = userCollection.doc(user.userId);
      DocumentReference ownerUserRef = userCollection.doc(ownerUser.userId);

      await visitedUserRef.update({'followers': visitedFollowers});

      await ownerUserRef.update({'following': ownerFollowing});
    } catch (e) {
      //
    }
  }

  Future<void> removeFollowerAndFollowing(Users user, Users ownerUser) async {
    try {
      List<String> visitedFollowers = user.followers;
      List<String> ownerFollowing = ownerUser.following;

      visitedFollowers.remove(ownerUser.userId);
      ownerFollowing.remove(user.userId);

      DocumentReference visitedUserRef = userCollection.doc(user.userId);
      DocumentReference ownerUserRef = userCollection.doc(ownerUser.userId);

      await visitedUserRef.update({'followers': visitedFollowers});

      await ownerUserRef.update({'following': ownerFollowing});
    } catch (e) {
      //
    }
  }

  Future<void> addPost(
      String userId,
      String userName,
      String? profileLoc,
      String postLoc,
      String? content,
      int totalLikes,
      int totalComments) async {
    try {
      DateTime currentDate = DateTime.now();
      Timestamp fireStoreDate = Timestamp.fromDate(currentDate);
      final doc = await postCollection.add({
        'userId': userId,
        'userName': userName,
        'profileLoc': profileLoc,
        'postLoc': postLoc,
        'content': content,
        'totalLikes': totalLikes,
        'totalComments': totalComments,
        'uploadDateTime': fireStoreDate
      });
      final post = Posts(doc.id, totalLikes, totalComments, userId, userName,
          profileLoc, postLoc, content, currentDate);
      PostsCollection().addPost(post: post);
    } catch (e) {
      //
    }
  }

  Future<int> totalPost(String userId) async {
    try {
      QuerySnapshot result =
          await postCollection.where('userId', isEqualTo: userId).get();

      int size = result.size;
      return size;
    } catch (e) {
      //
    }
    return 0;
  }

  Future<int> totalPostForVisitingProfile(String userId) async {
    try {
      QuerySnapshot result =
          await postCollection.where('userId', isEqualTo: userId).get();

      int size = result.size;
      return size;
    } catch (e) {
      //
    }
    return 0;
  }

  Future<List<Posts>?> getPosts(String userId) async {
    try {
      List<Posts> posts = [];
      QuerySnapshot result =
          await postCollection.where('userId', isEqualTo: userId).get();

      for (QueryDocumentSnapshot document in result.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        String postId = document.id;
        String userId = data['userId'] as String;
        String userName = data['userName'] as String;
        String? profileLoc = data['profileLoc'] as String?;
        String postLoc = data['postLoc'] as String;
        String? content = data['content'] as String?;
        int totalLikes = data['totalLikes'] as int;
        int totalComments = data['totalComments'] as int;
        Timestamp firebaseDate = data['uploadDateTime'] as Timestamp;

        DateTime dartDate = firebaseDate.toDate();

        Posts post = Posts(postId, totalLikes, totalComments, userId, userName,
            profileLoc, postLoc, content, dartDate);
        posts.add(post);
        if (AuthService().getUser()!.uid == userId) {
          PostsCollection().addPost(post: post);
        }
      }
      return posts;
    } catch (e) {
      //
    }
    return null;
  }

  Future<Users?> getUser(String userId) async {
    try {
      DocumentSnapshot result = await userCollection.doc(userId).get();
      if (result.exists) {
        Map<String, dynamic> data = result.data() as Map<String, dynamic>;
        String name = data['name'] as String;
        String userName = data['userName'] as String;
        String? profileLocation = data['profileLocation'] as String?;
        List<String> followers = List<String>.from(data['followers']);
        List<String> following = List<String>.from(data['following']);
        bool isPrivate = data['privateAccount'] as bool;
        String token = data['token'];

        Users user = Users(
          id: userId,
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
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Future<String?> getUserProfileLocation(String userId) async {
  //   try {
  //     DocumentSnapshot result = await userCollection.doc(userId).get();
  //     if (result.exists) {
  //       Map<String, dynamic> data = result.data() as Map<String, dynamic>;
  //       String? profileLocation = data['profileLocation'] as String?;

  //       return profileLocation;
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  //   return null;
  // }

  Future<bool> userNameExists(String userName) async {
    QuerySnapshot querySnapshot = await userCollection
        .where("userName", isEqualTo: userName)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //Update the FCM token
  Future<void> updateToken(String userId, String FCMtoken) async {
    try {
      DocumentReference result = userCollection.doc(userId);

      await result.update({'token': FCMtoken});
    } catch (e) {
      //
    }
  }

  void check() async {
    // Users user = Users(
    //     id: "cde", n: "ashar ", un: "batman786", loc: null, f1: [], f2: []);
    // DataBase db = DataBase();
    // var check = await getUser(FirebaseAuth.instance.currentUser!.uid);
    // print(check!.followers);
  }
}

class Users {
  late String userId;
  late String name;
  late String userName;
  late String? imageLoc;
  late List<String> followers;
  late List<String> following;
  late bool isPrivate;
  late String token;

  Users(
      {required String id,
      required String n,
      required String un,
      required String? loc,
      required List<String> f1,
      required List<String> f2,
      required bool isPriv,
      required String FCMtoken}) {
    userId = id;
    name = n;
    userName = un;
    imageLoc = loc;
    followers = f1;
    following = f2;
    isPrivate = isPriv;
    token = FCMtoken;
  }
}

class Posts {
  late String postId;
  late int totalLikes;
  late int totalComments;
  late String userId;
  late String userName;
  late String? profLoc;
  late String postLoc;
  late String? content;
  late DateTime uploadDateTime;

  Posts(
      this.postId,
      this.totalLikes,
      this.totalComments,
      this.userId,
      this.userName,
      this.profLoc,
      this.postLoc,
      this.content,
      this.uploadDateTime);
}

class PostsCollection extends ValueNotifier<List<Posts>> {
  //singleton class so only instance exists
  PostsCollection._sharedInstance() : super([]);
  static final PostsCollection _shared = PostsCollection._sharedInstance();
  factory PostsCollection() => _shared;

  void addPost({required Posts post}) {
    for (Posts p in value) {
      //If same post is added again then the view become redundant
      if (p.postId == post.postId) {
        return;
      }
    }
    value.add(post);
    notifyListeners();
  }

  void removePost({required Posts post}) {
    value.remove(post);
    notifyListeners();
  }
}

class ProfilePicture extends ValueNotifier<String?> {
  ProfilePicture._sharedInstance() : super(null);
  static final ProfilePicture _shared = ProfilePicture._sharedInstance();
  factory ProfilePicture() => _shared;

  void set({required String? location}) {
    value = location;
  }
}
