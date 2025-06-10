class StatistikData {
  final int totalPengunjung;
  final int totalSelesai;
  final int ktp;
  final int aktaKelahiran;
  final int aktaKematian;
  final int kk;
  final int layananLainnya;

  StatistikData({
    required this.totalPengunjung,
    required this.totalSelesai,
    required this.ktp,
    required this.aktaKelahiran,
    required this.aktaKematian,
    required this.kk,
    required this.layananLainnya,
  });

  factory StatistikData.fromJson(Map<String, dynamic> json) {
    return StatistikData(
      totalPengunjung: json['total_pengunjung'] ?? 0,
      totalSelesai: json['total_selesai'] ?? 0,
      ktp: json['ktp'] ?? 0,
      aktaKelahiran: json['akta_kelahiran'] ?? 0,
      aktaKematian: json['akta_kematian'] ?? 0,
      kk: json['kk'] ?? 0,
      layananLainnya: json['layanan_lainnya'] ?? 0,
    );
  }
}
