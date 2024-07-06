import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
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
