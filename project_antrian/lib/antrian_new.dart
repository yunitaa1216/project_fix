import 'package:flutter/material.dart'; 
import 'package:project_antrian/view/antrian_view/antrian_table.dart';
import 'package:project_antrian/viewmodel/antrian_viewmodel.dart';
import 'package:project_antrian/widgets/sidebar.dart';          // ⬅️
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;   // alias “pw” biar pendek
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' as pdf;

class AntrianSaatIniPage extends StatefulWidget {
  const AntrianSaatIniPage({Key? key}) : super(key: key);

  @override
  State<AntrianSaatIniPage> createState() => _AntrianSaatIniPageState();
}

class _AntrianSaatIniPageState extends State<AntrianSaatIniPage> {
  late AntrianViewModel viewModel;
  bool _isLoading = true;
  List<Map<String, String>> _dataAntrian = [];

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<AntrianViewModel>(context, listen: false);
    load();
  }

  Future<void> _printTicket(Map<String, String> item) async {
  final doc = pw.Document();

  final pageFormat = pdf.PdfPageFormat(
  58 * pdf.PdfPageFormat.mm,
  double.infinity, // tinggi fleksibel
  marginAll: 4 * pdf.PdfPageFormat.mm,
);

  final now = DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.now());

  doc.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'DISDUKCAPIL SULTENG',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            item['nomor'] ?? item['uuid']!.substring(0, 6).toUpperCase(),
            style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            item['layanan']!.toUpperCase(),
            style: pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 6),
          pw.Text(now, style: pw.TextStyle(fontSize: 8)),
        ],
      ),
    ),
  );

   await Printing.layoutPdf(
  name: 'Tiket Antrian 58 mm',
  onLayout: (_) async => doc.save(),   // pageFormat diambil dari `doc`
);

  // await Printing.sharePdf(
  //   bytes: await doc.save(),
  //   filename: 'tiket_antrian_58mm.pdf',
  // );
}

  Future<void> load() async {
    await viewModel.loadAntrian();
    setState(() {
      _dataAntrian = viewModel.antrian.where((e) =>
          (e['status'] ?? '').toLowerCase() != 'selesai').toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    Widget mainContent = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.list_alt, color: Color(0xFF292794)),
              SizedBox(width: 8),
              Text(
                'Antrian Saat Ini',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF292794),
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black12,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : AntrianDataTable(
                    dataAntrian: _dataAntrian,
                    dataRiwayat: const [],
                    onRiwayatUpdate: (_) {},
                    onPanggilAntrian: (_, __, ___) {},
                    onStatusChanged: (idx, status) async {
  final uuid = _dataAntrian[idx]['uuid']!;
  final ok = await viewModel.updateStatusAntrian(
      uuid: uuid, statusBaru: status!);
  if (ok) {
    setState(() {
      if (status.toLowerCase() == 'selesai') {
  _dataAntrian.removeAt(idx);           // langsung hilang dari tabel
} else {
  _dataAntrian[idx]['status'] = status; // ganti status di baris
}
    });
  }
},

                    onPrint: _printTicket,
                  ),
          ),
        ],
      ),
    );

    // ===== MOBILE LAYOUT =====
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Antrian Saat Ini',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF292794),
        ),
        drawer: Drawer(
          child: Sidebar(
            onItemSelected: (page) {
              Navigator.pop(context); // tutup drawer
              _handleNavigation(context, page);
            },
          ),
        ),
        body: mainContent,
      );
    }

    // ===== DESKTOP / TABLET LAYOUT =====
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            onItemSelected: (page) => _handleNavigation(context, page),
          ),
          Expanded(child: mainContent),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, String page) {
    switch (page) {
      case 'Beranda':
        Navigator.pushReplacementNamed(context, '/beranda');
        break;
      case 'Input Antrian':
        Navigator.pushReplacementNamed(context, '/antrian');
        break;
      case 'Antrian Saat Ini':
        // sudah di halaman ini, tak perlu apa‑apa
        break;
      case 'Riwayat':
        Navigator.pushReplacementNamed(context, '/riwayat');
        break;
      case 'Logout':
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        break;
    }
  }
}