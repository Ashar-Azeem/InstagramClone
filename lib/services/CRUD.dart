// ignore_for_file: file_names
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:mysocialmediaapp/utilities/utilities.dart';

class DataBase {
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  DocumentReference publicPosts = FirebaseFirestore.instance
      .collection('PublicPosts')
      .doc('UniversalCategory');

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

  Future<List<Posts>> getForYouPagePosts(List<String> publicPosts) async {
    List<Posts> suggestedPosts = [];
    for (String s in publicPosts) {
      Posts? post = await getPost(s);
      if (post != null &&
          post.userId != FirebaseAuth.instance.currentUser!.uid) {
        suggestedPosts.add(post);
      }
    }
    suggestedPosts.sort((a, b) => b.uploadDateTime.compareTo(a.uploadDateTime));

    return suggestedPosts;
  }

  Future<List<String>> getPublicPostsList() async {
    DocumentSnapshot doc = await publicPosts.get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<String> publicPostsList = List<String>.from(data['Posts']);

    return publicPostsList;
  }

  Future<void> updatePublicPostsList(List<String> newList) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(publicPosts, {'Posts': newList});
    });
  }

  Future<Posts?> getPost(String postId) async {
    try {
      DocumentSnapshot doc = await postCollection.doc(postId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String postId = doc.id;
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

        return post;
      }
    } catch (_) {
      //
      return null;
    }

    return null;
  }

  Future<bool> deletePost(String postId, String loc) async {
    try {
      await postCollection.doc(postId).delete();
      await FirebaseStorage.instance.refFromURL(loc).delete();

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
      await getPosts(user.userId, true);
      //Triggers the UI change where ever the old profile picture is used
      ProfilePicture().set(location: url);
    } catch (e) {
      //
    }
  }

  Future<void> changeAccountSecurity(Users user, List<Posts> posts) async {
    try {
      DocumentReference result = userCollection.doc(user.userId);

      if (user.isPrivate == false) {
        List<String> publicList = await getPublicPostsList();
        for (Posts post in posts) {
          publicList.remove(post.postId);
        }
        await updatePublicPostsList(publicList);
        await result.update({'privateAccount': true});
      } else if (user.isPrivate) {
        List<String> publicList = await getPublicPostsList();
        for (Posts post in posts) {
          if (!publicList.contains(post.postId)) {
            publicList.add(post.postId);
          }
        }
        await updatePublicPostsList(publicList);
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
            FCMtoken: token,
            public: null);
        if (user.userId != FirebaseAuth.instance.currentUser!.uid) {
          users.add(user);
        }
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
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference visitedUserRef = userCollection.doc(user.userId);
        DocumentReference ownerUserRef = userCollection.doc(ownerUser.userId);

        transaction.update(visitedUserRef, {'followers': visitedFollowers});

        transaction.update(ownerUserRef, {'following': ownerFollowing});

        Following().updateFollowing(ownerFollowing);
      });
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

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference visitedUserRef = userCollection.doc(user.userId);
        DocumentReference ownerUserRef = userCollection.doc(ownerUser.userId);

        transaction.update(visitedUserRef, {'followers': visitedFollowers});

        transaction.update(ownerUserRef, {'following': ownerFollowing});

        Following().updateFollowing(ownerFollowing);
      });
    } catch (e) {
      //
    }
  }

  Future<bool> removeFollower(Users visitingUser, Users ownerUser) async {
    try {
      List<String> visiterFollowing = visitingUser.following;
      List<String> ownerFollowers = ownerUser.followers;

      visiterFollowing.remove(ownerUser.userId);
      ownerFollowers.remove(visitingUser.userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference visitedUserRef =
            userCollection.doc(visitingUser.userId);
        DocumentReference ownerUserRef = userCollection.doc(ownerUser.userId);

        transaction.update(visitedUserRef, {'following': visiterFollowing});

        transaction.update(ownerUserRef, {'followers': ownerFollowers});

        Followers().updateFollowers(ownerFollowers);
      });

      return true;
    } catch (_) {
      //
    }
    return false;
  }

  Future<void> addPost(
      String userId,
      String userName,
      String? profileLoc,
      String postLoc,
      String? content,
      int totalLikes,
      int totalComments,
      Users user) async {
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

      if (!user.isPrivate) {
        List<String> publicPosts = await getPublicPostsList();
        publicPosts.add(doc.id);
        await updatePublicPostsList(publicPosts);
      }
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

  Future<List<Posts>?> getPosts(String userId, bool send) async {
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
        if (send) {
          PostsCollection().addPost(post: post);
        }
      }
      return posts;
    } catch (e) {
      //
    }
    return null;
  }

  Future<List<String>> getStories() async {
    await Future.delayed(const Duration(seconds: 2));
    var l = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];
    return l;
  }

  Future<Users?> getUser(String userId, bool getPublicPosts) async {
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

        Users user;

        if (getPublicPosts) {
          List<String> pulicPosts = await getPublicPostsList();
          user = Users(
              id: userId,
              n: name,
              un: userName,
              loc: profileLocation,
              f1: followers,
              f2: following,
              isPriv: isPrivate,
              FCMtoken: token,
              public: pulicPosts);
        } else {
          user = Users(
              id: userId,
              n: name,
              un: userName,
              loc: profileLocation,
              f1: followers,
              f2: following,
              isPriv: isPrivate,
              FCMtoken: token,
              public: null);
        }

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
  late List<String>? publicPosts;

  Users(
      {required String id,
      required String n,
      required String un,
      required String? loc,
      required List<String> f1,
      required List<String> f2,
      required bool isPriv,
      required String FCMtoken,
      required List<String>? public}) {
    userId = id;
    name = n;
    userName = un;
    imageLoc = loc;
    followers = f1;
    following = f2;
    isPrivate = isPriv;
    token = FCMtoken;
    publicPosts = public;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Users &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  // Override hashCode based on id
  @override
  int get hashCode => userId.hashCode;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Posts &&
          runtimeType == other.runtimeType &&
          postId == other.postId;

  // Override hashCode based on id
  @override
  int get hashCode => postId.hashCode;
}

class PostsCollection extends ValueNotifier<List<Posts>> {
  //singleton class so only instance exists
  PostsCollection._sharedInstance() : super([]);
  static final PostsCollection _shared = PostsCollection._sharedInstance();
  factory PostsCollection() => _shared;

  void addPost({required Posts post}) {
    for (Posts p in value) {
      //If same post is added again then the view becomes redundant
      if (p.postId == post.postId) {
        return;
      }
    }
    value.add(post);
    notifyListeners();
  }

  void clear() {
    value.clear();
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

class Following extends ValueNotifier<List<String>> {
  //singleton class so only one instance exists
  Following._sharedInstance() : super([]);
  static final Following _shared = Following._sharedInstance();
  factory Following() => _shared;

  void updateFollowing(List<String> following) {
    value.clear();
    value = following.map((str) => str).toList();
    notifyListeners();
  }

  void clear() {
    value.clear();
    notifyListeners();
  }
}

class Followers extends ValueNotifier<List<String>> {
  //singleton class so only one instance exists
  Followers._sharedInstance() : super([]);
  static final Followers _shared = Followers._sharedInstance();
  factory Followers() => _shared;

  void updateFollowers(List<String> followers) {
    value.clear();
    value = followers.map((str) => str).toList();
    notifyListeners();
  }

  void clear() {
    value.clear();
    notifyListeners();
  }
}
