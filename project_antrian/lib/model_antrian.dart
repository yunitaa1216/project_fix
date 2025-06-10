class Antrian {
  final String nama;
  final String nik;
  final String keperluan;
  final String nomor;
  String status;
  final String? hp;       // tambahan
  final String? alamat;   // tambahan

  Antrian({
    required this.nama,
    required this.nik,
    required this.keperluan,
    required this.nomor,
    required this.status,
    this.hp,
    this.alamat,
  });
}
