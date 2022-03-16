import 'login/login_page.dart';
import 'package:flutter/material.dart';
import 'home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Redditech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainRouter(),
    );
  }
}

class MainRouter extends StatefulWidget {
  const MainRouter({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MainRouter();
  }
}

class _MainRouter extends State<MainRouter> {
  int selectedIndex = 0;

  void switchRouter(int value) {
    setState(() {
      selectedIndex = value;
    });
    return;
  }

  Widget _login = Container();
  Widget _homePage = Container();

  _MainRouter() {
    _login = LoginPage(switchMainRouter: (int v) => {switchRouter(v)});
    _homePage = MyHomePage(switchMainRouter: (int v) => {switchRouter(v)});
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getBody() {
    if (selectedIndex == 0) {
      return _login;
    }
    return _homePage;
  }
}
