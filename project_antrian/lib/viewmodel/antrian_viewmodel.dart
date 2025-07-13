import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

    final url = Uri.parse('http://localhost:3000/queue');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _processResponse(response.body);
      } else {
        _error = "Gagal mengambil data dari API: ${response.statusCode}";
        debugPrint(_error);
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

  void _processResponse(String responseBody) {
    try {
      final decoded = json.decode(responseBody);

      final List<dynamic> data = (decoded is Map && decoded['response'] is List)
          ? decoded['response']
          : [];

      _antrian = data
          .map<Map<String, String>>((e) => _mapQueueItem(e, 'umum'))
          .toList();
    } catch (e) {
      _error = "Error processing API response: $e";
      debugPrint(_error);
    }
  }

  Map<String, String> _mapQueueItem(dynamic e, String defaultKategori) {
    final rawDate = (e['createdAt'] ?? e['date'])?.toString() ?? '';

    // format → “dd/MM/yyyy HH:mm”
    final formatted = rawDate.isNotEmpty
        ? DateFormat('dd/MM/yyyy  HH:mm').format(DateTime.parse(rawDate))
        : '';
    return {
      'uuid': e['uuid']?.toString() ?? '',
      'nama': e['nama']?.toString() ?? '',
      'nik': e['nik']?.toString() ?? '',
      'alamat': e['alamat']?.toString() ?? '',
      'layanan': e['jenis_layanan']?.toString() ?? '',
      'reason': e['reason']?.toString() ?? 'null',
      'noHp': e['telepon']?.toString() ?? '',
      'kategori': e['kategori']?.toString() ?? defaultKategori,
      'status': e['status']?.toString() ?? 'Menunggu',
      'tanggal': formatted,
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
    String? reason,
  }) async {
    final url = Uri.parse('http://localhost:3000/queue/create');
    final token = await _getToken();

    /* ────────────── bangun payload ────────────── */
    final Map<String, dynamic> payload = {
      'nama': nama,
      'nik': nik,
      'alamat': alamat,
      'telepon': telepon,
      'jenis_layanan': jenisLayanan,
      'kategori': kategori,
    };

    // backend mewajibkan reason HANYA ketika jenis layanan pembuatan ktp
    if (jenisLayanan == 'pembuatan ktp') {
      payload['reason'] = reason; // ⬅️ WAJIB ada
    }
    /* ──────────────────────────────────────────── */

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body  : ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // server Anda biasanya mengembalikan uuid langsung
        return data['uuid']?.toString();
      }

      // log jika gagal
      debugPrint('❌ Gagal tambah antrian, status: ${response.statusCode}');
      return null;
    } catch (e, s) {
      debugPrint('❌ Exception tambahAntrianAPI: $e');
      debugPrint('📍 $s');
      return null;
    }
  }

  Future<bool> updateStatusAntrian({
    required String uuid,
    required String statusBaru,
  }) async {
    final url = Uri.parse('http://localhost:3000/queue/update/$uuid');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // ← ambil token

    if (token == null) {
      _error = 'Token kosong, login ulang terlebih dahulu';
      notifyListeners();
      return false;
    }

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ← kirim token
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
