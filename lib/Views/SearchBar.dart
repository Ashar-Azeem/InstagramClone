import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/Views/visitingProfileView.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';

class SearchBarView extends StatefulWidget {
  final Users user;
  const SearchBarView({super.key, required this.user});

  @override
  State<SearchBarView> createState() => _SearchBarViewState();
}

class _SearchBarViewState extends State<SearchBarView> {
  late Users user;
  String prevText = '';
  DataBase db = DataBase();
  TextEditingController text = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  void deadFunction() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Container(
                width: MediaQuery.of(context).size.width - 70,
                height: 38,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade900),
                child: TextField(
                  onChanged: (value) async {
                    if (prevText.length < text.text.length) {
                      await db.sendRetreivedUsers(text.text);
                    } else if (text.text.isEmpty) {
                      await db.sendRetreivedUsers(text.text);
                    }

                    prevText = text.text;
                  },
                  cursorColor: Colors.white,
                  enableSuggestions: false,
                  autocorrect: false,
                  controller: text,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      prefixIcon: Icon(Icons.search)),
                ),
              ),
            ),
          ],
        ),
        body: StreamBuilder(
            stream: db.usersStream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  {
                    if (snapshot.hasData) {
                      final users = snapshot.data as List<Users>;
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            String? ImageLoc = users[index].imageLoc;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 10, top: 20),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            VisitingProfileView(
                                              user: users[index],
                                              ownerUser: user,
                                              rebuilt: null,
                                            )),
                                  );
                                },
                                child: SizedBox(
                                  height: 70,
                                  width: MediaQuery.of(context).size.width - 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ImageLoc == null
                                          ? const CircleAvatar(
                                              radius: 33,
                                              backgroundColor: Color.fromARGB(
                                                  255, 38, 38, 38),
                                              backgroundImage: AssetImage(
                                                  'assets/blankprofile.png'),
                                            )
                                          : CircleAvatar(
                                              radius: 33,
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 38, 38, 38),
                                              backgroundImage:
                                                  NetworkImage(ImageLoc),
                                            ),
                                      const SizedBox(
                                        width: 17,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              users[index].userName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14),
                                            ),
                                            Text(
                                              users[index].name,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      return const Text("");
                    }
                  }

                default:
                  {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }
              }
            }));
  }
}
