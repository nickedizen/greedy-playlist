import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

import '../models/song.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Fungsi parsing langsung (tanpa isolate)
  List<Song> parseCsvDirect(String rawCsv) {
    final rows = const CsvToListConverter(eol: '\n').convert(rawCsv);
    return rows.skip(1).map((row) {
      return Song.fromCsv(row);
    }).toList();
  }


  Future<void> loadData() async {
    debugPrint('loadData dipanggil');
    try {
      final byteData = await rootBundle.load('assets/data/songs.csv');
      final bytes = byteData.buffer.asUint8List();

      final rawCsv = utf8.decode(bytes);

      final songs = parseCsvDirect(rawCsv);

      await Future.delayed(Duration(seconds: 3));

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(seconds: 1),
          pageBuilder: (context, animation, secondaryAnimation) => HomePage(songs: songs),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      debugPrint('Gagal load CSV: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1f2b4c),
      body: Center(
        child: Image.asset('assets/images/logo.png'),
      ),
    );
  }
}
