import 'dart:io';

import 'package:ict_ebook_hsa/app_util.dart';
import 'package:ict_ebook_hsa/pages/nav_main.dart';
import 'package:ict_ebook_hsa/signup_login/sign_in.dart';
import 'package:ict_ebook_hsa/welcome/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late bool loggedIn = false;
  late bool expired = false;

  checkLoginStatus() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token != null) {
      setState(() {
        loggedIn = true;
      });
    }
  }

  checkExpiration() async {
    List<FileSystemEntity> result = await AppUtil().readBooks();
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var exp = localStorage.getString('expiry');
    // var expiration = '2023-08-09';
    if (exp != null) {
      final expDate = DateTime.parse(exp);
      final now = DateTime.now();
      if (now.isAfter(expDate) || now.isAtSameMomentAs(expDate)) {
        EasyLoading.showInfo('Subscription Expired!');
        if (result.isNotEmpty) {
          for (var item in result) {
            final directory = Directory(item.path);
            directory.deleteSync(recursive: true);
            // print("Deleted directory: ${directory.path}");
          }
        } else {
          // print("No books found.");
        }
        logout();
        if (mounted) {
          setState(() {
            expired = true;
          });
        }
      }
    } else {
      checkLoginStatus();
    }
  }

  logout() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    await localStorage.clear();
  }

  @override
  void initState() {
    configLoading();
    checkExpiration();
    AppUtil().changeStatusBarColor(Colors.white);
    super.initState();
  }

  void configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCube
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.green
      ..backgroundColor = Colors.transparent
      ..indicatorColor = Colors.green
      ..textColor = Colors.green
      ..maskColor = Colors.white
      ..userInteractions = true
      ..dismissOnTap = false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts
            .workSansTextTheme(), // Apply Poppins font to the entire app
      ),
      debugShowCheckedModeBanner: false,
      title: '',
      home: AnimatedSplashScreen(
        splashIconSize: 100,
        duration: 2000,
        centered: true,
        splash: 'img/CK_logo.png',
        nextScreen: expired
            ? const SignIn(0)
            : loggedIn
                ? const MyNav()
                : const Welcome(),
        splashTransition: SplashTransition.fadeTransition,
        pageTransitionType: PageTransitionType.topToBottom,
        backgroundColor: Colors.white,
      ),
      builder: EasyLoading.init(),
    );
  }
}
