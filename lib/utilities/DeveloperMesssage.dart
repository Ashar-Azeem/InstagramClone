import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/utilities/color.dart';

Future<void> showMessage(BuildContext context, String text) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Message from the dev'),
          content: Text(text),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white), // Border color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0), // Border radius
                  )),
              child: const Text(
                'Ok sir',
                style: TextStyle(color: primaryColor),
              ),
            )
          ],
        );
      });
}
