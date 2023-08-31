import 'package:ict_ebook_hsa/pages/nav_main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_app_backend/pages/article_page.dart';
import 'package:ict_ebook_hsa/signup_login/sign_in.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLoggedIn = false;

  @override
  void initState() {
    _checkLoginStatus();
    super.initState();
  }

  changeStatusBarColor(Color color) async {
    if (!kIsWeb) {
      await FlutterStatusbarcolor.setStatusBarColor(color);
      if (useWhiteForeground(color)) {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
      } else {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
      }
    }
  }

  _checkLoginStatus() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token') ?? '';
    if (token.isNotEmpty) {
      setState(() {
        isLoggedIn = true;
      });
    }
    isLoggedIn ? navigateToMainNav() : {};
  }

  navigateToMainNav() {
    changeStatusBarColor(const Color.fromRGBO(141, 31, 31, 1));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MyNav(),
        ),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: (isLoggedIn ? const MyNav() : const SignIn()),
      ),
    );
  }
}
