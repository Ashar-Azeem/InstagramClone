// ignore_for_file: file_names
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:mysocialmediaapp/utilities/state.dart';
import 'package:mysocialmediaapp/utilities/utilities.dart';
import 'package:sizer/sizer.dart';

class AddStoryView extends StatefulWidget {
  final Users user;
  const AddStoryView({super.key, required this.user});

  @override
  State<AddStoryView> createState() => _AddStoryViewState();
}

class _AddStoryViewState extends State<AddStoryView> {
  TextEditingController content = TextEditingController();
  bool itemSelected = false;
  Uint8List? story;
  bool loading = false;
  late Users user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragUpdate: (details) {
          // Note: Sensitivity is integer used when you don't want to mess up vertical drag
          int sensitivity = 10;

          if (details.delta.dx < -sensitivity) {
            Navigator.pop(context);
            //Left Swipe
          }
        },
        child: Scaffold(
            appBar: null,
            body: SafeArea(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: itemSelected
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      itemSelected = false;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Color.fromARGB(255, 206, 205, 205),
                                    size: 35,
                                  )),
                              const Text(
                                "Your Story",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 206, 205, 205),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                      });

                                      postStoryProcess(
                                              userName: user.userName,
                                              userId: user.userId,
                                              storyImage: story!,
                                              profileLoc: user.imageLoc,
                                              content: content.text,
                                              context: context)
                                          .then((value) {
                                        if (value) {
                                          setState(() {
                                            loading = false;
                                            itemSelected = false;
                                            content.text = '';
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Story Uploaded')));
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Some Error Occured')));
                                        }
                                      });
                                    },
                                    child: const Text(
                                      'Post',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 206, 205, 205),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )),
                              )
                            ],
                          )
                        : Row(children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Color.fromARGB(255, 206, 205, 205),
                                  size: 35,
                                )),
                            Padding(
                              padding: EdgeInsets.only(left: 20.w),
                              child: const Text(
                                "Add Your Story",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 206, 205, 205),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]),
                  ),
                  const Divider(
                    color: Color.fromARGB(255, 206, 205, 205),
                  ),
                  itemSelected == true
                      ? Column(
                          children: [
                            if (loading == true)
                              const LinearProgressIndicator(
                                color: blueColor,
                              ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Container(
                                    height: 65.h,
                                    width: 85.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      image: DecorationImage(
                                        image: MemoryImage(story!),
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 8,
                                  left: 7.5.w,
                                  right: 6,
                                  bottom: 6 +
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: SizedBox(
                                width: 100.w - 10,
                                height: 6.h,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 10.w,
                                        height: 10.w,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 38, 38, 38),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          image: DecorationImage(
                                            image: MemoryImage(story!),
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 13, right: 0),
                                      child: SizedBox(
                                        width: 68.w,
                                        child: TextField(
                                          cursorColor: Colors.white,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal),
                                          controller: content,
                                          autocorrect: false,
                                          enableSuggestions: true,
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Enter Your Caption'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 30.h),
                              child: Center(
                                child: IconButton(
                                    onPressed: () async {
                                      story =
                                          await imagepicker(ImageSource.camera);
                                      if (story != null) {
                                        setState(() {
                                          itemSelected = true;
                                        });
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.add_a_photo,
                                      size: 60,
                                      color: Color.fromARGB(255, 206, 205, 205),
                                    )),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 3, top: 40.h),
                                child: IconButton(
                                    onPressed: () async {
                                      story = await imagepicker(
                                          ImageSource.gallery);
                                      if (story != null) {
                                        setState(() {
                                          itemSelected = true;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.image,
                                        size: 48,
                                        color: Color.fromARGB(
                                            255, 206, 205, 205))),
                              ),
                            )
                          ],
                        )
                ],
              ),
            ))));
  }
}
