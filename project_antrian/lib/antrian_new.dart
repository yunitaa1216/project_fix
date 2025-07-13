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

  pdf.PdfColor _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return pdf.PdfColors.white;

    hex = hex.replaceFirst('#', '');
    // dukung format 3‑digit (#fff) → #ffffff
    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }
    // jika masih bukan 6 digit, pakai putih
    if (hex.length != 6) return pdf.PdfColors.white;

    try {
      final r = int.parse(hex.substring(0, 2), radix: 16);
      final g = int.parse(hex.substring(2, 4), radix: 16);
      final b = int.parse(hex.substring(4, 6), radix: 16);
      return pdf.PdfColor.fromInt(0xff000000 | (r << 16) | (g << 8) | b);
    } catch (_) {
      return pdf.PdfColors.white;
    }
  }


  Future<void> _printTicket(Map<String, String> item) async {
  final doc = pw.Document();

  // Default values jika data kosong
  final nomor = item['nomor'] ?? item['uuid']?.substring(0, 6).toUpperCase() ?? '???';
  final layanan = item['layanan']?.toUpperCase() ?? 'LAYANAN';
  final alasan = item['reason'] ?? '';
  final warnaHex = item['color'] ?? '#FFFFFF';

  final pdf.PdfColor penandaColor = _parseHexColor(warnaHex);
  final bool tampilBulatan = warnaHex.toUpperCase() != '#FFFFFF';

  final pageFormat = pdf.PdfPageFormat(
    58 * pdf.PdfPageFormat.mm,
    double.infinity,
    marginAll: 4 * pdf.PdfPageFormat.mm,
  );

  final now = DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.now());

  doc.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (tampilBulatan)
            pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                color: penandaColor,
                shape: pw.BoxShape.circle,
              ),
            ),
          if (tampilBulatan) pw.SizedBox(height: 6),
          pw.SizedBox(height: 6),
          pw.Text('DISDUKCAPIL SULTENG',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Divider(thickness: .8),
          pw.SizedBox(height: 6),

          pw.Text(nomor,
              style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(layanan,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 10)),

          if (alasan.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('(Alasan: $alasan)',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 8)),
          ],

          pw.SizedBox(height: 8),
          pw.Divider(thickness: .5),
          pw.SizedBox(height: 4),
          pw.Text(now, style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(
    name: 'Tiket Antrian 58 mm',
    onLayout: (_) async => doc.save(),
  );
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