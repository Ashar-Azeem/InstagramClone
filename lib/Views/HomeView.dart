import 'package:flutter/material.dart';
import 'package:mysocialmediaapp/services/CRUD.dart';

class HomeView extends StatefulWidget {
  final Users user;
  const HomeView({super.key, required this.user});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
