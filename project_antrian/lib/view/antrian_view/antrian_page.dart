import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:project_antrian/view/antrian_view/antrian_form.dart';
import 'package:project_antrian/view/antrian_view/antrian_table.dart';
import 'package:project_antrian/viewmodel/antrian_viewmodel.dart';
import 'package:project_antrian/widgets/responsive_layout.dart';
import 'package:project_antrian/widgets/sidebar.dart';
import 'package:provider/provider.dart';
// import '../widgets/responsive_layout.dart';
// import '../widgets/antrian_form.dart';
// import '../widgets/antrian_data_table.dart';
// import '../models/antrian_model.dart';

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
  
  String selectedKategori = 'umum';
String selectedLayanan = 'pembuatan ktp';

  List<Map<String, String>> dataAntrian = [];
  late List<Map<String, String>> dataRiwayat;
  final FocusNode namaFocus = FocusNode();
final FocusNode nikFocus = FocusNode();
final FocusNode alamatFocus = FocusNode();
final FocusNode nomorHpFocus = FocusNode();
late AntrianViewModel viewModel;

  @override
  void initState() {
    super.initState();
    setVoice();
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
    'nama': namaController.text,
    'nik': nikController.text,
    'alamat': alamatController.text,
    'telepon': nomorHpController.text,
    'jenis_layanan': selectedLayanan.toLowerCase(),
    'kategori': selectedKategori.toLowerCase(),
  };

  String? uuid = await viewModel.tambahAntrianAPI(
    nama: dataUntukAPI['nama']!,
    nik: dataUntukAPI['nik']!,
    alamat: dataUntukAPI['alamat']!,
    telepon: dataUntukAPI['telepon']!,
    jenisLayanan: dataUntukAPI['jenis_layanan']!,
    kategori: dataUntukAPI['kategori']!,
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
        'status': 'Menunggu',
      });

      namaController.clear();
      nikController.clear();
      alamatController.clear();
      nomorHpController.clear();
      selectedLayanan = 'pembuatan ktp';
      selectedKategori = 'umum';
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

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      isAntrianPage: true,
      mobileBody: Scaffold(
        drawer: Drawer(child: Sidebar(onItemSelected: (String page) {
  setState(() {
    currentPage = page;
  });

  // Navigasi ke halaman lain jika diperlukan
  if (page == 'Beranda') {
    Navigator.pushReplacementNamed(context, '/beranda');
  } else if (page == 'Antrian') {
    Navigator.pushReplacementNamed(context, '/antrian');
  } else if (page == 'Riwayat') {
    Navigator.pushReplacementNamed(context, '/riwayat');
  }
})
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
      Sidebar(onItemSelected: (String page) {
  setState(() {
    currentPage = page;
  });

  // Navigasi ke halaman lain jika diperlukan
  if (page == 'Beranda') {
    Navigator.pushReplacementNamed(context, '/beranda');
  } else if (page == 'Antrian') {
    Navigator.pushReplacementNamed(context, '/antrian');
  } else if (page == 'Riwayat') {
    Navigator.pushReplacementNamed(context, '/riwayat');
  }
}),
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
          
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
          ),
          const SizedBox(height: 12),
          
          AntrianDataTable(
            dataAntrian: dataAntrian,
            dataRiwayat: dataRiwayat,
            onRiwayatUpdate: widget.onRiwayatUpdate,
            onPanggilAntrian: panggilAntrian,
            onStatusChanged: (index, newStatus) async {
  final uuid = dataAntrian[index]['uuid']!;
  final sukses = await viewModel.updateStatusAntrian(
    uuid: uuid,
    statusBaru: newStatus!,
  );

  if (sukses) {
    setState(() {
      if (newStatus == 'Selesai') {
        dataRiwayat.add(dataAntrian[index]);
        widget.onRiwayatUpdate(dataRiwayat);
        dataAntrian.removeAt(index);
      } else {
        dataAntrian[index]['status'] = newStatus!;
      }
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal mengupdate status')),
    );
  }
}
          ),
        ],
      ),
    );
  }
}