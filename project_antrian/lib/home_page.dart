// import 'package:project_antrian/dropdown.dart';
// import 'package:project_antrian/form_field.dart';
// import 'package:project_antrian/viewmodel/antrian_viewmodel.dart';
// import 'package:project_antrian/widgets/sidebar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import '../widgets/sidebar_item.dart';
// // import '../widgets/form_field.dart';
// // import '../widgets/dropdown_field.dart';

// class AntrianPage extends StatefulWidget {
//   final List<Map<String, String>> dataRiwayat;
//   final Function(List<Map<String, String>>) onRiwayatUpdate;

//   AntrianPage({required this.dataRiwayat, required this.onRiwayatUpdate});

//   @override
//   State<AntrianPage> createState() => _AntrianPageState();
// }

// class _AntrianPageState extends State<AntrianPage> {
//   final FlutterTts flutterTts = FlutterTts();
//   String currentPage = 'Beranda';
//   late AntrianViewModel viewModel;
  
//   final TextEditingController namaController = TextEditingController();
//   final TextEditingController nikController = TextEditingController();
//   final TextEditingController alamatController = TextEditingController();
//   // final TextEditingController layananController = TextEditingController();

//   final TextEditingController nomorHpController = TextEditingController();
//   String selectedKategori = 'Umum';

//   List<Map<String, String>> dataAntrian = [];
//   late List<Map<String, String>> dataRiwayat;

//   @override
// void initState() {
//   super.initState();
//   setVoice();
//   dataRiwayat = widget.dataRiwayat;
//   viewModel = AntrianViewModel();
// }

//   @override
// void dispose() {
//   namaController.dispose();
//   nikController.dispose();
//   alamatController.dispose();
//   nomorHpController.dispose();

//   namaFocus.dispose();
//   nikFocus.dispose();
//   alamatFocus.dispose();
//   layananFocus.dispose();
//   nohpFocus.dispose();
//   kategoriFocus.dispose();

//   super.dispose();
// }

//   void tambahAntrian() async {
//   bool sukses = await viewModel.tambahAntrianAPI(
//     nama: namaController.text,
//     nik: nikController.text,
//     alamat: alamatController.text,
//     telepon: nomorHpController.text,
//     jenisLayanan: selectedLayanan,
//     kategori: selectedKategori,
//   );

//   if (sukses) {
//     setState(() {
//       dataAntrian.add({
//         'nama': namaController.text,
//         'nik': nikController.text,
//         'alamat': alamatController.text,
//         'layanan': selectedLayanan,
//         'noHp': nomorHpController.text,
//         'kategori': selectedKategori,
//         'status': 'Menunggu',
//       });

//       namaController.clear();
//       nikController.clear();
//       alamatController.clear();
//       nomorHpController.clear();
//       selectedLayanan = 'Pembuatan KTP';
//       selectedKategori = 'Umum';
//     });
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Gagal menambahkan antrian ke server'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }


//   Future<void> panggilAntrian(int nomor, String nama, String kategori) async {
//     int loket = kategori.toLowerCase() == 'khusus' ? 2 : 1;
//     String pesan =
//         "Antrian nomor $nomor, atas nama $nama, silakan ke loket $loket";
//     await flutterTts.setLanguage("id-ID");
//     await flutterTts.setPitch(1.0);
//     await flutterTts.speak(pesan);
//   }

//   List<String> jenisLayananList = [
//   'Pembuatan KTP',
//   'Perubahan KK',
//   'Akta Kelahiran',
//   'Akta Kematian',
//   'Pindah Domisili',
//   'Layanan Lainnya'
// ];

// String selectedLayanan = 'Pembuatan KTP';

// final FocusNode namaFocus = FocusNode();
// final FocusNode nikFocus = FocusNode();
// final FocusNode alamatFocus = FocusNode();
// final FocusNode layananFocus = FocusNode();
// final FocusNode nohpFocus = FocusNode();
// final FocusNode kategoriFocus = FocusNode();

// Future<void> setVoice() async {
//   List<dynamic> voices = await flutterTts.getVoices;

//   // Cari voice dengan bahasa Indonesia dan yang terdengar seperti perempuan
//   final voice = voices.firstWhere(
//     (v) =>
//         v.toString().contains('id-ID') &&
//         v.toString().toLowerCase().contains('female'),
//     orElse: () => null,
//   );

//   if (voice != null) {
//     await flutterTts.setVoice(voice);
//   } else {
//     // fallback: atur bahasa Indonesia saja
//     await flutterTts.setLanguage("id-ID");
//   }

//   await flutterTts.setPitch(1.0); // Nada standar
//   await flutterTts.setSpeechRate(0.9); // Lebih natural
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: LayoutBuilder(
//   builder: (context, constraints) {
//     bool isMobile = constraints.maxWidth < 768;

//     return isMobile
//         ? Scaffold(
//             drawer: Drawer(
//               child: Sidebar(
//   onItemSelected: (page) {
//     Navigator.pop(context); // Tutup drawer jika mobile
//     switch (page) {
//       case 'Beranda':
//         Navigator.pushReplacementNamed(context, '/beranda');
//         break;
//       case 'Antrian':
//         Navigator.pushReplacementNamed(context, '/antrian');
//         break;
//       case 'Riwayat':
//         Navigator.pushReplacementNamed(context, '/riwayat');
//         break;
//       case 'Logout':
//         Navigator.pushReplacementNamed(context, '/');
//         break;
//     }
//   },
// ),
//             ),
//             appBar: AppBar(
//               backgroundColor: Color(0xFF292794),
//               iconTheme: IconThemeData(color: Colors.white),
//               title: Text(
//                 'Antrian',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//               // elevation: 0,
//             ),
//             body: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//               child: buildMainContent(), // ⬅️ dipindah ke method khusus
//             ),
//           )
//         : Row(
//             children: [
//               Sidebar(
//   onItemSelected: (page) {
//     Navigator.pop(context); // Tutup drawer jika mobile
//     switch (page) {
//       case 'Beranda':
//         Navigator.pushReplacementNamed(context, '/beranda');
//         break;
//       case 'Antrian':
//         Navigator.pushReplacementNamed(context, '/antrian');
//         break;
//       case 'Riwayat':
//         Navigator.pushReplacementNamed(context, '/riwayat');
//         break;
//       case 'Logout':
//         Navigator.pushReplacementNamed(context, '/');
//         break;
//     }
//   },
// ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
//                   child: buildMainContent(),
//                 ),
//                     ),
//                   ],
//                 );
//         },
//       ),
//     );
//   }

//     Widget buildMainContent() {
//   return SingleChildScrollView(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Align(
//   alignment: Alignment.centerLeft,
//   child: Text(
//                     'INPUT ANTRIAN',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF292794),
//                       letterSpacing: 1.5,
//                     ),
//                   ),
// ),
//                     const SizedBox(height: 16),

//                     // Form Card
//                    Card(
//                     color: Colors.white,
//   elevation: 3,
//   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   child: Padding(
//     padding: const EdgeInsets.all(10.0),
//     child: LayoutBuilder(
//       builder: (context, constraints) {
//         final isWide = constraints.maxWidth > 600;
//         return GridView.count(
//           crossAxisCount: isWide ? 2 : 1,
//           crossAxisSpacing: 5.0,
//           mainAxisSpacing: 5.0,
//           shrinkWrap: true,
//           childAspectRatio: 6,
//           physics: NeverScrollableScrollPhysics(),
//           children: [
//             buildTextField(
//   'Nama Lengkap',
//   namaController,
//   hint: 'Masukkan nama sesuai KTP',
//   icon: Icons.person,
//   focusNode: namaFocus,
//   onSubmitted: () => FocusScope.of(context).requestFocus(nikFocus),
// ),
//             buildTextField(
//   'NIK',
//   nikController,
//   hint: 'Nomor Induk Kependudukan',
//   icon: Icons.credit_card,
//   focusNode: nikFocus,
//   onSubmitted: () => FocusScope.of(context).requestFocus(alamatFocus),
// ),
// buildTextField(
//   'Alamat',
//   alamatController,
//   hint: 'Alamat sesuai domisili',
//   icon: Icons.home,
//   focusNode: alamatFocus,
//   onSubmitted: () => FocusScope.of(context).unfocus(), // Atau pindah ke dropdown
// ),
//             buildDropdown(
//   'Jenis Layanan',
//   jenisLayananList,
//   selectedLayanan,
//   (val) => setState(() {
//     selectedLayanan = val!;
//   }),
//   icon: Icons.assignment,
// ),
//             buildTextField(
//   'Nomor HP',
//   nomorHpController,
//   hint: 'Contoh: 081234567890',
//   icon: Icons.phone,
//   focusNode: null,
// ),
//             buildDropdown(
//               'Kategori Antrian',
//               ['Umum', 'Khusus'],
//               selectedKategori,
//               (val) => setState(() {
//                 selectedKategori = val!;
//               }),
//               icon: Icons.group,
//             ),
//           ],
//         );
//       },
//     ),
//   ),
// ),
//                     const SizedBox(height: 20),
//                     Align(
//   alignment: Alignment.centerLeft,
//   child: ElevatedButton(
//     onPressed: tambahAntrian,
//     style: ElevatedButton.styleFrom(
//       backgroundColor: const Color(0xFFEFEF2A), // Kuning cerah
//       foregroundColor: const Color(0xFF292794), // Warna teks ungu
//       padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//         // side: const BorderSide(color: Color(0xFF292794), width: 1.5),
//       ),
//       elevation: 4,
//       shadowColor: Colors.black26,
//     ),
//     child: const Text(
//       'Tambah',
//       style: TextStyle(
//         fontWeight: FontWeight.bold,
//         letterSpacing: 1.0,
//         fontSize: 16,
//       ),
//     ),
//   ),
// ),

//                     const SizedBox(height: 40),
//                     Align(
//   alignment: Alignment.centerLeft,
//   child: Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Icon(Icons.list_alt, color: Color(0xFF292794)),
//       SizedBox(width: 8),
//       Text(
//         'Antrian Saat Ini',
//         style: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Color(0xFF292794),
//           letterSpacing: 1.0,
//           shadows: [
//             Shadow(
//               color: Colors.black12,
//               offset: Offset(1, 1),
//               blurRadius: 2,
//             ),
//           ],
//         ),
//       ),
//     ],
//   ),
// ),
// const SizedBox(height: 12),
// Card(
//   color: Colors.white,
//   elevation: 4,
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(12),
//   ),
//   child: LayoutBuilder(
//     builder: (context, constraints) {
//       bool isMobile = constraints.maxWidth < 800;

//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(12.0),
//         child: isMobile
//             ? SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: IntrinsicWidth(
//                   child: _buildDataTable(),
//                 ),
//               )
//             : _buildDataTable(), // tampilkan penuh tanpa scroll di web
//       );
//     },
//   ),
// )

//                   ],
//                 ),
//   );
//   }

//   Widget _buildDataTable() {
//   return DataTable(
//     headingRowColor: MaterialStateProperty.all(Color(0xFFFFFFFF)),
//     columnSpacing: 24,
//     horizontalMargin: 16,
//     dividerThickness: 0.8,
//     headingTextStyle: TextStyle(
//       fontWeight: FontWeight.w700,
//       color: Color(0xFF292794),
//     ),
//     dataTextStyle: TextStyle(
//       fontSize: 14,
//       color: Color(0xFF292794),
//     ),
//     columns: [
//       DataColumn(label: Text('No')),
//       DataColumn(label: Text('Nama')),
//       DataColumn(label: Text('Jenis Layanan')),
//       DataColumn(label: Text('Kategori')),
//       DataColumn(label: Text('No HP')),
//       DataColumn(label: Text('Status')),
//       DataColumn(label: Text('Aksi')),
//     ],
//     rows: List.generate(
//       dataAntrian.length,
//       (index) => DataRow(
//         cells: [
//           DataCell(Text('${index + 1}')),
//           DataCell(Text(dataAntrian[index]['nama'] ?? '')),
//           DataCell(Text(dataAntrian[index]['layanan'] ?? '')),
//           DataCell(Text(dataAntrian[index]['kategori'] ?? '')),
//           DataCell(Text(dataAntrian[index]['noHp'] ?? '')),
//           DataCell(
//             DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: dataAntrian[index]['status'],
//                 iconEnabledColor: Color(0xFF292794),
//                 dropdownColor: Color(0xFFEAEAFF),
//                 style: const TextStyle(
//                   color: Color(0xFF292794),
//                   fontWeight: FontWeight.w500,
//                 ),
//                 onChanged: (newStatus) {
//                   setState(() {
//                     if (newStatus == 'Selesai') {
//                       dataAntrian[index]['status'] = 'Selesai';
//                       dataRiwayat.add(dataAntrian[index]);
//                       widget.onRiwayatUpdate(dataRiwayat);
//                       dataAntrian.removeAt(index);
//                     } else {
//                       dataAntrian[index]['status'] = newStatus!;
//                     }
//                   });
//                 },
//                 items: ['Menunggu', 'Dalam Proses', 'Selesai']
//                     .map((status) => DropdownMenuItem<String>(
//                           value: status,
//                           child: Text(status),
//                         ))
//                     .toList(),
//               ),
//             ),
//           ),
//           DataCell(
//             IconButton(
//               icon: Icon(Icons.volume_up, color: Colors.deepPurple),
//               tooltip: 'Panggil Antrian',
//               onPressed: () {
//                 panggilAntrian(
//                   index + 1,
//                   dataAntrian[index]['nama'] ?? '',
//                   dataAntrian[index]['kategori'] ?? 'Umum',
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget buildTextField(
//     String label,
//     TextEditingController controller, {
//     String? hint,
//     IconData? icon,
//     FocusNode? focusNode,
//     Function()? onSubmitted,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextField(
//         controller: controller,
//         focusNode: focusNode,
//         onSubmitted: (_) => onSubmitted?.call(),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Color(0xFF292794)),
//           hintText: hint,
//           hintStyle: const TextStyle(color: Color.fromARGB(255, 177, 208, 241)),
//           prefixIcon: icon != null ? Icon(icon, color: Color(0xFF292794)) : null,
//           focusedBorder: OutlineInputBorder(
//             borderSide: const BorderSide(color: Color(0xFF292794), width: 2),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: const BorderSide(color: Color(0xFF292794)),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         ),
//         style: const TextStyle(color: Color(0xFF292794)),
//       ),
//     );
//   }

//   Widget buildDropdown(
//     String label,
//     List<String> items,
//     String? selectedValue,
//     Function(String?) onChanged, {
//     IconData? icon,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: InputDecorator(
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Color(0xFF292794)),
//           prefixIcon: icon != null ? Icon(icon, color: Color(0xFF292794)) : null,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Color(0xFF292794)),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Color(0xFF292794)),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Color(0xFF292794), width: 2),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           filled: false,
//         ),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             value: selectedValue,
//             isExpanded: true,
//             iconEnabledColor: Color(0xFF292794),
//             dropdownColor: Colors.white,
//             style: const TextStyle(color: Color(0xFF292794)),
//             items: items
//                 .map((item) => DropdownMenuItem<String>(
//                       value: item,
//                       child: Text(item),
//                     ))
//                 .toList(),
//             onChanged: onChanged,
//           ),
//         ),
//       ),
//     );
//   }
// }