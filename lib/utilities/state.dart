import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/services/AuthExceptions.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/services/FireBaseMessaging.dart';
import 'package:mysocialmediaapp/services/SendingNotification.dart';
import 'package:mysocialmediaapp/services/firebase.dart';
import 'package:mysocialmediaapp/utilities/ErrorDialogue.dart';
import 'package:mysocialmediaapp/utilities/utilities.dart';

Future<String?> registrationBackEnd(String e, String p, String n, String u,
    BuildContext context, Uint8List? file) async {
  DataBase db = DataBase();
  String? url;
  try {
    bool checkUserName = await db.userNameExists(u);
    if (!checkUserName) {
      await AuthService().createUser(email: e, password: p);

      if (file != null) {
        file = await compressImage(file);
        url = await uploadImageGetUrl(file, "profile", false);
      }

      String token = await Messaging().getFCMToken();

      await db.insertUser(
          FirebaseAuth.instance.currentUser!.uid, n, u, url, [], [], token);
      return "success";
    } else {
      await showErrorDialog(context, 'UserName Already exists');
    }
  } on UserNotFoundAuthException {
    await showErrorDialog(context, 'User not found');
  } on WrongPasswordAuthException {
    await showErrorDialog(context, 'Incorrect password  ');
  } on GenericAuthException {
    await showErrorDialog(context, 'Authentication error');
  } on EmailAlreadyInUseAuthException {
    await showErrorDialog(context, 'Email already in use');
  } on InvalidEmailAuthException {
    await showErrorDialog(context, 'Invalid Email');
  } catch (_) {
    await showErrorDialog(context, 'Unknown Error');
  }
  return null;
}

Future<String> loginUser(
    String email, String password, BuildContext context) async {
  try {
    await AuthService().login(email: email, password: password);
    String token = await Messaging().getFCMToken();
    await DataBase().updateToken(FirebaseAuth.instance.currentUser!.uid, token);

    return 'success';
  } on UserNotFoundAuthException {
    await showErrorDialog(context, 'User not found');
  } on WrongPasswordAuthException {
    await showErrorDialog(context, 'Incorrect password  ');
  } on GenericAuthException {
    await showErrorDialog(context, 'Authentication error');
  }
  return 'failure';
}

Future<String> postProcess(
    Uint8List post, Users user, String? content, BuildContext context) async {
  try {
    post = await compressImage(post);
    String url = await uploadImageGetUrl(post, 'posts', true);

    await DataBase().addPost(user.userId, user.userName, user.imageLoc, url,
        content, 0, 0, [], user);

    return 'success';
  } catch (e) {
    await showErrorDialog(context, e.toString());
  }
  return 'failure';
}

Future<Users?> updatePorfileProcess(
    Uint8List profilePicture, Users user) async {
  try {
    profilePicture = await compressImage(profilePicture);
    await DataBase().updateProfilePicture(user, profilePicture);
    final user1 = await DataBase().getUser(user.userId, false);
    return user1;
  } catch (e) {
    //
  }
  return null;
}

Future<String> changePrivacy(Users user, DataBase db, List<Posts> posts) async {
  try {
    await db.changeAccountSecurity(user, posts);
    print('success');
    return "success";
  } catch (e) {
    //
  }
  return "failure";
}

Future<bool> addRelationship(Users user, Users ownerUser, DataBase db) async {
  try {
    await db.addFollowerAndFollowing(user, ownerUser);
    Notifications notification = Notifications(
        receiverId: user.userId,
        isLikeNotification: false,
        isCommentNotification: false,
        isFollowerNotification: true,
        isRequestNotification: false,
        senderId: ownerUser.userId,
        senderProfileLoc: ownerUser.imageLoc,
        senderUserName: ownerUser.userName,
        time: DateTime.now(),
        postId: null,
        postLoc: null,
        comment: null);
    await db.insertNotification(notification);
    await sendNotification(user.token, 'Following',
        "${ownerUser.userName} started following you", null);

    return true;
  } catch (e) {
    //
  }
  return false;
}

Future<bool> removeRelationship(
    Users user, Users ownerUser, DataBase db) async {
  try {
    await db.removeFollowerAndFollowing(user, ownerUser);
    await db.deleteNotification(null, ownerUser, user, false, true, false);

    return true;
  } catch (e) {
    //
  }
  return false;
}

Future<bool> removeFollower(Users user, Users ownerUser, DataBase db) async {
  var result = await db.removeFollower(user, ownerUser);
  return result;
}

Future<bool> confirmingARequest(
    Users userWhoWillGainFollower, Users userWhoWillGainAFriend) async {
  var result = await DataBase()
      .gainFollower(userWhoWillGainFollower, userWhoWillGainAFriend);

  await DataBase().deleteNotification(null, userWhoWillGainAFriend,
      userWhoWillGainFollower, false, false, true);

  await sendNotification(
      userWhoWillGainAFriend.token,
      'Request Accepted',
      "${userWhoWillGainFollower.userName} has accepted your following request",
      null);

  return result;
}

Future<Story?> postStoryProcess(
    {required String userId,
    required Uint8List storyImage,
    required String? content,
    required BuildContext context}) async {
  try {
    var updatedImage = await compressImage(storyImage);
    String url = await uploadStoryImageGetUrl(updatedImage, 'story');

    var story = await DataBase()
        .uploadStory(userId: userId, storyImageLoc: url, content: content);

    return story;
  } catch (e) {
    await showErrorDialog(context, e.toString());
  }
  return null;
}
