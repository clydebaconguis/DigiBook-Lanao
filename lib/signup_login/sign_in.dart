// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:ict_ebook_hsa/api/my_api.dart';
import 'package:ict_ebook_hsa/app_util.dart';
import 'package:ict_ebook_hsa/pages/nav_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:web_socket_channel/io.dart';

class SignIn extends StatefulWidget {
  final int index;
  const SignIn(this.index, {Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var selectedschool = 0;
  // var message = '';

  // final channel = IOWebSocketChannel.connect(
  //   Uri.parse('ws://192.168.0.192:6001/app/livepost_key'),
  // );

  // @override
  // void dispose() {
  //   super.dispose();
  //   channel.sink.close();
  // }

  // websocketCon() {
  //   channel.sink.add(json.encode({
  //     "event": "pusher:subscribe",
  //     "data": {"channel": "Public.message"}
  //   }));

  //   channel.stream.listen((data) {
  //     Map<String, dynamic> messageData = jsonDecode(data);

  //     if (messageData.containsKey("data")) {
  //       Map<String, dynamic> data = jsonDecode(messageData["data"]);
  //       if (data.containsKey("message")) {
  //         setState(() {
  //           message = data["message"];
  //         });
  //         // Now you have the message, and you can use it in your Flutter app.
  //         print("Received Message: $message");
  //       }
  //     }
  //   }, onError: (error) {
  //     print("Socket: error => $error");
  //   }, onDone: () {
  //     print("Socket: done");
  //   });
  // }

  @override
  void initState() {
    selectedschool = widget.index;
    AppUtil().changeStatusBarColor(Colors.black);
    super.initState();
    // websocketCon();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return SafeArea(
      child: Scaffold(
        body: OrientationBuilder(builder: (context, orientation) {
          bool isLandscape = orientation == Orientation.landscape;
          return SingleChildScrollView(
            child: isSmallScreen
                ? Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                          Colors.black
                              .withOpacity(0.5), // Color to apply as a filter
                          BlendMode.srcATop, // Blend mode
                        ),
                        image: const AssetImage('img/mycover.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: ListView(
                      children: [
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: CustomSearchableDropDown(
                            dropdownHintText: 'Search For School Here... ',
                            showLabelInMenu: true,
                            primaryColor: Colors.red,
                            menuMode: true,
                            labelStyle: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                            items: AppUtil().schools,
                            label: 'Select School',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Icon(Icons.search),
                            ),
                            dropDownMenuItems: AppUtil().schools.map((item) {
                              return item.name;
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedschool = AppUtil().schools.indexWhere(
                                    (item) => item.name == value.name);
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        _Logo(selectedschool),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isLandscape
                                ? Colors.grey.shade800
                                : Colors.white10,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Login',
                                  style: GoogleFonts.workSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                              const SizedBox(height: 5),
                              _FormContent(selectedschool),
                              const SizedBox(height: 40),
                              GestureDetector(
                                onTap: () => EasyLoading.showInfo(
                                    'Please notify your teacher or advisor if you\'ve forgotten your password.'),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.workSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                          Colors.black
                              .withOpacity(0.5), // Color to apply as a filter
                          BlendMode.srcATop, // Blend mode
                        ),
                        image: const AssetImage('img/mycover.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    padding: const EdgeInsets.all(32.0),
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: CustomSearchableDropDown(
                            dropdownHintText: 'Search For School Here... ',
                            showLabelInMenu: true,
                            primaryColor: Colors.red,
                            menuMode: true,
                            labelStyle: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                            items: AppUtil().schools,
                            label: 'Select School',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Icon(Icons.search),
                            ),
                            dropDownMenuItems: AppUtil().schools.map((item) {
                              return item.name;
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedschool = AppUtil().schools.indexWhere(
                                    (item) => item.name == value.name);
                              });
                            },
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _Logo(selectedschool),
                            ),
                            Expanded(
                              child: Center(
                                child: _FormContent(selectedschool),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          );
        }),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final int pos;
  const _Logo(this.pos, {Key? key}) : super(key: key);

  Widget _title() {
    return Column(
      children: [
        Text(
          AppUtil().schools[pos].name,
          style: GoogleFonts.workSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          AppUtil().schools[pos].address,
          style: GoogleFonts.workSans(
            fontSize: 14,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // FlutterLogo(size: isSmallScreen ? 100 : 200),
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.grey.shade400,
          child: CircleAvatar(
            radius: isSmallScreen ? 50 : 90,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(AppUtil().schools[pos].img),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
            padding: isSmallScreen
                ? const EdgeInsets.all(10.0)
                : const EdgeInsets.all(0.0),
            child: _title())
      ],
    );
  }
}

class _FormContent extends StatefulWidget {
  final int pos;
  const _FormContent(this.pos, {Key? key}) : super(key: key);

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {
  bool isPasswordVisible = false;
  bool isButtonEnabled = true;
  var body = {};
  var expiration = '';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // final channel = IOWebSocketChannel.connect(
  //   Uri.parse('ws://192.168.0.192:6001/app/livepost_key'),
  // );

  deleteExpiredBooks() async {
    List<FileSystemEntity> result = await AppUtil().readBooks();
    if (result.isNotEmpty) {
      for (var item in result) {
        final directory = Directory(item.path);
        directory.deleteSync(recursive: true);
        // print("Deleted directory: ${directory.path}");
      }
    }
  }

  _navigateToBooks() {
    if (mounted) {
      EasyLoading.showSuccess('Successfully loggedin!');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MyNav(),
          ),
          (Route<dynamic> route) => false);
    }
  }

  _login() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    EasyLoading.show(status: 'loading...');
    var data = {
      'email': emailController.text,
      'password': passwordController.text,
    };

    try {
      var res = await CallApi().login(
        data,
        'api/studentlogin',
        AppUtil().schools[widget.pos].domain,
      );
      if (res != null) {
        if (mounted) {
          setState(() {
            body = json.decode(res.body);
            expiration = body['expiry'] ?? '';
            // print(body);
            // print(expiration);
          });
        }
      }
      if (body['success'] && expiration.isNotEmpty) {
        final now = DateTime.now();
        final expDate = DateTime.parse(expiration);
        if (now.isAfter(expDate) || now.isAtSameMomentAs(expDate)) {
          EasyLoading.showInfo('Subscription Expired!');
          deleteExpiredBooks();
        } else {
          localStorage.setString('token', body['user']['name'] ?? 'Not Set');
          localStorage.setString('grade', body['grade'] ?? 'Not Set');
          localStorage.setString('user', json.encode(body['user']));
          localStorage.setString('expiry', expiration);
          localStorage.setInt('myschool', widget.pos);
          _navigateToBooks();
        }
      } else {
        EasyLoading.showError('Failed to Login');
        if (mounted) {
          setState(() {
            isButtonEnabled = true;
          });
        }
      }
    } catch (e) {
      // print('Error during login: $e');
      EasyLoading.showError('An error occurred during login $e');
      if (mounted) {
        setState(() {
          isButtonEnabled = true;
        });
      }
    } finally {
      EasyLoading.dismiss();
      if (mounted) {
        setState(() {
          isButtonEnabled = true;
        });
      }
    }
    if (mounted) {
      setState(() {
        isButtonEnabled = true;
      });
    }
  }

  // websocketCon() {
  //   channel.sink.add(json.encode({
  //     "event": "pusher:subscribe",
  //     "data": {"channel": "Public.message"}
  //   }));

  //   AppUtil().changeStatusBarColor(Colors.black);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            style: GoogleFonts.workSans(color: Colors.white),
            controller: emailController,
            validator: (value) {
              // add email validation
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }

              bool emailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(value);
              if (!emailValid) {
                return 'Please enter a valid email';
              }

              return null;
            },
            decoration: InputDecoration(
              hintStyle: const TextStyle(color: Colors.white),
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              labelText: 'Username',
              labelStyle: const TextStyle(color: Colors.white),
              hintText: 'Enter your email',
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Colors.white70,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 2.0,
                  color: Colors.white70, // Change the border color here
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 2.0,
                  color: Colors.blue, // Change the border color when focused
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          _gap(),
          TextFormField(
            style: GoogleFonts.workSans(color: Colors.white),
            controller: passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }

              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
                hintStyle: const TextStyle(color: Colors.white),
                labelStyle: const TextStyle(color: Colors.white),
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white70,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 2.0,
                    color: Colors.white70, // Change the border color here
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 2.0,
                    color: Colors.blue, // Change the border color when focused
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                )),
          ),
          _gap(),
          // CheckboxListTile(
          //   value: _rememberMe,
          //   onChanged: (value) {
          //     if (value == null) return;
          //     setState(() {
          //       _rememberMe = value;
          //     });
          //   },
          //   title: const Text('Remember me'),
          //   controlAffinity: ListTileControlAffinity.leading,
          //   dense: true,
          //   contentPadding: const EdgeInsets.all(0),
          // ),
          _gap(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.white,
                elevation: 10.0,
                backgroundColor: isButtonEnabled
                    ? AppUtil().schools[widget.pos].primary
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              onPressed: isButtonEnabled
                  ? () {
                      // websocketCon();

                      if (emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        EasyLoading.showToast(
                          'Fill all fields!',
                          toastPosition: EasyLoadingToastPosition.bottom,
                        );
                      } else {
                        setState(() {
                          isButtonEnabled = false;
                        });
                        _login();
                      }
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Sign in',
                  style: GoogleFonts.workSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
