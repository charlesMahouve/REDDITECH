import 'dart:async';

import 'home/home.dart';
import 'my_profile/my_profile.dart';
import 'search/search.dart';
import 'package:flutter/material.dart';

typedef MainRouter = void Function(int value);

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.switchMainRouter})
      : super(key: key);

  final MainRouter switchMainRouter;

  @override
  State<StatefulWidget> createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  final Widget _home = const Home();
  final Widget _myProfile = const MyProfile();
  final Widget _search = const Search();
  static const timeout = Duration(seconds: 3);
  static const ms = Duration(milliseconds: 1);

  Timer startTimeout([int? milliseconds]) {
    var duration = milliseconds == null
        ? timeout
        : ms * milliseconds; //TODO faire le refresh de token
    return Timer(duration, handleTimeout);
  }

  void handleTimeout() {
    // callback function
    debugPrint("hello cela fait 3 seconds");
  }

  String getNameApp() {
    if (selectedIndex == 0) {
      return "Redditech";
    } else if (selectedIndex == 1) {
      return 'Search subreddit';
    } else {
      return "Profile";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: Text(
            getNameApp(),
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              ),
              tooltip: 'Disconnect',
              onPressed: () {
                widget.switchMainRouter(0);
              },
            )
          ]),
      body: getBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black54,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon((selectedIndex == 0 ? Icons.home : Icons.home_outlined),
                color: Colors.white),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon((selectedIndex == 1 ? Icons.saved_search : Icons.search),
                color: Colors.white),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(
                (selectedIndex == 2 ? Icons.person : Icons.person_outline),
                color: Colors.white),
            label: "Profile",
          )
        ],
        onTap: (int index) {
          onTapHandler(index);
        },
      ),
    );
  }

  Widget getBody() {
    if (selectedIndex == 0) {
      return _home;
    } else if (selectedIndex == 1) {
      return _search;
    } else {
      return _myProfile;
    }
  }

  void onTapHandler(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
