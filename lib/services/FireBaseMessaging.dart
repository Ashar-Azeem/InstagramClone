import 'package:firebase_messaging/firebase_messaging.dart';

class Messaging {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<String> getFCMToken() async {
    await firebaseMessaging.requestPermission();
    String token = await firebaseMessaging.getToken() as String;

    return token;
  }
}
