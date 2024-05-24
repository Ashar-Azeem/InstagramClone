import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print(message.notification!.title);
}

class Messaging {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<String> getFCMToken() async {
    await firebaseMessaging.requestPermission();
    String token = await firebaseMessaging.getToken() as String;
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    print(token);
    return token;
  }
}
