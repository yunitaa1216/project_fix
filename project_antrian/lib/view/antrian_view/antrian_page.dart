import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:project_antrian/view/antrian_view/antrian_form.dart';
import 'package:project_antrian/view/antrian_view/antrian_table.dart';
import 'package:project_antrian/viewmodel/antrian_viewmodel.dart';
import 'package:project_antrian/widgets/responsive_layout.dart';
import 'package:project_antrian/widgets/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';


class AntrianPage extends StatefulWidget {
  final List<Map<String, String>> dataRiwayat;
  final Function(List<Map<String, String>>) onRiwayatUpdate;

  AntrianPage({required this.dataRiwayat, required this.onRiwayatUpdate});

  @override
  State<AntrianPage> createState() => _AntrianPageState();
}

class _AntrianPageState extends State<AntrianPage> {
  final FlutterTts flutterTts = FlutterTts();
  String currentPage = 'Beranda';
  // final viewModel = Provider.of<AntrianViewModel>(context, listen: false);
  
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController nomorHpController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  
  String selectedKategori = 'umum';
String selectedLayanan = 'pembuatan ktp';
String? selectedReason; 

  List<Map<String, String>> dataAntrian = [];
  late List<Map<String, String>> dataRiwayat;
  final FocusNode namaFocus = FocusNode();
final FocusNode nikFocus = FocusNode();
final FocusNode alamatFocus = FocusNode();
final FocusNode nomorHpFocus = FocusNode();
late AntrianViewModel viewModel;
final List<String> alasanKTP = [              // ⬅️  NEW
    'Perubahan Data',
    'Rusak',
    'Hilang',
    'Luar Daerah',
  ];

String _namaBulanIndonesia(int bulan) {
  const bulanIndonesia = [
    '', // index ke-0 tidak digunakan
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  return bulanIndonesia[bulan];
}

  @override
  void initState() {
    super.initState();
    setVoice();
    final now = DateTime.now();
final formattedDate = "${now.day.toString().padLeft(2, '0')} "
    "${_namaBulanIndonesia(now.month)} "
    "${now.year}";
tanggalController.text = formattedDate;

    dataRiwayat = widget.dataRiwayat;
     viewModel = Provider.of<AntrianViewModel>(context, listen: false);
     Future.microtask(() async {
    await viewModel.loadAntrian();
    setState(() {
      dataAntrian = viewModel.antrian;
    });
  });
}

  @override
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    alamatController.dispose();
    nomorHpController.dispose();
    namaFocus.dispose();
  nikFocus.dispose();
  alamatFocus.dispose();
  nomorHpFocus.dispose();
  tanggalController.dispose();
    super.dispose();
  }

  Future<void> setVoice() async {
    List<dynamic> voices = await flutterTts.getVoices;
    final voice = voices.firstWhere(
      (v) => v.toString().contains('id-ID') && v.toString().toLowerCase().contains('female'),
      orElse: () => null,
    );

    if (voice != null) {
      await flutterTts.setVoice(voice);
    } else {
      await flutterTts.setLanguage("id-ID");
    }

    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.9);
  }

    void tambahAntrian() async {
  final dataUntukAPI = {
    'nama'         : namaController.text,
    'nik'          : nikController.text,
    'alamat'       : alamatController.text,
    'telepon'      : nomorHpController.text,
    'jenis_layanan': selectedLayanan.toLowerCase(),
    'kategori'     : selectedKategori.toLowerCase(),
    'reason'       : selectedReason ?? '',          // ← 1️⃣ kirim ke API
  };

  String? uuid = await viewModel.tambahAntrianAPI(
    nama: dataUntukAPI['nama']!,
    nik: dataUntukAPI['nik']!,
    alamat: dataUntukAPI['alamat']!,
    telepon: dataUntukAPI['telepon']!,
    jenisLayanan: dataUntukAPI['jenis_layanan']!,
    kategori: dataUntukAPI['kategori']!,
    reason     : dataUntukAPI['reason']!,
  );

  if (uuid != null) {
    setState(() {
      dataAntrian.add({
        'uuid': uuid,
        'nama': dataUntukAPI['nama']!,
        'nik': dataUntukAPI['nik']!,
        'alamat': dataUntukAPI['alamat']!,
        'layanan': dataUntukAPI['jenis_layanan']!,
        'noHp': dataUntukAPI['telepon']!,
        'kategori': dataUntukAPI['kategori']!,
        'tanggal' : tanggalController.text, 
        'reason'  : selectedReason ?? '', 
        'status': 'Menunggu',
      });
      selectedReason = null; 
      namaController.clear();
      nikController.clear();
      alamatController.clear();
      nomorHpController.clear();
      selectedLayanan = 'pembuatan ktp';
      selectedKategori = 'umum';
      selectedReason   = null; 
    });
  } else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: const [
          Icon(Icons.error_outline, color: Color(0xFF292794)),
          SizedBox(width: 12),
          Expanded(child: Text('Gagal menambahkan antrian ke server')),
        ],
      ),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: Duration(seconds: 3),
    ),
  );
}
}



  Future<void> panggilAntrian(int nomor, String nama, String kategori) async {
    int loket = kategori.toLowerCase() == 'prioritas' ? 2 : 1;
    String pesan = "Antrian atas nama $nama, silakan ke loket $loket";
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(pesan);
  }

  Future<void> _printTicket(Map<String, String> item) async {
  final doc = pw.Document();
  final now = DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.now());

  doc.addPage(
    pw.Page(
      build: (context) => pw.Center(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(24),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 2),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text('DISDUKCAPIL SULTENG',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Text(
                  item['nomor'] ??
                      item['uuid']!.substring(0, 6).toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 32, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(item['layanan']!.toUpperCase(),
                  style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 12),
              pw.Text(now, style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => doc.save());
}

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      isAntrianPage: true,
      mobileBody: Scaffold(
        drawer: Drawer(
  child: Sidebar(
    onItemSelected: (String page) {
      setState(() => currentPage = page);

      switch (page) {
        case 'Beranda':
          Navigator.pushReplacementNamed(context, '/beranda');
          break;
        case 'Input Antrian':
          Navigator.pushReplacementNamed(context, '/antrian');
          break;
        case 'Daftar Antrian':
          Navigator.pushReplacementNamed(context, '/antriannew');
          break;
        case 'Riwayat':
          Navigator.pushReplacementNamed(context, '/riwayat');
          break;
        case 'Logout':
          Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
          break;
      }
    },
  ),
        ),
        appBar: AppBar(
          backgroundColor: Color(0xFF292794),
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Antrian',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: buildMainContent(),
        ),
      ),
      desktopBody: Scaffold(
  body: Row(
    children: [
      Sidebar(
  onItemSelected: (String page) {
    setState(() => currentPage = page);

    switch (page) {
      case 'Beranda':
        Navigator.pushReplacementNamed(context, '/beranda');
        break;
      case 'Input Antrian':
        Navigator.pushReplacementNamed(context, '/antrian');
        break;
      case 'Daftar Antrian':
        Navigator.pushReplacementNamed(context, '/antriannew');
        break;
      case 'Riwayat':
        Navigator.pushReplacementNamed(context, '/riwayat');
        break;
      case 'Logout':
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
        break;
    }
  },
),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          child: buildMainContent(),
        ),
      ),
    ],
  ),
),

    );
  }

  Widget buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'INPUT ANTRIAN',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF292794),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          AntrianForm(
            namaController: namaController,
            nikController: nikController,
            alamatController: alamatController,
            nomorHpController: nomorHpController,
            tanggalController: tanggalController,
            selectedLayanan: selectedLayanan,
            selectedKategori: selectedKategori,
            onLayananChanged: (val) => setState(() => selectedLayanan = val!),
            onKategoriChanged: (val) => setState(() => selectedKategori = val!),
            onTambahPressed: tambahAntrian,
            namaFocus: namaFocus,
  nikFocus: nikFocus,
  alamatFocus: alamatFocus,
  nomorHpFocus: nomorHpFocus,
          ),
          
        ],
      ),
    );
  }
}