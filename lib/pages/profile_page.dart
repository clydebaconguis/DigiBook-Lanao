import 'dart:convert';

import 'package:ict_ebook_hsa/app_util.dart';
import 'package:ict_ebook_hsa/pages/nav_main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user/user.dart';
import '../user/user_data.dart';

// This class handles the Page to dispaly the user's info on the "Edit Profile" Screen
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var user = UserData.myUser;
  Color theme = AppUtil().schoolSecondary();
  String grade = '';
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

  @override
  Widget build(BuildContext context) {
    // final double height = MediaQuery.of(context).size.height;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MyNav(),
                    ),
                    (Route<dynamic> route) => false);
              },
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    "Profile",
                    style: GoogleFonts.orbitron(
                      textStyle: TextStyle(
                        color: Colors.yellow.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: true,
                  ),
                ),
              ],
            ),
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
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Card(
                            margin: const EdgeInsets.all(12),
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    offset: const Offset(0.0, 0.0),
                                    blurRadius: 18.0,
                                    spreadRadius: 4.0,
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const CircleAvatar(
                                      backgroundColor:
                                          Color.fromARGB(255, 140, 228, 243),
                                      radius: 60.0,
                                      backgroundImage: AssetImage(
                                        'img/anonymous.jpg', // Replace with the actual profile picture URL
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    Text(
                                      user.name,
                                      style: GoogleFonts.workSans(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 25.0),
                                    buildProfileItem(
                                        Icons.phone,
                                        'Phone',
                                        user.mobilenum.isNotEmpty
                                            ? user.mobilenum
                                            : 'Not Specified'),
                                    const Divider(),
                                    buildProfileItem(
                                        Icons.school,
                                        'Grade Level',
                                        grade.isNotEmpty
                                            ? grade
                                            : 'Not Specified'),
                                    const Divider(),
                                    buildProfileItem(
                                        Icons.email,
                                        'Email',
                                        user.email.isNotEmpty
                                            ? user.email
                                            : 'Not Specified'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildProfileItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 8.0),
        Text(
          '$label:',
          style: GoogleFonts.workSans(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.workSans(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
