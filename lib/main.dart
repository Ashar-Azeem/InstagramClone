import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mysocialmediaapp/Views/LoginView.dart';
import 'package:mysocialmediaapp/Views/MainUI.dart';
import 'package:mysocialmediaapp/Views/RegistrationView.dart';
import 'package:mysocialmediaapp/utilities/const.dart';
import 'package:mysocialmediaapp/services/firebase.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        title: 'My Instagram',
        theme: ThemeData.dark()
            .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
        home: const Main(),
        routes: {
          LoginRoute: (context) => const LoginView(),
          RegisterRoute: (context) => const RegistrationView(),
          MainUIRoute: (context) => const MainUI()
        },
      );
    }),
  );
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService().initialize(),
        builder: (
          context,
          snapshot,
        ) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              {
                if (FirebaseAuth.instance.currentUser == null) {
                  return const LoginView();
                } else {
                  return const MainUI();
                }
              }
            default:
              {
                return const Scaffold(
                    body: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeCap: StrokeCap.round,
                  ),
                ));
              }
          }
        });
  }
}
