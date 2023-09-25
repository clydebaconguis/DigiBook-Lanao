import 'dart:convert';

import 'package:ict_ebook_hsa/app_util.dart';
import 'package:ict_ebook_hsa/components/copyright.dart';
import 'package:ict_ebook_hsa/data/drawer_items.dart';
import 'package:ict_ebook_hsa/models/drawer_item.dart';
import 'package:ict_ebook_hsa/pages/nav_main.dart';
import 'package:ict_ebook_hsa/pages/profile_page.dart';
import 'package:ict_ebook_hsa/provider/navigation_provider.dart';
import 'package:ict_ebook_hsa/signup_login/sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pdf_tile.dart';
import '../user/user.dart';
import '../user/user_data.dart';

class NavigationDrawerWidget extends StatefulWidget {
  const NavigationDrawerWidget({super.key});

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = const EdgeInsets.symmetric(horizontal: 20);
  late List<PdfTile> files = [];
  var user = UserData.myUser;
  String grade = '';
  String currentPage = '';

  @override
  void initState() {
    getUser();

    super.initState();
  }

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    grade = preferences.getString('grade')!;

    setState(() {
      user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    });
  }

  logout() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    await localStorage.clear();
    EasyLoading.showToast('Logged out successfully!',
        toastPosition: EasyLoadingToastPosition.bottom);
  }

  Future<void> showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.workSans(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog and do nothing (cancel logout)
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog and perform logout
                Navigator.of(context).pop();
                logout();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const SignIn(),
                    ),
                    (Route<dynamic> route) => false);
              },
              child: Text(
                'Logout',
                style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color theme = AppUtil().schoolSecondary();
    final safeArea =
        EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top);
    final provider = Provider.of<NavigationProvider>(context);
    var isCollapsed = provider.isCollapsed;
    currentPage = provider.currentPage;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      bool isWide = constraints.maxWidth > 1000;
      return SizedBox(
        width: isCollapsed && isWide && kIsWeb
            ? 100
            : isCollapsed &&
                    constraints.maxWidth < 1000 &&
                    constraints.maxWidth > 800 &&
                    kIsWeb
                ? MediaQuery.of(context).size.width * 0.1
                : isCollapsed && constraints.maxWidth <= 800 && kIsWeb
                    ? 80
                    : isCollapsed && !kIsWeb
                        ? MediaQuery.of(context).size.width * 0.2
                        : null,
        child: OrientationBuilder(builder: (context, orientation) {
          bool isLandscape = orientation == Orientation.landscape;

          return Drawer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme,
                    theme,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              // color: const Color(0xff292735),
              child: Stack(
                children: <Widget>[
                  ListView(
                    children: [
                      // if (constraints.maxWidth < 1000)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 0)
                            .add(safeArea),
                        width: double.infinity,
                        color: Colors.white12,
                        child: buildHeader(
                            isCollapsed, constraints.maxWidth >= 1000),
                      ),
                      buildProfileCircle(isCollapsed),
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey.shade700),
                      buildList(items: itemsFirst, isCollapsed: isCollapsed),
                      const SizedBox(height: 40),
                      if (isLandscape)
                        buildLogout(
                            items: itemsFirst2, isCollapsed: isCollapsed),
                      if (isLandscape)
                        Wrap(
                          children: [
                            if (!isCollapsed)
                              const Copyright(
                                labelColor: Colors.white,
                              ),
                            buildCollapseIcon(context, isCollapsed),
                          ],
                        ),
                    ],
                  ),
                  if (!isLandscape)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: Column(
                          children: [
                            buildLogout(
                                items: itemsFirst2, isCollapsed: isCollapsed),
                            Wrap(
                              children: [
                                if (!isCollapsed)
                                  const Copyright(
                                    labelColor: Colors.white,
                                  ),
                                buildCollapseIcon(context, isCollapsed),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  // Pdf Tile
  Widget buildTile({
    required bool isCollapsed,
    required List<PdfTile> items,
    int indexOffset = 0,
  }) =>
      ListView.separated(
        padding: isCollapsed ? EdgeInsets.zero : padding,
        shrinkWrap: true,
        primary: false,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = items[index];

          return buildMenuItemTiles(
            isCollapsed: isCollapsed,
            text: item.title,
            path: item.path,
            icon: Icons.picture_as_pdf_outlined,
            // items: item.lessons,
          );
        },
      );

  Widget buildMenuItemTiles({
    required bool isCollapsed,
    required String text,
    required String path,
    required IconData icon,
    // required List<PdfTile> items,
    VoidCallback? onClicked,
  }) {
    final color = Colors.pink.shade50;
    final leading = Icon(icon, color: color);

    return Material(
      color: Colors.transparent,
      child: isCollapsed
          ? ListTile(
              title: leading,
              // onTap: onClicked,
            )
          : ListTile(
              minLeadingWidth: 0,
              leading: leading,
              title: Text(
                text,
                style: TextStyle(color: color),
              ),
            ),
    );
  }

  // Main Nav tile
  Widget buildList({
    required bool isCollapsed,
    required List<DrawerItem> items,
    int indexOffset = 0,
  }) =>
      ListView.separated(
        padding: isCollapsed ? EdgeInsets.zero : padding,
        shrinkWrap: true,
        primary: false,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = items[index];

          return buildMenuItem(
            isCollapsed: isCollapsed,
            text: item.title,
            icon: item.icon,
            onClicked: () => selectItem(context, indexOffset + index),
          );
        },
      );

  void selectItem(BuildContext context, int index) {
    navigateTo(page) => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => page,
        ));

    Navigator.of(context).pop();

    switch (index) {
      case 0:
        if (currentPage != "Home") {
          navigateTo(const MyNav());
          final provider =
              Provider.of<NavigationProvider>(context, listen: false);
          setState(() {
            currentPage = "Home";
          });

          provider.setNewPage("Home");
        }
        break;
      case 1:
        navigateTo(const ProfilePage());
        break;
    }
  }

  Widget buildMenuItem({
    required bool isCollapsed,
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    const color = Colors.white;
    final leading = Icon(icon, color: color);

    return Material(
      color: Colors.transparent,
      child: isCollapsed
          ? ListTile(
              title: leading,
              onTap: onClicked,
            )
          : ListTile(
              leading: leading,
              title: Text(
                text,
                style: GoogleFonts.workSans(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: onClicked,
            ),
    );
  }

  Widget buildCollapseIcon(BuildContext context, bool isCollapsed) {
    const double size = 30;
    final icon = isCollapsed
        ? Icons.arrow_forward_ios_rounded
        : Icons.arrow_back_ios_rounded;
    final alignment = isCollapsed ? Alignment.center : Alignment.centerRight;
    // final margin = isCollapsed ? null : const EdgeInsets.only(right: 16);
    final width = isCollapsed ? double.infinity : size;

    return Container(
      alignment: alignment,
      // margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: SizedBox(
            width: width,
            height: size,
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          onTap: () {
            final provider =
                Provider.of<NavigationProvider>(context, listen: false);

            provider.toggleIsCollapsed();
          },
        ),
      ),
    );
  }

  Widget buildHeader(bool isCollapsed, bool iscons) => isCollapsed
      ? Container(
          padding: const EdgeInsets.only(bottom: 22, top: 0),
          child: !iscons
              ? const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    maxRadius: 28,
                    backgroundImage: AssetImage("img/mylogo.png"),
                  ),
                )
              : null,
        )
      : Container(
          padding: const EdgeInsets.only(bottom: 22, top: 0),
          child: Row(
            children: [
              const SizedBox(width: 24),
              if (!iscons)
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    maxRadius: 28,
                    backgroundImage: AssetImage("img/mylogo.png"),
                  ),
                ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppUtil().schoolAbbv(),
                    style: GoogleFonts.orbitron(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow.shade800,
                    ),
                  ),
                  Text(
                    'ICT E-BOOK',
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow.shade700,
                    ),
                  ),
                ],
              )
            ],
          ),
        );

  Widget buildLogout({
    required bool isCollapsed,
    required List<DrawerItem> items,
    int indexOffset = 0,
  }) =>
      ListView.separated(
        padding: isCollapsed ? EdgeInsets.zero : padding,
        shrinkWrap: true,
        primary: false,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = items[index];

          return buildMenuItem(
            isCollapsed: isCollapsed,
            text: item.title,
            icon: item.icon,
            onClicked: () {
              showLogoutConfirmationDialog(context);
            },
          );
        },
      );

  Widget buildProfileCircle(bool isCollapsed) => isCollapsed
      ? const Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFD5F6FF),
                  child: CircleAvatar(
                    backgroundColor: Color(0xFFD5F6FF),
                    backgroundImage: AssetImage("img/anonymous.jpg"),
                    radius: 28,
                  ),
                ),
                // Positioned(
                //   left: 1,
                //   bottom: -1,
                //   child: buildEditIcon(const Color(0xE70DDA11), 20, 1),
                // )
              ],
            ),
          ],
        )
      : Column(
          children: [
            const SizedBox(height: 24),
            const Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  // backgroundColor: Color(0xFFD5F6FF),
                  backgroundColor: Colors.grey,
                  child: CircleAvatar(
                    backgroundColor: Color(0xFFD5F6FF),
                    backgroundImage: AssetImage("img/anonymous.jpg"),
                    radius: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
              child: Text(
                user.name.toUpperCase(),
                style: GoogleFonts.orbitron(
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              grade.isNotEmpty ? grade : '',
              style: GoogleFonts.workSans(
                textStyle: TextStyle(
                  color: Colors.yellow.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            // Text(
            //   grade,
            //   style: const TextStyle(
            //       fontWeight: FontWeight.bold, color: Colors.greenAccent),
            // ),
          ],
        );

  Widget buildEditIcon(Color color, double size, double pad) => buildCircle(
      all: pad,
      child: Icon(
        Icons.safety_check,
        color: color,
        size: size,
      ));

  Widget buildCircle({
    required Widget child,
    required double all,
  }) =>
      ClipOval(
          child: Container(
        padding: EdgeInsets.all(all),
        // color: const Color(0xFFE91E63),
        child: child,
      ));
}
