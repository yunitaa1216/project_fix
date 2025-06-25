import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_antrian/model/beranda_model/beranda_m.dart';
// import 'package:dukcapil_antrian/widgets/sidebar_content.dart'; // Gunakan SidebarContent, bukan Sidebar yang fix web
import 'package:project_antrian/widgets/sidebar.dart'; // Hanya untuk web
import 'package:http/http.dart' as http;

class BerandaPage extends StatefulWidget {
  const BerandaPage({Key? key}) : super(key: key);

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  StatistikData? statistik;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatistik();
  }

  Future<void> fetchStatistik() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/queue/statistik'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          statistik = StatistikData.fromJson(data);
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data statistik');
      }
    } catch (e) {
      print('Error saat fetch statistik: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (statistik == null) {
      return const Center(child: Text("Gagal memuat data statistik."));
    }

    final layananData = {
      'KTP': statistik!.ktp,
      'Akte kelahiran': statistik!.aktaKelahiran,
      'Akte kematian': statistik!.aktaKematian,
      'Kartu keluarga': statistik!.kk,
      'Layanan lainnya': statistik!.layananLainnya,
    };

    int maxValue = layananData.values.reduce((a, b) => a > b ? a : b);

    Widget mainContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'SISTEM ANTRIAN DISDUKCAPIL PROVINSI SULAWESI TENGAH',
              style: TextStyle(
                fontSize: isMobile ? 20 : 30,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF292794),
                letterSpacing: 1.1,
                shadows: const [
                  Shadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 2),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Statistik Antrian',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          isMobile
              ? Column(
                  children: [
                    _buildStatCard(Icons.people, 'Total Pengunjung',
                        statistik!.totalPengunjung.toString(), Colors.indigo),
                    const SizedBox(height: 16),
                    _buildStatCard(Icons.check_circle, 'Sudah Dilayani',
                        statistik!.totalSelesai.toString(), Colors.indigo),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(Icons.people, 'Total Pengunjung',
                          statistik!.totalPengunjung.toString(), Colors.indigo),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(Icons.check_circle, 'Sudah Dilayani',
                          statistik!.totalSelesai.toString(), Colors.indigo),
                    ),
                  ],
                ),
          const SizedBox(height: 32),
          const Text(
            'Distribusi Jenis Layanan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: layananData.entries.map((entry) {
                double barWidth = (entry.value / maxValue) * 300;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(width: 140, child: Text(entry.key, style: const TextStyle(fontSize: 14))),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Container(
                              height: 20,
                              width: barWidth,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFF170),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(entry.value.toString()),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Beranda',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: const Color(0xFF292794),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: Drawer(
          child: Sidebar(
            onItemSelected: (item) {
              Navigator.pop(context);
              _handleNavigation(context, item);
            },
          ),
        ),
        body: mainContent,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Sidebar(onItemSelected: (item) => _handleNavigation(context, item)),
          Expanded(child: mainContent),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, String item) {
    if (item == 'Input Antrian') {
      Navigator.pushNamed(context, '/antrian');
    } else if (item == 'Riwayat') {
      Navigator.pushNamed(context, '/riwayat');
    } else if (item == 'Logout') {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}