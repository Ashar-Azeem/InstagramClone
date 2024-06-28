// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';
import 'package:mysocialmediaapp/utilities/color.dart';

class HomeView extends StatefulWidget {
  final Users user;
  const HomeView({super.key, required this.user});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Users user;
  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    'assets/logo.svg',
                    color: primaryColor,
                    height: 36,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/messageIcon.png',
                      height: 30,
                    ),
                  )
                ],
              ),
            ),
            FutureBuilder(
              future: DataBase().getStories(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    {
                      var data = snapshot.data as List<String>;
                      return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 6,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        InkWell(
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.all(3.5),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  10,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    //Change the color of unseen stories
                                                    color: const Color.fromARGB(
                                                        255, 61, 61, 65),
                                                    width: 3,
                                                  )),
                                              child: const CircleAvatar(
                                                backgroundColor: Colors.orange,
                                                radius: 20,
                                              )),
                                        ),
                                        Text(data[index])
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ));
                    }
                  default:
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    );
                }
              },
            )
          ],
        ),
      )),
    );
  }
}
