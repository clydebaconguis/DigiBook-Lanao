import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:ict_ebook_hsa/pages/schools_selection.dart';
import 'package:path_provider/path_provider.dart';

class AppUtil {
  // schoolAbbv() {
  //   return "SJHS";
  // }

  // schoolPrimary() {
  //   return const Color(0xFFA4040B);
  // }

  schoolSecondary() {
    return Colors.grey[900];
  }

  // schoolName() {
  //   return "Saint Jude High School";
  // }

  // schoolAddress() {
  //   return "Sitio Regta, Poblacion @, Pagudpud, Ilocos Norte";
  // }

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

  changeStatusBarColor(Color color) async {
    await FlutterStatusbarcolor.setStatusBarColor(color);
    if (useWhiteForeground(color)) {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    } else {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    }
  }

  List<SchoolData> schools = [
    SchoolData(
      name: 'Christ the King College de Maranding',
      img: 'img/CKCM.png',
      domain: 'https://ckcm.cklms.ph/',
      abbv: 'CKCM',
      primary: const Color(0xFFFD3C03),
      address: 'Maranding, Lala, Lanao del Norte, Maranding, Philippines',
    ),
    SchoolData(
      name: 'Saint Francis Xavier Academy',
      img: 'img/FRANCIS.png',
      domain: 'https://sfxa.cklms.ph/',
      abbv: 'SFXA',
      primary: const Color(0xFF019651),
      address: 'Poblacion, Kapatagan, Lanao del Norte',
    ),
    SchoolData(
      name: 'Lanipao Catholic High School',
      img: 'img/LANIPAO.png',
      domain: 'https://lchs.cklms.ph/',
      abbv: 'LCHS',
      primary: const Color(0xFF026F39),
      address: 'Lanipao Lala Lanao del Norte',
    ),
    SchoolData(
      name: 'Sto. Niño Academy of Baroy',
      img: 'img/SNABI.png',
      domain: 'https://snabi.cklms.ph/',
      abbv: 'SNABI',
      primary: const Color(0xFF05904A),
      address: 'Baroy, Lanao del Norte, Baroy, Philippines',
    ),
  ];
}
