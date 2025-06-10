// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';

// class TabelAntrianViewModel extends ChangeNotifier {
//   List<Map<String, String>> _antrian = [];

//   List<Map<String, String>> get antrian => _antrian;

//   Future<void> loadAntrian() async {
//     final umumUrl = Uri.parse('http://localhost:3000/queue/umum');
//     final prioritasUrl = Uri.parse('http://localhost:3000/queue/prioritas');

//     try {
//       final responseUmum = await http.get(umumUrl);
//       final responsePrioritas = await http.get(prioritasUrl);

//       if (responseUmum.statusCode == 200 && responsePrioritas.statusCode == 200) {
//         final List<dynamic> dataUmum = json.decode(responseUmum.body);
//         final List<dynamic> dataPrioritas = json.decode(responsePrioritas.body);

//         _antrian = [
//           ...dataUmum.map((e) => {
//             'nama': e['nama'] ?? '',
//             'nik': e['nik'] ?? '',
//             'alamat': e['alamat'] ?? '',
//             'layanan': e['jenis_layanan'] ?? '',
//             'noHp': e['telepon'] ?? '',
//             'kategori': e['kategori'] ?? 'umum',
//             'status': e['status'] ?? 'Menunggu',
//           }),
//           ...dataPrioritas.map((e) => {
//             'nama': e['nama'] ?? '',
//             'nik': e['nik'] ?? '',
//             'alamat': e['alamat'] ?? '',
//             'layanan': e['jenis_layanan'] ?? '',
//             'noHp': e['telepon'] ?? '',
//             'kategori': e['kategori'] ?? 'khusus',
//             'status': e['status'] ?? 'Menunggu',
//           }),
//         ];

//         notifyListeners();
//       } else {
//         throw Exception("Gagal mengambil data dari API");
//       }
//     } catch (e) {
//       print("Error saat loadAntrian: $e");
//     }
//   }
// }
