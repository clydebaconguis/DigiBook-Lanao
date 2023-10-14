import 'package:ict_ebook_hsa/app_util.dart';
import 'package:ict_ebook_hsa/pages/all_books.dart';
import 'package:ict_ebook_hsa/provider/navigation_provider.dart';
import 'package:ict_ebook_hsa/signup_login/sign_in.dart';
import 'package:ict_ebook_hsa/widget/navigation_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyNav extends StatelessWidget {
  const MyNav({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => NavigationProvider(),
        child: const NavMain(),
      );
}

class NavMain extends StatefulWidget {
  const NavMain({super.key});

  @override
  State<NavMain> createState() => _NavMainState();
}

class _NavMainState extends State<NavMain> {
  late int myschool;
  Color theme = AppUtil().schoolSecondary();

  @override
  void initState() {
    getUser();
    AppUtil().changeStatusBarColor(Colors.white);
    super.initState();
  }

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      myschool = preferences.getInt('myschool') ?? 0;
    });
    final json = preferences.getString('token');
    if (json == null || json.isEmpty) {
      redirectToSignIn();
    }
  }

  void redirectToSignIn() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const SignIn(0),
        ),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          bool isWide = constraints.maxWidth > 500;
          return Scaffold(
            drawer: const NavigationDrawerWidget(),
            appBar: AppBar(
              foregroundColor: Colors.black54,
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0.0,
              backgroundColor: Colors.white,
              toolbarHeight: constraints.maxWidth > 1000 ? 80 : 70,
              leadingWidth: constraints.maxWidth > 1000 ? 10 : null,
              leading:
                  constraints.maxWidth > 1000 ? const SizedBox.shrink() : null,
              titleSpacing: 0,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  // gradient: LinearGradient(
                  //   colors: [
                  //     theme,
                  //     theme,
                  //   ],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                ),
              ),
              // backgroundColor: const Color(0xff500a34),
              title: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        backgroundImage: myschool >= 0
                            ? AssetImage(AppUtil().schools[myschool].img)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    !isWide
                        ? Expanded(
                            child: Text(
                              AppUtil().schools[myschool].name,
                              style: GoogleFonts.orbitron(
                                textStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: true,
                            ),
                          )
                        : Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                AppUtil().schools[myschool].name,
                                style: GoogleFonts.orbitron(
                                  textStyle: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        constraints.maxWidth >= 1000 ? 30 : 18,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: true,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            body: Row(
              children: [
                if (constraints.maxWidth > 1500) const NavigationDrawerWidget(),
                const Expanded(child: AllBooks()),
              ],
            ),
          );
        }),
      );
}
