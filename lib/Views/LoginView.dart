import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mysocialmediaapp/utilities/const.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:mysocialmediaapp/utilities/state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool loading = false;
  bool passwordInvisible = true;
  late TextEditingController email;
  late TextEditingController password;
  @override
  void initState() {
    email = TextEditingController();
    password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      //This column is the parent column of all text fields login and register button
      body: SafeArea(
        child: Column(
          children: [
            //Space above the icon
            Flexible(flex: 2, child: Container()),
            //Icon
            Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  "assets/logo.svg",
                  color: primaryColor,
                  height: 72,
                )),
            //Space below the icon
            const SizedBox(
              height: 40,
            ),
            Column(
              //this centers the whole column
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(children: [
                    TextField(
                      cursorColor: Colors.white,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      controller: email,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          width: 1,
                          color: primaryColor,
                        )),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: primaryColor),
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(color: primaryColor),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      cursorColor: Colors.white,
                      obscureText: passwordInvisible,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: password,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: primaryColor)),
                          focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: primaryColor)),
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: primaryColor),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  passwordInvisible = !passwordInvisible;
                                });
                              },
                              icon: Icon(
                                //ternary operator  bool ? open eye: close eye
                                passwordInvisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ))),
                    ),
                  ]),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    final e = email.text;
                    final p = password.text;
                    loginUser(e, p, context).then((result) async {
                      setState(() {
                        loading = false;
                      });
                      if (result == 'success') {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            MainUIRoute, (route) => false);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(370, 50),
                      backgroundColor: blueColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: loading == false
                      ? const Text(
                          "Login",
                          style: TextStyle(color: primaryColor),
                        )
                      : const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 2,
                ),
              ],
            ),
            Flexible(flex: 2, child: Container()),
            TextButton(
                onPressed: () {
                  //Navigator is an stack that keeps track of our views
                  //In this case we are adding the new view into that stack.
                  //and when route is false then previous screen is not accesible.
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(RegisterRoute, (route) => false);
                  //Navigator Stack stores the addresses of all the views
                },
                child: const Text(
                  "Not registered yet ? Register here",
                  style: TextStyle(color: Colors.grey),
                )),
          ],
        ),
      ),
    );
  }
}
