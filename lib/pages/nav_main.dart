import 'package:ict_ebook_hsa/app_util.dart';
import 'package:ict_ebook_hsa/pages/all_books.dart';
import 'package:ict_ebook_hsa/provider/navigation_provider.dart';
import 'package:ict_ebook_hsa/signup_login/sign_in.dart';
import 'package:ict_ebook_hsa/widget/navigation_drawer_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
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
  Color theme = AppUtil().schoolColor();

  @override
  void initState() {
    getUser();
    changeStatusBarColor(AppUtil().schoolColor());
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

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('token');
    if (json == null || json.isEmpty) {
      redirectToSignIn();
    }
  }

  void redirectToSignIn() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const SignIn(),
        ),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        bool isWide = constraints.maxWidth > 500;

        return Scaffold(
          drawer: const NavigationDrawerWidget(),
          appBar: AppBar(
            toolbarHeight: constraints.maxWidth > 1000 ? 80 : 70,
            elevation: 0,
            leadingWidth: constraints.maxWidth > 1000 ? 10 : null,
            leading:
                constraints.maxWidth > 1000 ? const SizedBox.shrink() : null,
            titleSpacing: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme,
                    theme,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // backgroundColor: const Color(0xff500a34),
            title: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage("img/HSA.png"),
                ),
                const SizedBox(width: 5.0),
                !isWide
                    ? Expanded(
                        child: Text(
                          "Holy Spirit Academy",
                          style: GoogleFonts.prompt(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: true,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "Holy Spirit Academy",
                          style: GoogleFonts.prompt(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: constraints.maxWidth >= 1000 ? 30 : 18,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: true,
                        ),
                      ),
              ],
            ),
          ),
          body: Row(
            children: [
              if (constraints.maxWidth > 1500) const NavigationDrawerWidget(),
              const Expanded(child: AllBooks()),
            ],
          ),
        );
      });
}
