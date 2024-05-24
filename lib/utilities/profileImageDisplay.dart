import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';

Future<void> showdisplayImage(BuildContext context, Users user) {
  return showDialog(
      // barrierColor: Colors.black,
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            surfaceTintColor: mobileBackgroundColor,
            shadowColor: Colors.blue,
            content: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(user.imageLoc!),
              radius: 120,
            ));
      });
}
