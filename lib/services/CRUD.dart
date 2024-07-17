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

  CollectionReference notificationCollection =
      FirebaseFirestore.instance.collection('notifications');

  CollectionReference messageCollection =
      FirebaseFirestore.instance.collection('messeges');

  CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chats');

  CollectionReference storyCollection =
      FirebaseFirestore.instance.collection('stories');

  CollectionReference commentsCollection =
      FirebaseFirestore.instance.collection('comments');

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
        List<String> likesList = List<String>.from(data['likesList']);

        DateTime dartDate = firebaseDate.toDate();

        Posts post = Posts(postId, totalLikes, totalComments, userId, userName,
            profileLoc, postLoc, content, dartDate, likesList);

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

      QuerySnapshot notifications =
          await notificationCollection.where('postId', isEqualTo: postId).get();

      for (QueryDocumentSnapshot documentSnapshot in notifications.docs) {
        await notificationCollection.doc(documentSnapshot.id).delete();
      }

      QuerySnapshot comments =
          await commentsCollection.where('postId', isEqualTo: postId).get();

      for (QueryDocumentSnapshot documentSnapshot in comments.docs) {
        await commentsCollection.doc(documentSnapshot.id).delete();
      }

      return true;
    } catch (e) {
      //
    }
    return false;
  }

  Future<void> updateProfileInDatabase(Users user, url) async {
    try {
      //update location in user
      DocumentReference ref = userCollection.doc(user.userId);
      await ref.update({'profileLocation': url});
      //update Location in stories
      Timestamp now = Timestamp.fromDate(DateTime.now());
      QuerySnapshot storySnapShot = await storyCollection
          .where('userId', isEqualTo: user.userId)
          .where('finishDateTime', isGreaterThan: now)
          .get();

      for (QueryDocumentSnapshot documentSnapshot in storySnapShot.docs) {
        DocumentReference documentRef =
            storyCollection.doc(documentSnapshot.id);
        await documentRef.update({'profileLoc': url});
      }
      //update location in posts
      QuerySnapshot querySnapshot =
          await postCollection.where('userId', isEqualTo: user.userId).get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        DocumentReference documentRef = postCollection.doc(documentSnapshot.id);
        await documentRef.update({'profileLoc': url});
      }
      //update location in chats
      QuerySnapshot docs = await chatCollection
          .where(Filter.or(Filter('user1UserId', isEqualTo: user.userId),
              Filter('user2UserId', isEqualTo: user.userId)))
          .get();

      for (QueryDocumentSnapshot documentSnapshot in docs.docs) {
        DocumentReference documentRef = chatCollection.doc(documentSnapshot.id);
        var chat = getChatObject(documentSnapshot);
        if (chat.user1UserId == user.userId) {
          await documentRef.update({'user1ProfileLoc': url});
        } else {
          await documentRef.update({'user2ProfileLoc': url});
        }
      }

      //update location in comments:
      QuerySnapshot comments = await commentsCollection
          .where('userId', isEqualTo: user.userId)
          .get();

      for (QueryDocumentSnapshot documentSnapshot in comments.docs) {
        DocumentReference documentRef =
            commentsCollection.doc(documentSnapshot.id);
        await documentRef.update({'profileLoc': url});
      }

      //update location in notifications
      QuerySnapshot notifications = await notificationCollection
          .where('senderId', isEqualTo: user.userId)
          .get();

      for (QueryDocumentSnapshot documentSnapshot in notifications.docs) {
        DocumentReference documentRef =
            notificationCollection.doc(documentSnapshot.id);
        await documentRef.update({'senderProfileLoc': url});
      }

      //update location in chats:

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

        transaction.update(visitedUserRef, {
          'followers': FieldValue.arrayUnion([ownerUser.userId])
        });

        transaction.update(ownerUserRef, {
          'following': FieldValue.arrayUnion([user.userId])
        });

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

        transaction.update(visitedUserRef, {
          'followers': FieldValue.arrayRemove([ownerUser.userId])
        });

        transaction.update(ownerUserRef, {
          'following': FieldValue.arrayRemove([user.userId])
        });

        Following().updateFollowing(ownerFollowing);
      });
    } catch (e) {
      //
    }
  }

  Future<bool> addLike(Posts post, Users user) async {
    DocumentReference postRef = postCollection.doc(post.postId);
    Posts currentPost = await getPost(post.postId) as Posts;
    if (currentPost.likesList.contains(user.userId)) {
      return false;
    }
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(postRef, {
        'likesList': FieldValue.arrayUnion([user.userId])
      });
      transaction.update(postRef, {'totalLikes': FieldValue.increment(1)});

      return true;
    });
    return false;
  }

  Future<bool> removeLike(Posts post, Users user) async {
    DocumentReference postRef = postCollection.doc(post.postId);
    Posts currentPost = await getPost(post.postId) as Posts;
    if (!currentPost.likesList.contains(user.userId) ||
        (currentPost.totalLikes <= 0)) {
      return false;
    }
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(postRef, {
        'likesList': FieldValue.arrayRemove([user.userId])
      });
      transaction.update(postRef, {'totalLikes': FieldValue.increment(-1)});

      return true;
    });
    return false;
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

        transaction.update(visitedUserRef, {
          'following': FieldValue.arrayRemove([ownerUser.userId])
        });

        transaction.update(ownerUserRef, {
          'followers': FieldValue.arrayRemove([visitingUser.userId])
        });

        Followers().updateFollowers(ownerFollowers);
      });

      return true;
    } catch (_) {
      //
    }
    return false;
  }

  Future<bool> gainFollower(Users followerGainer, Users fanUser) async {
    try {
      List<String> gain = followerGainer.followers;
      List<String> fan = fanUser.following;

      gain.add(fanUser.userId);
      fan.add(followerGainer.userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference gainRef = userCollection.doc(followerGainer.userId);
        DocumentReference fanRef = userCollection.doc(fanUser.userId);

        transaction.update(gainRef, {
          'followers': FieldValue.arrayUnion([fanUser.userId])
        });

        transaction.update(fanRef, {
          'following': FieldValue.arrayUnion([followerGainer.userId])
        });

        Followers().updateFollowers(gain);
      });

      return true;
    } catch (_) {
      //
    }
    return false;
  }

  Future<bool> addView(Story story, Users user) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference storyRefrence = storyCollection.doc(story.storyId);

        transaction.update(storyRefrence, {
          'views': FieldValue.arrayUnion([user.userId])
        });
      });

      if (!story.views.contains(user.userId)) {
        story.views.add(user.userId);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> addPost(
      String userId,
      String userName,
      String? profileLoc,
      String postLoc,
      String? content,
      int totalLikes,
      int totalComments,
      List<String> likesList,
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
        'uploadDateTime': fireStoreDate,
        'likesList': likesList,
      });
      final post = Posts(doc.id, totalLikes, totalComments, userId, userName,
          profileLoc, postLoc, content, currentDate, likesList);

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
        List<String> likesList = List<String>.from(data['likesList']);

        DateTime dartDate = firebaseDate.toDate();

        Posts post = Posts(postId, totalLikes, totalComments, userId, userName,
            profileLoc, postLoc, content, dartDate, likesList);
        posts.add(post);

        if (send) {
          PostsCollection().addPost(post: post);
        }
      }
      return posts;
    } catch (e) {}
    return null;
  }

  bool checkCondition(List<Story> list, Story story) {
    var c = list[0].userName == story.userName;
    return c;
  }

  Future<List<List<Story>>> getStories(Users user) async {
    Timestamp currentDate = Timestamp.fromDate(DateTime.now());
    List<String> search =
        user.following.isEmpty ? [] : List.from(user.following);
    search.add(user.userId);
    List<List<Story>> stories = [];
    try {
      var data = await storyCollection
          .where('userId', whereIn: search)
          .where('finishDateTime', isGreaterThan: currentDate)
          .orderBy('finishDateTime', descending: false)
          .get();

      for (QueryDocumentSnapshot document in data.docs) {
        Story story = makeStoryObject(document);

        for (var i = 0; i < stories.length; i++) {
          if (checkCondition(stories[i], story)) {
            stories[i].add(story);
            break;
          } else if (i == stories.length - 1) {
            stories.add([story]);
            break;
          }
        }

        if (stories.isEmpty) {
          stories.add([story]);
        }
      }

      return stories;
    } catch (e) {}
    return stories;
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
    } catch (e) {}
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
  Future<void> updateToken(String userId, String fcmtoken) async {
    try {
      DocumentReference result = userCollection.doc(userId);

      await result.update({'token': fcmtoken});

      //update location in chats
      QuerySnapshot docs = await chatCollection
          .where(Filter.or(Filter('user1UserId', isEqualTo: userId),
              Filter('user2UserId', isEqualTo: userId)))
          .get();

      for (QueryDocumentSnapshot documentSnapshot in docs.docs) {
        DocumentReference documentRef = chatCollection.doc(documentSnapshot.id);
        var chat = getChatObject(documentSnapshot);
        if (chat.user1UserId == userId) {
          await documentRef.update({'user1FCMtoken': fcmtoken});
        } else {
          await documentRef.update({'user2FCMtoken': fcmtoken});
        }
      }
    } catch (e) {
      //
    }
  }

  Future<Story?> uploadStory(
      {required String userId,
      required String storyImageLoc,
      required String? content}) async {
    try {
      Users user = await getUser(userId, false) as Users;
      DateTime currentDateTime = DateTime.now();
      DateTime finishDateTime = currentDateTime.add(const Duration(hours: 24));
      List<String> views = [];
      Timestamp fireStoreDate1 = Timestamp.fromDate(currentDateTime);
      Timestamp fireStoreDate2 = Timestamp.fromDate(finishDateTime);

      var id = await storyCollection.add({
        'userId': userId,
        'userName': user.userName,
        'profileLoc': user.imageLoc,
        'uploadDateTime': fireStoreDate1,
        'content': content,
        'finishDateTime': fireStoreDate2,
        'storyImageLoc': storyImageLoc,
        'views': views,
      });
      Story story = Story(content, finishDateTime, user.imageLoc, id.id,
          storyImageLoc, currentDateTime, userId, user.userName, views);
      return story;
    } catch (e) {}
    return null;
  }

  Future<bool> insertComments(Comments comment) async {
    try {
      DateTime currentDate = DateTime.now();
      Timestamp fireStoreDate = Timestamp.fromDate(currentDate);
      await commentsCollection.add({
        'userId': comment.userId,
        'userName': comment.userName,
        'profileLoc': comment.profileLoc,
        'postId': comment.postId,
        'uploadDate': fireStoreDate,
        'content': comment.content,
      });

      DocumentReference postRef = postCollection.doc(comment.postId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(postRef, {'totalComments': FieldValue.increment(1)});

        return true;
      });
    } catch (e) {
      //
    }
    return false;
  }

  Future<Chats?> getChat(String senderId, String receiverId) async {
    try {
      var query1 = await chatCollection
          .where('user1UserId', isEqualTo: senderId)
          .where('user2UserId', isEqualTo: receiverId)
          .limit(1)
          .get();

      // Query 2: user2UserId matches senderId or receiverId
      var query2 = await chatCollection
          .where('user2UserId', isEqualTo: senderId)
          .where('user1UserId', isEqualTo: receiverId)
          .limit(1)
          .get();

      List<QueryDocumentSnapshot> docs = query1.docs + query2.docs;
      if (docs.isEmpty) {
        return null;
      } else {
        Map<String, dynamic> data = docs[0].data() as Map<String, dynamic>;
        var chatId = docs[0].id;
        var user1UserId = data['user1UserId'];
        var user1UserName = data['user1UserName'];
        var user1Name = data['user1Name'];
        var user1ProfileLoc = data['user1ProfileLoc'];
        var user1FCMToken = data['user1FCMtoken'];
        var user2FCMToken = data['user2FCMtoken'];
        var user2UserId = data['user2UserId'];
        var user2UserName = data['user2UserName'];
        var user2Name = data['user2Name'];
        var user2ProfileLoc = data['user2ProfileLoc'];

        var user1Seen = data['user1Seen'];
        var user2Seen = data['user2Seen'];

        Timestamp date = data['time'];

        var dartDate = date.toDate();

        Chats chat = Chats(
            chatId: chatId,
            user1UserId: user1UserId,
            user1UserName: user1UserName,
            user1Name: user1Name,
            user1FCMToken: user1FCMToken,
            user1ProfileLoc: user1ProfileLoc,
            user2UserId: user2UserId,
            user2UserName: user2UserName,
            user2FCMToken: user2FCMToken,
            user2Name: user2Name,
            user2ProfileLoc: user2ProfileLoc,
            user1Seen: user1Seen,
            user2Seen: user2Seen,
            date: dartDate);

        return chat;
      }
    } catch (e) {
      print(e);
//
      return null;
    }
  }

  Future<void> createAChat(Chats chat) async {
    Timestamp now = Timestamp.fromDate(DateTime.now());
    try {
      var doc = await chatCollection.add({
        'user1UserId': chat.user1UserId,
        'user1UserName': chat.user1UserName,
        'user1Name': chat.user1Name,
        'user1FCMtoken': chat.user1FCMToken,
        'user1ProfileLoc': chat.user1ProfileLoc,
        'user2UserId': chat.user2UserId,
        'user2UserName': chat.user2UserName,
        'user2Name': chat.user2Name,
        'user2FCMtoken': chat.user2FCMToken,
        'user2ProfileLoc': chat.user2ProfileLoc,
        'user1Seen': chat.user1Seen,
        'user2Seen': chat.user2Seen,
        'time': now
      });

      chat.chatId = doc.id;
    } catch (e) {
      //
    }
  }

  Future<bool> insertMessage(
      Chats chat, String? message, String? imageLoc, String? postId) async {
    Timestamp now = Timestamp.fromDate(DateTime.now());
    try {
      await messageCollection.add({
        'chatId': chat.chatId,
        'senderUserId': chat.user1UserId,
        'receiverId': chat.user2UserId,
        'message': message,
        'imageLoc': imageLoc,
        'postId': postId,
        'time': now,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateSeen(Chats chat, int personalUserNumber) async {
    try {
      var doc = chatCollection.doc(chat.chatId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        if (personalUserNumber == 1) {
          transaction.update(doc, {
            'user1Seen': true,
          });
          chat.user1Seen = true;
        } else {
          transaction.update(doc, {
            'user2Seen': true,
          });
          chat.user2Seen = true;
        }
      });
    } catch (e) {
      print(e);
      //
    }
  }

  Future<void> toggleSeen(Chats chat, int personalUserNumber) async {
    try {
      var doc = chatCollection.doc(chat.chatId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        if (personalUserNumber == 1) {
          transaction.update(doc, {
            'user1Seen': true,
            'user2Seen': false,
          });
          chat.user1Seen = true;
          chat.user2Seen = false;
        } else {
          transaction.update(doc, {
            'user1Seen': false,
            'user2Seen': true,
          });
          chat.user1Seen = false;
          chat.user2Seen = true;
        }
      });
    } catch (e) {
      //
    }
  }

  Future<bool> sendMessage(Chats chat, int personalUserNumber, String? message,
      String? imageLoc, String? postId) async {
    try {
      if (chat.chatId == null) {
        //create chat document if it doesn't exists
        await createAChat(chat);
      }

      var result = await insertMessage(chat, message, imageLoc, postId);
      if (!result) {
        return false;
      } else {
        await toggleSeen(chat, personalUserNumber);

        return true;
      }
    } catch (e) {
      print(e);
      //
      return false;
    }
  }

  Future<void> deleteNotification(Posts? post, Users senderUser,
      Users? receiverUser, bool isLike, bool isFollow, bool isRequest) async {
    if (post != null) {
      if (isLike) {
        var doc = await notificationCollection
            .where('senderId', isEqualTo: senderUser.userId)
            .where('postId', isEqualTo: post.postId)
            .where('isLikeNotification', isEqualTo: true)
            .limit(1)
            .get();
        if (doc.docs.isNotEmpty) {
          var ref = doc.docs.first;
          notificationCollection.doc(ref.id).delete();
        }
      }
    } else if (receiverUser != null) {
      if (isFollow) {
        var doc = await notificationCollection
            .where('senderId', isEqualTo: senderUser.userId)
            .where('receiverId', isEqualTo: receiverUser.userId)
            .where('isFollowerNotification', isEqualTo: true)
            .limit(1)
            .get();
        if (doc.docs.isNotEmpty) {
          var ref = doc.docs.first;
          notificationCollection.doc(ref.id).delete();
        }
      } else if (isRequest) {
        var doc = await notificationCollection
            .where('senderId', isEqualTo: senderUser.userId)
            .where('receiverId', isEqualTo: receiverUser.userId)
            .where('isRequestNotification', isEqualTo: true)
            .limit(1)
            .get();
        if (doc.docs.isNotEmpty) {
          var ref = doc.docs.first;
          notificationCollection.doc(ref.id).delete();
        }
      }
    }
  }

  Future<void> insertNotification(Notifications notification) async {
    try {
      notificationCollection.add({
        'receiverId': notification.receiverId,
        'isLikeNotification': notification.isLikeNotification,
        'isCommentNotification': notification.isCommentNotification,
        'isFollowerNotification': notification.isFollowerNotification,
        'isRequestNotification': notification.isRequestNotification,
        'senderId': notification.senderId,
        'senderUserName': notification.senderUserName,
        'senderProfileLoc': notification.senderProfileLoc,
        'time': Timestamp.fromDate(notification.time),
        'postId': notification.postId,
        'postLoc': notification.postLoc,
        'comment': notification.comment
      });
    } catch (e) {
      //
    }
  }

  Future<bool> isRequested(Users ownerUser, Users visitingUser) async {
    try {
      QuerySnapshot docs = await notificationCollection
          .where('senderId', isEqualTo: ownerUser.userId)
          .where('receiverId', isEqualTo: visitingUser.userId)
          .where('isRequestNotification', isEqualTo: true)
          .get();

      if (docs.docs.isNotEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      //
      return false;
    }
  }
}

class Notifications {
  late String receiverId;
  late bool isLikeNotification;
  late bool isCommentNotification;
  late bool isFollowerNotification;
  late bool isRequestNotification;
  late String senderId;
  late String senderUserName;
  late String? senderProfileLoc;
  late DateTime time;
  late String? postId;
  late String? postLoc;
  late String? comment;

  Notifications(
      {required this.receiverId,
      required this.isLikeNotification,
      required this.isCommentNotification,
      required this.isFollowerNotification,
      required this.isRequestNotification,
      required this.senderId,
      required this.senderProfileLoc,
      required this.senderUserName,
      required this.time,
      required this.postId,
      required this.postLoc,
      required this.comment});
}

class Messages {
  late String chatId;
  late String senderUserId;
  late String receicerUserId;
  late String? content;
  late DateTime time;
  String? imageLoc;
  String? postId;

  Messages(
      {required this.chatId,
      required this.senderUserId,
      required this.receicerUserId,
      required this.content,
      required this.time,
      required this.imageLoc,
      required this.postId});
}

class Chats {
  late String? chatId;
  late String user1UserId;
  late String user1UserName;
  late String user1Name;
  late String user1FCMToken;
  late String? user1ProfileLoc;
  late String user2UserId;
  late String user2UserName;
  late String user2Name;
  late String user2FCMToken;
  late String? user2ProfileLoc;
  late bool user1Seen;
  late bool user2Seen;
  late DateTime date;

  Chats(
      {this.chatId,
      required this.user1UserId,
      required this.user1UserName,
      required this.user1Name,
      required this.user1FCMToken,
      required this.user1ProfileLoc,
      required this.user2UserId,
      required this.user2UserName,
      required this.user2Name,
      required this.user2FCMToken,
      required this.user2ProfileLoc,
      required this.user1Seen,
      required this.user2Seen,
      required this.date});
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

class Story {
  late String storyId;
  late String userName;
  late String userId;
  late String storyImageLoc;
  late String? profileLoc;
  late DateTime uploadDate;
  late DateTime finishDateTime;
  late String? content;
  late List<String> views;

  Story(
      this.content,
      this.finishDateTime,
      this.profileLoc,
      this.storyId,
      this.storyImageLoc,
      this.uploadDate,
      this.userId,
      this.userName,
      this.views);
}

class Comments {
  late String userName;
  late String userId;
  late String? profileLoc;
  late String postId;
  late DateTime uploadDateTime;
  late String content;

  Comments(this.postId, this.userId, this.userName, this.profileLoc,
      this.uploadDateTime, this.content);
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
  late List<String> likesList;

  Posts(
      this.postId,
      this.totalLikes,
      this.totalComments,
      this.userId,
      this.userName,
      this.profLoc,
      this.postLoc,
      this.content,
      this.uploadDateTime,
      this.likesList);

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

class StoryCollection extends ValueNotifier<List<Story>> {
  //singleton class so only instance exists
  StoryCollection._sharedInstance() : super([]);
  static final StoryCollection _shared = StoryCollection._sharedInstance();
  factory StoryCollection() => _shared;

  void addStory({required Story story}) {
    for (Story s in value) {
      //If same post is added again then the view becomes redundant
      if (s.storyId == story.storyId) {
        return;
      }
    }
    value.add(story);

    notifyListeners();
  }

  void addAllStories({required List<Story> stories}) {
    value.addAll(stories);
    notifyListeners();
  }

  void clear() {
    value.clear();
    notifyListeners();
  }
}
