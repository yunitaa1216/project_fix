import 'package:project_antrian/beranda.dart';
import 'package:project_antrian/dropdown.dart';
import 'package:project_antrian/form_field.dart';
import 'package:project_antrian/home_page.dart';
import 'package:project_antrian/login_page.dart';
import 'package:project_antrian/riwayat.dart';
import 'package:project_antrian/view/antrian_view/antrian_page.dart';
import 'package:project_antrian/viewmodel/antrian_viewmodel.dart';
import 'package:project_antrian/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar_item.dart';
// import '../widgets/form_field.dart';
// import '../widgets/dropdown_field.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AntrianViewModel(),
      child: MyAntrianApp(),
    ),
  );
}

class MyAntrianApp extends StatefulWidget {
  @override
  State<MyAntrianApp> createState() => _MyAntrianAppState();
}

class _MyAntrianAppState extends State<MyAntrianApp> {
  List<Map<String, String>> dataRiwayat = [];
  @override
  void initState() {
    super.initState();

    // Tambahkan data dummy saat initState
    dataRiwayat = List.generate(25, (index) {
      return {
        'nama': 'Nama $index',
        'nik': '7205${index.toString().padLeft(6, '0')}',
        'alamat': 'Jl. Contoh No.${index + 1}',
        'layanan': 'Pembuatan KTP',
        'kategori': index % 2 == 0 ? 'Umum' : 'Lansia',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'Sistem Antrian Disdukcapil',
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    fontFamily: 'Arial',
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
  ),
  initialRoute: '/', // <--- Tambahkan ini
  routes: {
    '/': (context) => const LoginPage(), // <--- Tambahkan rute login
    '/beranda': (context) => BerandaPage(),
    '/antrian': (context) => AntrianPage(
          onRiwayatUpdate: (riwayatBaru) {
            setState(() {
              dataRiwayat = riwayatBaru;
            });
          },
          dataRiwayat: dataRiwayat,
        ),
    '/riwayat': (context) => RiwayatPage(),
  },
);
  }
}