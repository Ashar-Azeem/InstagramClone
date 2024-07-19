import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/utilities/color.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error:"),
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
                'Ok',
                style: TextStyle(color: primaryColor),
              ),
            )
          ],
        );
      });
}
