import 'package:project_antrian/viewmodel/riwayat_viewmodel.dart';
import 'package:project_antrian/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final RiwayatViewModel viewModel = RiwayatViewModel();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  final int _rowsPerPage = 10;

  List<Map<String, String>> _riwayatData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiwayatData();
  }

 Future<void> fetchRiwayatData() async {
  try {
    final response =
        await http.get(Uri.parse('http://localhost:3000/queue/riwayat'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      // Pastikan json['response'] adalah List
      List<dynamic> data = json['response'];
      print(jsonDecode(response.body));

      setState(() {
        _riwayatData = data
            .where((item) => item['status'] == 'selesai')
            .map<Map<String, String>>((item) {
          // Format tanggal menjadi yy/MM/dd
          String formattedDate = '';
          if (item['date'] != null) {
            try {
              final rawDate = DateTime.parse(item['date']);
              formattedDate = DateFormat('dd/MM/yyyy').format(rawDate);
            } catch (e) {
              print('Error parsing date: $e');
            }
          }

          return {
            'nama': item['nama'] ?? '',
            'nik': item['nik'] ?? '',
            'alamat': item['alamat'] ?? '',
            'layanan': item['jenis_layanan'] ?? '',
            'noHp': item['telepon'] ?? '',
            'kategori': item['kategori'] ?? '',
            'status': item['status'] ?? '',
            'tanggal': formattedDate, // Gunakan tanggal yang diformat
          };
        }).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print('Error fetching data: $e');
    setState(() {
      _isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    List<Map<String, String>> filteredData = _riwayatData.where((item) {
      final nama = item['nama']?.toLowerCase() ?? '';
      return nama.contains(_searchQuery.toLowerCase());
    }).toList();

    int start = _currentPage * _rowsPerPage;
    int end = (start + _rowsPerPage).clamp(0, filteredData.length);

    List<Map<String, String>> paginatedData = filteredData.sublist(start, end);

    Widget content;

    if (_isLoading) {
      content = Center(child: CircularProgressIndicator());
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RIWAYAT ANTRIAN',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF292794),
              ),
            ),
            const SizedBox(height: 20),
            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama...',
                      hintStyle: TextStyle(color: Color(0xFFA3A3D1)),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF292794)),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF292794)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF292794), width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    style: TextStyle(color: Color(0xFF292794)),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchQuery = _searchController.text;
                      _currentPage = 0;
                    });
                  },
                  icon: Icon(Icons.filter_alt_outlined),
                  label: Text('Cari'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF292794),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Tabel
            Expanded(
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth,
                                  ),
                                  child: DataTable(
                                    headingRowColor:
                                        MaterialStateProperty.all(Color(0xFFEAEAFF)),
                                    headingTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF292794),
                                      fontSize: 14,
                                    ),
                                    dataTextStyle: TextStyle(
                                      color: Color(0xFF292794),
                                      fontSize: 13,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text('No')),
                                      DataColumn(label: Text('Tanggal')), 
                                      DataColumn(label: Text('Nama')),
                                      DataColumn(label: Text('NIK')),
                                      DataColumn(label: Text('Alamat')),
                                      DataColumn(label: Text('Layanan')),
                                      DataColumn(label: Text('No HP')),
                                      DataColumn(label: Text('Kategori')),
                                    ],
                                    rows: List.generate(
                                      paginatedData.length,
                                      (index) => DataRow(
                                        color:
                                            MaterialStateProperty.resolveWith<Color?>(
                                                (states) {
                                          if (index % 2 == 0) {
                                            return Color(0xFFF5F5FF);
                                          }
                                          return null;
                                        }),
                                        cells: [
                                          DataCell(Text('${start + index + 1}')),
                                          DataCell(Text(paginatedData[index]['tanggal'] ?? '')),
                                          DataCell(Text(
                                              paginatedData[index]['nama'] ?? '')),
                                          DataCell(Text(
                                              paginatedData[index]['nik'] ?? '')),
                                          DataCell(Text(
                                              paginatedData[index]['alamat'] ?? '')),
                                          DataCell(Text(
                                              paginatedData[index]['layanan'] ?? '')),
                                          DataCell(Text(
                                              paginatedData[index]['noHp'] ?? '')),
                                          DataCell(Text(
                                              paginatedData[index]['kategori'] ?? '')),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Halaman ${_currentPage + 1} dari ${((filteredData.length - 1) / _rowsPerPage + 1).floor()}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _currentPage > 0
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                  }
                                : null,
                            child: Text('Previous'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: end < filteredData.length
                                ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  }
                                : null,
                            child: Text('Next'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Riwayat Antrian',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Color(0xFF292794),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: Drawer(
          child: Sidebar(
            onItemSelected: (item) {
              Navigator.pop(context);
              if (item == 'Beranda') {
                Navigator.pushNamed(context, '/beranda');
              } else if (item == 'Input Antrian') {
                Navigator.pushNamed(context, '/antrian');
              } else if (item == 'Logout') {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              }
            },
          ),
        ),
        body: content,
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            Sidebar(
              onItemSelected: (item) {
                if (item == 'Beranda') {
                  Navigator.pushNamed(context, '/beranda');
                } else if (item == 'Input Antrian') {
                  Navigator.pushNamed(context, '/antrian');
                } else if (item == 'Logout') {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                }
              },
            ),
            Expanded(child: content),
          ],
        ),
      );
    }
  }
}
