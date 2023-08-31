import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:ict_ebook_hsa/app_util.dart';
import 'package:ict_ebook_hsa/models/pdf_tile.dart';
import 'package:ict_ebook_hsa/pages/nav_pdf.dart';
import 'package:ict_ebook_hsa/signup_login/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ict_ebook_hsa/api/my_api.dart';
import 'package:ict_ebook_hsa/models/get_books_info_02.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailBookPage extends StatefulWidget {
  final Books2 bookInfo;
  final int index;
  const DetailBookPage({Key? key, required this.bookInfo, required this.index})
      : super(key: key);

  @override
  State<DetailBookPage> createState() => _DetailBookPageState();
}

class _DetailBookPageState extends State<DetailBookPage> {
  Color theme = AppUtil().schoolColor();
  String mainHost = CallApi().getHost();
  double _diskSpace = 0;
  bool lowStorage = false;
  var parts = [];
  var chapters = [];
  var lessons = [];
  var bookCoverUrl = '';
  bool isButtonEnabled = true;
  bool isButtonEnabled2 = true;
  var lessonLength = 0;
  var existBook = false;
  List<Future<void>> futures = [];
  List<PdfDownloadInfo> pdfDownloadList = [];
  Directory appDir = Directory('');
  double downloadProgress = 0.0;
  String pdfTitle = '';
  bool downloadEnabled = false;
  bool finished = false;

  checkIfBookExist() async {
    if (mounted) {
      existBook = await fileExist(widget.bookInfo.title);
    }
  }

  Future<void> initDiskSpacePlus() async {
    double diskSpace = 0;

    diskSpace = await DiskSpacePlus.getFreeDiskSpace ?? 0;

    setState(() {
      _diskSpace = diskSpace;
      if (_diskSpace < 1000.00) {
        setState(() {
          lowStorage = true;
        });
      } else {
        lowStorage = false;
      }
    });
  }

  @override
  void initState() {
    getToken();
    initDiskSpacePlus();
    _fetchParts();
    checkIfBookExist();
    super.initState();
  }

  getToken() async {
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

  Future<bool> fileExist(String folderName) async {
    final Directory appDir = await getApplicationSupportDirectory();
    // const folderName = 'SampleBook';
    final Directory appDirFolder = Directory("${appDir.path}/$folderName/");
    if (await appDirFolder.exists()) {
      // File imageFile = File("$appDir/${widget.bookInfo.title}/cover_image");
      // if (await imageFile.exists()) {
      //   setState(() {
      //     imgPathLocal = imageFile.path;
      //   });
      // }
      //if folder already exists return path
      return true;
    } else {
      //if folder not exists create folder and then return its path
      return false;
    }
  }

  downloadImage(String foldr, String filename, String imgUrl) async {
    String host = "$mainHost$imgUrl";
    var savePath = '$foldr$filename';
    // print(savePath);
    var dio = Dio();
    dio.interceptors.add(LogInterceptor());
    try {
      var response = await dio.get(
        host,
        //Received data with List<int>
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      var file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
      // print("image dowloaded successfully");
    } catch (e) {
      debugPrint(e.toString());
      // print("image failed to download");
    }
  }

  _fetchParts() async {
    appDir = await getApplicationSupportDirectory();
    CallApi().getPublicData('bookchapter2/${widget.bookInfo.bookid}').then(
      (response) {
        if (mounted) {
          setState(
            () {
              var results = json.decode(response.body);
              // print(results);
              parts = results['parts'] ?? [];
              // print(parts);
              chapters = results['chapters'] ?? [];
              // print(chapters);
              lessons = results['lessons'] ?? [];
              bookCoverUrl = results['bookcover'] ?? '';
              // print(bookCoverUrl);
              // print(lessons);
              lessonLength = lessons.length;
              // print(lessonLength);
            },
          );
        }
      },
    );
  }

  String getFileExtension(String url) {
    // Find the last occurrence of the dot (.)
    int dotIndex = url.lastIndexOf('.');

    // If a dot is found and it's not the last character of the URL, return the extension
    if (dotIndex != -1 && dotIndex < url.length - 1) {
      String extension = url.substring(dotIndex);
      return extension;
    }

    // If no dot is found or it's the last character, return an empty string as the extension
    return '';
  }

  // Start downloading all PDF
  Future<void> _downloadPdf() async {
    setState(() {
      downloadEnabled = true;
    });
    Directory bookNewFolder = Directory('');
    try {
      final Directory appDirFolder =
          Directory("${appDir.path}/${widget.bookInfo.title}/");
      bookNewFolder = await appDirFolder.create(recursive: true);
      downloadImage(bookNewFolder.path, "cover_image", bookCoverUrl);

      if (parts.isNotEmpty) {
        for (var part in parts) {
          final Directory partDirFolder =
              Directory("${bookNewFolder.path}${part['title']}/");
          final Directory newPart = await partDirFolder.create(recursive: true);
          if (chapters.isNotEmpty) {
            for (var chapter in chapters) {
              if (chapter['partid'] != null &&
                  chapter['partid'] == part['id']) {
                final Directory chapDirFolder =
                    Directory("${newPart.path}${chapter['title']}/");
                final Directory newChap =
                    await chapDirFolder.create(recursive: true);
                if (lessons.isNotEmpty) {
                  for (var lesson in lessons) {
                    if (lesson['chapterid'] != null &&
                        lesson['chapterid'] == chapter['id']) {
                      if (lesson['path'] != null && lesson['path'].isNotEmpty) {
                        for (var lessonFileItem in lesson['path']) {
                          if (getFileExtension(lessonFileItem['filepath'])
                                  .toLowerCase() ==
                              '.pdf') {
                            pdfDownloadList.add(
                              PdfDownloadInfo(
                                  '$mainHost${lessonFileItem['filepath']}',
                                  '${newChap.path}${lessonFileItem['content']}',
                                  '${lessonFileItem['content']}'),
                            );
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        if (chapters.isNotEmpty) {
          for (var chapter in chapters) {
            final Directory chapDirFolder =
                Directory("${bookNewFolder.path}${chapter['title']}/");
            final Directory newChap =
                await chapDirFolder.create(recursive: true);
            if (lessons.isNotEmpty) {
              for (var lesson in lessons) {
                if (lesson['chapterid'] != null &&
                    lesson['chapterid'] == chapter['id']) {
                  if (lesson['path'] != null && lesson['path'].isNotEmpty) {
                    for (var lessonFileItem in lesson['path']) {
                      if (getFileExtension(lessonFileItem['filepath'])
                              .toLowerCase() ==
                          '.pdf') {
                        pdfDownloadList.add(
                          PdfDownloadInfo(
                              '$mainHost${lessonFileItem['filepath']}',
                              '${newChap.path}${lessonFileItem['content']}',
                              '${lessonFileItem['content']}'),
                        );
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      EasyLoading.showError('Error occurred: $e');
    }
    final List<Future<void>> downloadFutures = [];
    // loop all pdf in pdfdownloadlist
    for (final pdfInfo in pdfDownloadList) {
      final downloadFuture = downloadPdfFiles(pdfInfo);
      downloadFutures.add(downloadFuture);
    }

    await Future.wait(downloadFutures);
    // all download is finish.
    if (mounted) {
      setState(() {
        finished = true;
      });
    }
    saveCurrentBook(widget.bookInfo.title);
    navigateToMainNav("${bookNewFolder.path}cover_image");
  }

  navigateToMainNav(String path) {
    EasyLoading.dismiss();
    if (mounted) {
      setState(() {
        existBook = true;
        isButtonEnabled2 = true;
        isButtonEnabled = true;
      });
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NavPdf(
          books: PdfTile(
            title: widget.bookInfo.title,
            path: path,
            isExpanded: false,
          ),
          path: '',
        ),
      ),
    );
  }

  Future<void> saveCurrentBook(bookName) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setString('currentBook', bookName);
  }

  // Function to download each pdf.
  Future<void> downloadPdfFiles(PdfDownloadInfo pdfInfo) async {
    try {
      final Dio dio = Dio();
      dio.interceptors.add(LogInterceptor());
      final savePath = pdfInfo.savePath;
      final response = await dio.get(
        pdfInfo.pdfUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              if (pdfTitle != pdfInfo.title) {
                pdfTitle = pdfInfo.title;
              }
              downloadProgress = received / total;
            });
          }
        },
      );

      final file = File(savePath);
      await file.writeAsBytes(response.data);

      setState(() {
        downloadProgress = 1.0; // Set progress to 100% after download
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> showDonwloadConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Download ${widget.bookInfo.title}?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Don\'t interrupt while book is being downloaded.',
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog and do nothing (cancel logout)
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  setState(() {
                    isButtonEnabled = false;
                  });
                }
                _downloadPdf();
              },
              child: Text(
                'Download',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showClearConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Remove ${widget.bookInfo.title}?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This will remove the book and its associated lessons from your phone.',
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog and do nothing (cancel logout)
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  setState(() {
                    isButtonEnabled2 = false;
                  });
                }
                // _downloadPdf();
                deleteSpecificFolder();
              },
              child: Text(
                'Confirm',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteSpecificFolder() async {
    try {
      // Get the application support directory
      Directory appSupportDir = await getApplicationSupportDirectory();

      // Create the path of the specific folder you want to delete
      String specificFolderPath =
          '${appSupportDir.path}/${widget.bookInfo.title}';

      // Check if the folder exists
      if (await Directory(specificFolderPath).exists()) {
        // Delete the folder and all its contents
        await Directory(specificFolderPath).delete(recursive: true);
        if (mounted) {
          setState(() {
            existBook = false;
          });
        }
        EasyLoading.showToast("Cleared successfully");
        // print('Specific folder and its contents deleted successfully.');
      } else {
        EasyLoading.showToast("The specific folder does not exist.");
        // print('The specific folder does not exist.');
      }
    } catch (e) {
      EasyLoading.showToast("Error while deleting the specific folder: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
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
                Expanded(
                  child: Text(
                    widget.bookInfo.title,
                    style: GoogleFonts.prompt(
                      textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Material(
                        elevation: 0.0,
                        child: widget.bookInfo.picurl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: '$mainHost${widget.bookInfo.picurl}',
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 200,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 8,
                                          blurRadius: 10,
                                          offset: const Offset(0, 3))
                                    ],
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 8,
                                          blurRadius: 10,
                                          offset: const Offset(0, 3))
                                    ],
                                    image: const DecorationImage(
                                      image: AssetImage("img/CK_logo.png"),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                height: 200,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: const DecorationImage(
                                    image: AssetImage("img/CK_logo.png"),
                                  ),
                                ),
                              ),
                      ),
                      Container(
                        width: screenWidth - 30 - 180 - 20,
                        margin: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              widget.bookInfo.title,
                              style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Lessons: ",
                                  style: GoogleFonts.prompt(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black38,
                                  ),
                                ),
                                lessonLength > 0
                                    ? Text(
                                        "$lessonLength items",
                                        style: GoogleFonts.prompt(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: const Color(0xcd292735),
                                        ),
                                      )
                                    : SizedBox(
                                        width:
                                            10.0, // Set the desired width of the CircularProgressIndicator
                                        height:
                                            10.0, // Set the desired height of the CircularProgressIndicator
                                        child: CircularProgressIndicator(
                                          strokeWidth:
                                              3, // You can adjust the thickness of the progress indicator
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.blue),
                                          backgroundColor: Colors.grey[300],
                                        ),
                                      ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Author:",
                                  style: GoogleFonts.prompt(
                                    color: Colors.black38,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.transparent,
                                  child: Image.asset(
                                    "img/cklogo.png",
                                    height: 25,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        "DETAILS",
                        style: GoogleFonts.prompt(
                          textStyle: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w800,
                              fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: Text(
                      'Presented by CK Children\'s Publishing, this book offers visual learning and integration for your benefit.'
                          .toUpperCase(),
                      style: GoogleFonts.prompt(
                          color: Colors.black87, fontSize: 15),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (downloadEnabled) const Divider(),
                  if (pdfTitle.isNotEmpty)
                    SizedBox(
                      child: Text(
                        pdfTitle,
                        style: GoogleFonts.prompt(
                          textStyle: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        overflow:
                            TextOverflow.ellipsis, // Truncate text with ...
                        maxLines: 1, // Display only one line
                        textAlign: TextAlign.start,
                      ),
                    ),
                  if (downloadEnabled)
                    LinearPercentIndicator(
                      lineHeight: 20.0,
                      percent: downloadProgress <= 1.0 ? downloadProgress : 0,
                      center: Text(
                          '${(downloadProgress * 100).toStringAsFixed(2)}%'),
                      progressColor: Colors.blue,
                    ),
                  const SizedBox(
                    height: 5,
                  ),
                  if (downloadEnabled)
                    finished
                        ? const Text(
                            'Finished.',
                          )
                        : const Text(
                            'Please wait while the file is being downloaded.',
                          ),
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: isButtonEnabled
                              ? () {
                                  if (existBook) {
                                    if (mounted) {
                                      setState(() {
                                        isButtonEnabled = false;
                                      });
                                    }
                                    var imgPathLocal =
                                        "${appDir.path}/${widget.bookInfo.title}/cover_image";
                                    EasyLoading.show(status: "Preparing...");
                                    saveCurrentBook(widget.bookInfo.title);
                                    navigateToMainNav(imgPathLocal);
                                    if (mounted) {
                                      setState(() {
                                        isButtonEnabled = true;
                                      });
                                    }
                                  } else {
                                    if (lowStorage) {
                                      EasyLoading.showInfo(
                                          'Not enough storage. Please clean your phone!');
                                    } else {
                                      showDonwloadConfirmationDialog(context);
                                    }
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: isButtonEnabled
                                  ? Colors.green[600]
                                  : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 10.0,
                                bottom: 10.0,
                              ),
                              alignment: Alignment.center),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                existBook
                                    ? Icons.remove_red_eye_rounded
                                    : Icons.download,
                                color:
                                    Colors.white, // Set the icon color to red
                              ),
                              const SizedBox(
                                  width:
                                      8.0), // Add some spacing between icon and text
                              Text(
                                " ${existBook ? 'Explore' : 'Download'} ",
                                style: GoogleFonts.prompt(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (existBook)
                          ElevatedButton(
                            onPressed: isButtonEnabled2
                                ? () {
                                    showClearConfirmationDialog(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .transparent, // Set the background color to transparent
                              foregroundColor: Colors
                                  .red, // Set the text color when using a transparent button
                              elevation:
                                  0, // No elevation for a transparent button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                    color: Colors
                                        .red), // Add an outline using a red border
                              ),
                              padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 10.0,
                                bottom: 10.0,
                              ),
                              alignment: Alignment.center,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.delete,
                                  color:
                                      Colors.red, // Set the icon color to red
                                ),
                                const SizedBox(
                                    width:
                                        8.0), // Add some spacing between icon and text
                                Text(
                                  "Clear",
                                  style: GoogleFonts.prompt(
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                  // const Divider(color: Color(0xFF7b8ea3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PdfDownloadInfo {
  final String pdfUrl;
  final String savePath;
  final String title;

  PdfDownloadInfo(this.pdfUrl, this.savePath, this.title);
}
