import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AntrianViewModel extends ChangeNotifier {
  List<Map<String, String>> _antrian = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, String>> get antrian => _antrian;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAntrian() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final umumUrl = Uri.parse('http://localhost:3000/queue/umum');
    final prioritasUrl = Uri.parse('http://localhost:3000/queue/prioritas');

    try {
      final responses = await Future.wait([
        http.get(umumUrl),
        http.get(prioritasUrl),
      ]);

      final responseUmum = responses[0];
      final responsePrioritas = responses[1];

      if (responseUmum.statusCode == 200 && responsePrioritas.statusCode == 200) {
        _processResponse(responseUmum.body, responsePrioritas.body);
      } else {
        _error = "Gagal mengambil data dari API: ${responseUmum.statusCode}, ${responsePrioritas.statusCode}";
      }
    } catch (e, stackTrace) {
      _error = "Error saat loadAntrian: $e";
      debugPrint("❌ Error saat loadAntrian: $e");
      debugPrint("📍 StackTrace: $stackTrace");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _processResponse(String umumBody, String prioritasBody) {
    try {
      final decodedUmum = json.decode(umumBody);
      final decodedPrioritas = json.decode(prioritasBody);

      final List<dynamic> dataUmum = (decodedUmum is Map && decodedUmum['response'] is List)
          ? decodedUmum['response']
          : [];

      final List<dynamic> dataPrioritas = (decodedPrioritas is Map && decodedPrioritas['response'] is List)
          ? decodedPrioritas['response']
          : [];

      _antrian = [
        ...dataUmum.map<Map<String, String>>((e) => _mapQueueItem(e, 'umum')),
        ...dataPrioritas.map<Map<String, String>>((e) => _mapQueueItem(e, 'prioritas')),
      ];
    } catch (e) {
      _error = "Error processing API response: $e";
      debugPrint(_error);
    }
  }

  Map<String, String> _mapQueueItem(dynamic e, String defaultKategori) {
    return {
      'uuid': e['uuid']?.toString() ?? '',
      'nama': e['nama']?.toString() ?? '',
      'nik': e['nik']?.toString() ?? '',
      'alamat': e['alamat']?.toString() ?? '',
      'layanan': e['jenis_layanan']?.toString() ?? '',
      'noHp': e['telepon']?.toString() ?? '',
      'kategori': e['kategori']?.toString() ?? defaultKategori,
      'status': e['status']?.toString() ?? 'Menunggu',
    };
  }
  Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  return token;
}

  Future<String?> tambahAntrianAPI({
  required String nama,
  required String nik,
  required String alamat,
  required String telepon,
  required String jenisLayanan,
  required String kategori,
}) async {
  final url = Uri.parse('http://localhost:3000/queue/create');

  try {
    final token = await _getToken();
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama'         : nama,
        'nik'          : nik,
        'alamat'       : alamat,
        'telepon'      : telepon,
        'jenis_layanan': jenisLayanan,
        'kategori'     : kategori,
      }),
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body  : ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // ── Cari uuid di dua lokasi yang mungkin ────────────────────────────
      String? uuid = data['uuid'] as String?;
      if (uuid == null && data['response'] is Map) {
        uuid = (data['response'] as Map)['uuid'] as String?;
      }
      // ────────────────────────────────────────────────────────────────────

      if (uuid != null) {
        debugPrint('✅ Berhasil tambah antrian; UUID = $uuid');
        return uuid;      // ← sukses dengan uuid
      } else {
        debugPrint('ℹ️ Berhasil tambah antrian; server tak kirim uuid');
        return null;      // ← sukses, tapi tanpa uuid
      }
    } else {
      debugPrint('❌ Gagal tambah antrian, status code: ${response.statusCode}');
      return null;
    }
  } catch (e, stackTrace) {
    debugPrint('Error tambah antrian: $e');
    debugPrint('StackTrace: $stackTrace');
    return null;
  }
}

  Future<bool> updateStatusAntrian({
  required String uuid,
  required String statusBaru,
}) async {
  final url   = Uri.parse('http://localhost:3000/queue/update/$uuid');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');          // ← ambil token

  if (token == null) {
    _error = 'Token kosong, login ulang terlebih dahulu';
    notifyListeners();
    return false;
  }

  try {
    final response = await http.patch(
      url,
      headers: {
        'Content-Type' : 'application/json',
        'Authorization': 'Bearer $token',        // ← kirim token
      },
      body: jsonEncode({'status': statusBaru}),
    );

    if (response.statusCode == 200) {
      final index = _antrian.indexWhere((e) => e['uuid'] == uuid);
      if (index != -1) _antrian[index]['status'] = statusBaru;
      notifyListeners();
      return true;
    } else {
      _error =
          'Gagal update status: ${response.statusCode} - ${response.body}';
      notifyListeners();
      return false;
    }
  } catch (e) {
    _error = 'Error update status: $e';
    notifyListeners();
    return false;
  }
}
}
