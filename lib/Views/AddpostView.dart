import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:mysocialmediaapp/utilities/state.dart';
import 'package:mysocialmediaapp/utilities/utilities.dart';
import 'package:sizer/sizer.dart';

class AddPostView extends StatefulWidget {
  final Users user;
  const AddPostView({super.key, required this.user});

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView>
    with AutomaticKeepAliveClientMixin {
  bool loading = false;
  late Users user;
  Uint8List? post;
  TextEditingController content = TextEditingController();
  bool itemSelected = false;

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Add Post"),
          shape: const Border(
            bottom: BorderSide(color: Colors.white, width: 1.0),
          ),
          actions: [
            itemSelected == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                itemSelected = false;
                              });
                            },
                            child: const Text("Remove",
                                style: TextStyle(color: Colors.white))),
                        TextButton(
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              String? content1 = content.text;
                              postProcess(post!, user, content1, context)
                                  .then((result) {
                                setState(() {
                                  loading = false;
                                });
                                if (result == 'success') {
                                  itemSelected = false;
                                  content.text = '';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Post Uploaded')));
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                    'Some Error Occured',
                                    style: TextStyle(color: Colors.red),
                                  )));
                                }
                              });
                            },
                            child: const Text("Post",
                                style: TextStyle(color: Colors.white))),
                      ])
                : const Text("")
          ],
        ),
        body: itemSelected == true
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    if (loading == true)
                      const LinearProgressIndicator(
                        color: blueColor,
                      ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Container(
                            height: 36.h,
                            width: 66.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              image: DecorationImage(
                                image: MemoryImage(post!),
                                fit: BoxFit.contain,
                              ),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 10,
                        right: 10,
                      ),
                      child: TextField(
                        controller: content,
                        cursorColor: Colors.white,
                        maxLines: 3,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(130),
                        ],
                        decoration: InputDecoration(
                            labelText: 'Enter your text',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            filled: true,
                            fillColor: Colors.black),
                        style: const TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              )
            : Center(
                child: IconButton(
                    onPressed: () async {
                      post = await imagepicker(ImageSource.gallery);
                      if (post != null) {
                        setState(() {
                          itemSelected = true;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.add_a_photo,
                      size: 50,
                      color: Colors.white,
                    )),
              ));
  }

  @override
  bool get wantKeepAlive => true;
}
