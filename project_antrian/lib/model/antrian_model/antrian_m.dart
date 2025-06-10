class AntrianModel {
  final String nama;
  final String nik;
  final String alamat;
  final String layanan;
  final String noHp;
  final String kategori;
  final String status;

  AntrianModel({
    required this.nama,
    required this.nik,
    required this.alamat,
    required this.layanan,
    required this.noHp,
    required this.kategori,
    required this.status,
  });

  factory AntrianModel.fromJson(Map<String, dynamic> json) {
    return AntrianModel(
      nama: json['nama'] ?? '',
      layanan: json['layanan'] ?? '',
      nik: json['nik'] ?? '',
      alamat: json['alamat'] ?? '',
      kategori: json['kategori'] ?? '',
      noHp: json['noHp'] ?? '',
      status: json['status'] ?? 'Menunggu',
    );
  }

  Map<String, String> toMap() {
    return {
      'nama': nama,
      'layanan': layanan,
      'kategori': kategori,
      'noHp': noHp,
      'status': status,
    };
  }
}