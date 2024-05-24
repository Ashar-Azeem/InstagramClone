import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysocialmediaapp/utilities/const.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:mysocialmediaapp/utilities/state.dart';
import 'package:mysocialmediaapp/utilities/utilities.dart';

class RegistrationView extends StatefulWidget {
  const RegistrationView({super.key});

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final GlobalKey<FormState> _fullName = GlobalKey<FormState>();
  final GlobalKey<FormState> _userName = GlobalKey<FormState>();
  final GlobalKey<FormState> _email = GlobalKey<FormState>();
  final GlobalKey<FormState> _password = GlobalKey<FormState>();
  Uint8List? file;
  String? url;
  bool loading = false;
  bool passwordInvisible = true;
  late TextEditingController email;
  late TextEditingController password;
  late TextEditingController userName;
  late TextEditingController fullName;
  @override
  void initState() {
    email = TextEditingController();
    password = TextEditingController();
    userName = TextEditingController();
    fullName = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    fullName.dispose();
    userName.dispose();
    super.dispose();
  }

  void selectImage() async {
    Uint8List? img = await imagepicker(ImageSource.gallery);
    setState(() {
      file = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //This column is the parent column of all text fields login and register button
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 40,
            child: Column(
              children: [
                //Space above the icon
                //Icon
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Align(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        "assets/logo.svg",
                        color: primaryColor,
                        height: 60,
                      )),
                ),
                const SizedBox(
                  height: 2,
                ),
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Stack(alignment: Alignment.bottomRight, children: [
                    file == null
                        ? const CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                AssetImage('assets/blankprofile.png'),
                            backgroundColor: mobileBackgroundColor,
                          )
                        : CircleAvatar(
                            radius: 60,
                            backgroundImage: MemoryImage(file!),
                            backgroundColor: mobileBackgroundColor,
                          ),
                    IconButton(
                        onPressed: () {
                          selectImage();
                        },
                        icon: const Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Color.fromARGB(255, 134, 133, 133),
                        )),
                  ]),
                ),

                Flexible(flex: 1, child: Container()),
                const SizedBox(
                  height: 2,
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Form(
                        key: _fullName,
                        child: TextFormField(
                          enableSuggestions: false,
                          cursorColor: Colors.white,
                          autocorrect: false,
                          controller: fullName,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your 'full name'";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            isDense: true, // Added this
                            contentPadding: EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: primaryColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: primaryColor),
                            ),
                            labelText: 'Full Name',
                            errorStyle:
                                TextStyle(color: Colors.red, fontSize: 10),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: Color.fromARGB(255, 199, 78, 69),
                              ),
                            ),
                            labelStyle: TextStyle(color: primaryColor),
                          ),
                        ),
                      )),
                ),
                const SizedBox(
                  height: 8,
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Form(
                        key: _userName,
                        child: TextFormField(
                          enableSuggestions: false,
                          cursorColor: Colors.white,
                          autocorrect: false,
                          controller: userName,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your 'user name'";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            isDense: true, // Added this
                            contentPadding: EdgeInsets.all(16),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                              width: 1,
                              color: primaryColor,
                            )),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: primaryColor),
                            ),
                            labelText: 'User Name',
                            errorStyle:
                                TextStyle(color: Colors.red, fontSize: 10),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: Color.fromARGB(255, 199, 78, 69),
                              ),
                            ),
                            labelStyle: TextStyle(color: primaryColor),
                          ),
                        ),
                      )),
                ),
                const SizedBox(
                  height: 8,
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Form(
                        key: _email,
                        child: TextFormField(
                          enableSuggestions: false,
                          autocorrect: false,
                          cursorColor: Colors.white,
                          controller: email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your 'email'";
                            } else if (!value.contains('@')) {
                              return "Invalid email";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            isDense: true, // Added this
                            contentPadding: EdgeInsets.all(16),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                              width: 1,
                              color: primaryColor,
                            )),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: primaryColor),
                            ),
                            labelText: 'Email',
                            errorStyle:
                                TextStyle(color: Colors.red, fontSize: 10),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: Color.fromARGB(255, 199, 78, 69),
                              ),
                            ),
                            labelStyle: TextStyle(color: primaryColor),
                          ),
                        ),
                      )),
                ),
                const SizedBox(
                  height: 8,
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Form(
                      key: _password,
                      child: TextFormField(
                        obscureText: passwordInvisible,
                        cursorColor: Colors.white,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: password,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter 'password'";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            isDense: true, // Added this
                            contentPadding: const EdgeInsets.all(16),
                            border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: primaryColor)),
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: primaryColor)),
                            labelText: 'Password',
                            errorStyle: const TextStyle(
                                color: Colors.red, fontSize: 10),
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: Color.fromARGB(255, 199, 78, 69),
                              ),
                            ),
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
                    ),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_fullName.currentState!.validate() &&
                          _userName.currentState!.validate() &&
                          _email.currentState!.validate() &&
                          _password.currentState!.validate()) {
                        setState(() {
                          loading = true;
                        });
                        final e = email.text;
                        final p = password.text;
                        final n = fullName.text;
                        final u = userName.text;

                        registrationBackEnd(e, p, n, u, context, file).then(
                          (result) async {
                            setState(() {
                              loading = false;
                            });
                            if (result == "success") {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  MainUIRoute, (route) => false);
                            }
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(370, 47),
                        backgroundColor: blueColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Register",
                            style: TextStyle(color: primaryColor),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: TextButton(
                      onPressed: () {
                        //Navigator is an stack that keeps track of our views
                        //In this case we are adding the new view into that stack.
                        //and when route is false then previous screen is not accesible.
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            LoginRoute, (route) => false);

                        //Navigator Stack stores the addresses of all the views
                      },
                      child: const Text(
                        "Already registered ? Login here",
                        style: TextStyle(color: Colors.grey),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
