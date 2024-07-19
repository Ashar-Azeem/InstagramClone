import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/services/SendingNotification.dart';
import 'package:uuid/uuid.dart';

imagepicker(ImageSource source) async {
  XFile? image = await ImagePicker().pickImage(source: source);

  if (image != null) {
    return image.readAsBytes();
  }
}

Future<String> uploadImageGetUrl(
    Uint8List image, String category, bool isPost) async {
  String imageId = const Uuid().v1();
  if (isPost) {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child(category)
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(imageId);
    UploadTask task = storageReference.putData(image);
    TaskSnapshot snap = await task;
    return snap.ref.getDownloadURL();
  } else {
    Reference storageReference =
        FirebaseStorage.instance.ref().child(category).child(imageId);
    UploadTask task = storageReference.putData(image);
    TaskSnapshot snap = await task;
    return snap.ref.getDownloadURL();
  }
}

Future<String> uploadStoryImageGetUrl(Uint8List image, String category) async {
  String imageId = const Uuid().v1();
  Reference storageReference = FirebaseStorage.instance
      .ref()
      .child(category)
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child(imageId);
  UploadTask task = storageReference.putData(image);
  TaskSnapshot snap = await task;
  return snap.ref.getDownloadURL();
}

Future<Uint8List> compressImage(Uint8List imageBytes) async {
  try {
    // Compress the image using flutter_image_compress
    List<int> compressedBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      quality: 45, // Adjust the quality as needed (0 to 100)
    );

    // Convert the compressed bytes to Uint8List
    Uint8List compressedUint8List = Uint8List.fromList(compressedBytes);

    return compressedUint8List;
  } catch (e) {
    throw Exception('Failed to compress image');
  }
}

Story makeStoryObject(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  String storyId = snapshot.id;
  String userId = data['userId'] as String;
  String userName = data['userName'] as String;
  String? profileLoc = data['profileLoc'] as String?;
  String storyImageLoc = data['storyImageLoc'] as String;
  String? content = data['content'] as String?;
  Timestamp firebaseDate1 = data['uploadDateTime'] as Timestamp;
  Timestamp firebaseDate2 = data['finishDateTime'] as Timestamp;
  List<String> views = List<String>.from(data['views']);

  DateTime uploadDate = firebaseDate1.toDate();
  DateTime endDate = firebaseDate2.toDate();

  Story story = Story(content, endDate, profileLoc, storyId, storyImageLoc,
      uploadDate, userId, userName, views);

  return story;
}

Chats getChatObject(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  var chatId = snapshot.id;
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
      user1FCMToken: user1FCMToken,
      user2FCMToken: user2FCMToken,
      user1Name: user1Name,
      user1ProfileLoc: user1ProfileLoc,
      user2UserId: user2UserId,
      user2UserName: user2UserName,
      user2Name: user2Name,
      user2ProfileLoc: user2ProfileLoc,
      user1Seen: user1Seen,
      user2Seen: user2Seen,
      date: dartDate);

  return chat;
}

Future<void> notification(Chats chat, String message) async {
  if (chat.user1UserId == FirebaseAuth.instance.currentUser!.uid) {
    await sendNotification(
        chat.user2FCMToken, chat.user1UserName, message, null);
  } else {
    await sendNotification(
        chat.user1FCMToken, chat.user2UserName, message, null);
  }
}

Future<void> sendLikeNotification(Users ownerUser, Posts post) async {
  if (ownerUser.userId == post.userId) {
    return;
  }
  Users otherUser = await DataBase().getUser(post.userId) as Users;
  String data = "${ownerUser.userName} liked your picture";
  Notifications notification = Notifications(
      receiverId: post.userId,
      isLikeNotification: true,
      isCommentNotification: false,
      isFollowerNotification: false,
      isRequestNotification: false,
      senderId: ownerUser.userId,
      senderProfileLoc: ownerUser.imageLoc,
      senderUserName: ownerUser.userName,
      time: DateTime.now(),
      postId: post.postId,
      postLoc: post.postLoc,
      comment: null);
  await DataBase().insertNotification(notification);
  await sendNotification(otherUser.token, 'Notification', data, null);
}

Future<void> sendCommentNotification(
    Users ownerUser, Posts post, String comment) async {
  if (ownerUser.userId == post.userId) {
    return;
  }
  Users otherUser = await DataBase().getUser(post.userId) as Users;
  String data = "${ownerUser.userName} commented on your picture";
  Notifications notification = Notifications(
      receiverId: post.userId,
      isLikeNotification: false,
      isCommentNotification: true,
      isFollowerNotification: false,
      isRequestNotification: false,
      senderId: ownerUser.userId,
      senderProfileLoc: ownerUser.imageLoc,
      senderUserName: ownerUser.userName,
      time: DateTime.now(),
      postId: post.postId,
      postLoc: post.postLoc,
      comment: comment);
  await DataBase().insertNotification(notification);
  await sendNotification(otherUser.token, data, comment, null);
}
