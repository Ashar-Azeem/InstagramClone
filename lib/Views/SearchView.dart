import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/Views/SearchBar.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';

class SearchView extends StatefulWidget {
  final Users user;
  const SearchView({super.key, required this.user});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with AutomaticKeepAliveClientMixin {
  late Users user;
  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade900,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  // Remove tap effect
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchBarView(
                                user: user,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 17),
                        child: Text(
                          'Search',
                          style: TextStyle(
                              fontSize: 17, color: Colors.grey.shade400),
                        ))
                  ],
                )),
          )
        ],
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
