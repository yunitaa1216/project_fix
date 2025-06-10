import 'dart:convert';
import 'package:http/http.dart' as http;

class RiwayatViewModel {
  Future<List<Map<String, String>>> getDataRiwayat() async {
    final url = Uri.parse('http://localhost:3000/queue/riyawat');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      final List<dynamic> dataList = jsonData['response'];

      return dataList.map<Map<String, String>>((item) {
        return {
          'uuid': item['uuid'] ?? '',
          'nama': item['nama'] ?? '',
          'nik': item['nik'] ?? '',
          'alamat': item['alamat'] ?? '',
          'layanan': item['layanan'] ?? '',
          'noHp': item['noHp'] ?? '',
          'kategori': item['kategori'] ?? '',
          'status': item['status'] ?? ''
        };
      }).toList();
    } else {
      throw Exception('Gagal mengambil data riwayat');
    }
  }
}
