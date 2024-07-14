// ignore_for_file: file_names

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendNotification(
    String token, String title, String body, String? image) async {
  try {
    const String serverKey =
        'AAAA2J5UG80:APA91bGcOPjg-dMxdE6GyEJyT9VXNsQv5iwGAwXmTsuO8PtXTJXSQRRWapEUZAk2nii0slB6O8b1W-jg0J7ggDDrn4AqN8jM-G1N3g1oTzQYp3sMmMTaWS4a64f0QLOtmEuQNVRYa-4a';
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': body,
            'icon': null,
            // Optionally include a URL to a large icon
            'image': image,
          },
          'priority': 'high',
          'to': token,
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    print(e);
  }
}
