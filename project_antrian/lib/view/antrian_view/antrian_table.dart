import 'package:flutter/material.dart';

class AntrianDataTable extends StatelessWidget {
  final List<Map<String, String>> dataAntrian;
  final List<Map<String, String>> dataRiwayat;
  final Function(List<Map<String, String>>) onRiwayatUpdate;
  final Function(int, String, String) onPanggilAntrian;
  final Function(int, String?) onStatusChanged;
  final void Function(Map<String, String>)? onPrint; 

  const AntrianDataTable({
    required this.dataAntrian,
    required this.dataRiwayat,
    required this.onRiwayatUpdate,
    required this.onPanggilAntrian,
    required this.onStatusChanged,
    required this.onPrint
  });

  @override
  Widget build(BuildContext context) {
  return Card(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final table = _buildDataTable();

        // --- GULIR VERTIKAL + HORIZONTAL ---
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,     // ⬅️ gulir atas‑bawah
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // ⬅️ gulir kiri‑kanan
              child: ConstrainedBox(
                // pastikan lebar min. = lebar parent, supaya
                // tabel tidak “mengecil” saat kolom sedikit
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: table,
              ),
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildDataTable() {
    final List<String> statusList = ['Menunggu', 'Proses', 'Selesai'];

    return DataTable(
      headingRowColor: MaterialStateProperty.all(Color(0xFFFFFFFF)),
      columnSpacing: 24,
      horizontalMargin: 16,
      dividerThickness: 0.8,
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF292794),
      ),
      dataTextStyle: TextStyle(
        fontSize: 14,
        color: Color(0xFF292794),
      ),
      columns: [
        DataColumn(label: Text('No')),
        DataColumn(label: Text('Nama')),
        DataColumn(label: Text('Jenis Layanan')),
        DataColumn(label: Text('Kategori')),
        DataColumn(label: Text('No HP')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Cetak')), 
        DataColumn(label: Text('Aksi')),
      ],
      rows: List.generate(
        dataAntrian.length,
        (index) => DataRow(
          cells: [
            DataCell(Text('${index + 1}')),
            DataCell(Text(dataAntrian[index]['nama'] ?? '')),
            DataCell(Text(dataAntrian[index]['layanan'] ?? '')),
            DataCell(Text(dataAntrian[index]['kategori'] ?? '')),
            DataCell(Text(dataAntrian[index]['noHp'] ?? '')),
            DataCell(
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _normalizeStatus(dataAntrian[index]['status']),
                  iconEnabledColor: Color(0xFF292794),
                  dropdownColor: Color(0xFFEAEAFF),
                  style: const TextStyle(
                    color: Color(0xFF292794),
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (newStatus) => onStatusChanged(index, newStatus),
                  items: statusList
                      .map((status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                ),
              ),
            ),
            DataCell(
  IconButton(
    icon: const Icon(Icons.print, color: Color(0xFF292794)),
    tooltip: 'Cetak Tiket',
    onPressed: () {
      debugPrint('print pressed');               // ← tes console
      final item = {
        ...dataAntrian[index],                   // semua data
        'nomor': (index + 1).toString(),         // nomor urut
        'layanan': dataAntrian[index]['layanan'] ??
                   dataAntrian[index]['jenis_layanan'] ??
                   '',
      };
      onPrint?.call(item);                       // WAJIB ada
    },
  ),
),
            DataCell(
              IconButton(
                icon: Icon(Icons.volume_up, color: Colors.deepPurple),
                tooltip: 'Panggil Antrian',
                onPressed: () {
                  onPanggilAntrian(
                    index + 1,
                    dataAntrian[index]['nama'] ?? '',
                    dataAntrian[index]['kategori'] ?? 'Umum',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _normalizeStatus(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'proses':
        return 'Proses';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Menunggu';
    }
  }
}
