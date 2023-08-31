import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:ict_ebook_hsa/splash_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  changeStatusBarColor();

  runApp(const Splash());
}

changeStatusBarColor() async {
  if (!kIsWeb) {
    await FlutterStatusbarcolor.setStatusBarColor(
      const Color.fromRGBO(141, 31, 31, 1),
    );
    if (useWhiteForeground(
      const Color.fromRGBO(141, 31, 31, 1),
    )) {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    } else {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    }
  }
}

// deleteExpiredBooks() async {
//   var result = await AppUtil().readBooks();
//   result.forEach((item) {
//     final directory = Directory(item.path);
//     final now = DateTime.now();
//     print(now);
//     final lastModified = File(directory.path).statSync().modified;
//     final difference = now.difference(lastModified);
//     if (difference.inDays >= 365) {
//       directory.deleteSync(recursive: true);
//     }
//   });
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("ebook");
  }
}
