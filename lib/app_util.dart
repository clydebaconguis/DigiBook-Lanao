import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AppUtil {
  schoolAbbv() {
    return "SNABI";
  }

  schoolPrimary() {
    return const Color(0xFF05904A);
  }

  schoolSecondary() {
    return Colors.grey[900];
  }

  schoolName() {
    return "Sto. Niño Academy of Baroy, Inc.";
  }

  schoolAddress() {
    return "Baroy, Lanao del Norte, Baroy, Philippines";
  }

  readBooks() async {
    var dir = await getApplicationSupportDirectory();
    final pathFile = Directory(dir.path);
    final List<FileSystemEntity> entities = await pathFile.list().toList();
    // final Iterable<Directory> files = entities.whereType<Directory>();
    return entities;
  }

  readFilesDir(String folderName) async {
    var dir = await getApplicationSupportDirectory();
    final pathFile = Directory('${dir.path}/$folderName');
    final List<FileSystemEntity> entities = await pathFile.list().toList();
    // final Iterable<Directory> files = entities.whereType<Directory>();

    // entities.forEach(print);
    return entities;
  }

  static Future<String> foldrExist(String folderName) async {
    final Directory appDir = await getApplicationSupportDirectory();
    // const folderName = 'SampleBook';
    final Directory appDirFolder = Directory("${appDir.path}/$folderName/");
    if (await appDirFolder.exists()) {
      //if folder already exists return path
      return appDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      // final Directory appDocDirNewFolder =
      //     await appDirFolder.create(recursive: true);
      // return appDocDirNewFolder.path;
      return '';
    }
  }

  String splitPath(url) {
    File file = File(url);
    String filename = file.path.split(Platform.pathSeparator).last;
    return filename;
  }
}
