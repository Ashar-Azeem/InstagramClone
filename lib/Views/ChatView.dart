import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';
import 'package:sizer/sizer.dart';

class ChatView extends StatefulWidget {
  final Chats chat;

  const ChatView({super.key, required this.chat});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  int maxLines = 1;
  bool loading = false;
  late Chats chat;
  int userNumber = 1;
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    chat = widget.chat;

    if (chat.user1UserId != FirebaseAuth.instance.currentUser!.uid) {
      userNumber = 2;
      var temp = chat.user1Name;
      chat.user1Name = chat.user2Name;
      chat.user2Name = temp;

      var temp1 = chat.user1UserName;
      chat.user1UserName = chat.user2UserName;
      chat.user2UserName = temp1;

      var temp2 = chat.user1UserId;
      chat.user1UserId = chat.user2UserId;
      chat.user2UserId = temp2;

      var temp3 = chat.user1ProfileLoc;
      chat.user1ProfileLoc = chat.user2ProfileLoc;
      chat.user2ProfileLoc = temp3;
    }
    controller.addListener(_updateMaxLines);
  }

  void _updateMaxLines() {
    final lines = '\n'.allMatches(controller.text).length + 1;
    if (lines > maxLines && lines <= 3) {
      setState(() {
        maxLines = lines;
      });
    } else if (lines < maxLines && lines > 0) {
      setState(() {
        maxLines = lines;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          forceMaterialTransparency: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: chat.user2ProfileLoc == null
                    ? const AssetImage('assets/blankprofile.png')
                        as ImageProvider
                    : NetworkImage(chat.user2ProfileLoc!),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: SizedBox(
                  width: 50.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.user2Name,
                        softWrap: true,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(chat.user2UserName,
                          softWrap: true,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Color.fromARGB(255, 220, 209, 209)))
                    ],
                  ),
                ),
              )
            ],
          )),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: ListView(
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 4.w),
                  child: chat.chatId == null
                      ? const Center(
                          child: Text("No Messages"),
                        )
                      : FirestorePagination(
                          isLive: true,
                          shrinkWrap: true,
                          viewType: ViewType.list,
                          onEmpty: const Text('No Posts Available'),
                          initialLoader: const SizedBox.shrink(),
                          bottomLoader: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          limit: 12,
                          query: FirebaseFirestore.instance
                              .collection('messeges')
                              .where('chatId', isEqualTo: chat.chatId)
                              .orderBy('time', descending: false),
                          itemBuilder: (context, snapshot, index) {
                            var message = getMyObject(snapshot);
                            return Row(
                              children: [Text(message.content)],
                            );
                          },
                        ))
            ],
          )),
          Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.w),
                      color: const Color.fromARGB(255, 36, 38, 44)),
                  alignment: Alignment.center,
                  width: 96.w,
                  height: maxLines * 6.3.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 1.w),
                        child: ValueListenableBuilder(
                            valueListenable: ProfilePicture(),
                            builder: (context, value, child) {
                              chat.user1ProfileLoc = value;
                              return value == null
                                  ? CircleAvatar(
                                      backgroundColor: Colors.black,
                                      radius: 2.8.h,
                                      backgroundImage: const AssetImage(
                                          'assets/blankprofile.png'),
                                    )
                                  : CircleAvatar(
                                      radius: 2.8.h,
                                      backgroundColor: Colors.black,
                                      backgroundImage: NetworkImage(value),
                                    );
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 3.w, right: 0),
                        child: SizedBox(
                          width: 62.w,
                          child: TextField(
                            maxLines: null,
                            expands: false,
                            minLines: 1,
                            cursorColor: Colors.white,
                            style:
                                const TextStyle(fontWeight: FontWeight.normal),
                            controller: controller,
                            autocorrect: false,
                            enableSuggestions: true,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Message...'),
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            var text = controller.text;

                            if (text.isNotEmpty) {
                              setState(() {
                                loading = true;
                              });

                              DataBase()
                                  .sendMessage(
                                      chat, userNumber, controller.text)
                                  .then((value) {
                                if (value) {
                                  controller.text = '';
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                    "Some thing happened!",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  )));
                                }
                                setState(() {
                                  loading = false;
                                });
                              });
                            }
                          },
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Text(
                                  'Send',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor),
                                ))
                    ],
                  ),
                ),
              ))
        ],
      )),
      resizeToAvoidBottomInset: true,
    );
  }
}

Messages getMyObject(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  String chatId = data['chatId'] as String;
  String senderUserId = data['senderUserId'] as String;
  String receicerUserId = data['receiverId'] as String;
  String content = data['message'] as String;
  Timestamp time = data['time'] as Timestamp;

  DateTime timeDart = time.toDate();

  return Messages(
      chatId: chatId,
      senderUserId: senderUserId,
      receicerUserId: receicerUserId,
      content: content,
      time: timeDart);
}
