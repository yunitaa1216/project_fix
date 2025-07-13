class StatistikData {
  final int totalPengunjung;
  final int totalSelesai;

  // distribusi layanan
  final int ktp;
  final int kk;
  final int aktaKelahiran;
  final int aktaKematian;
  final int layananLainnya;   // ←  dipakai utk “Pelayanan KK/KTP”
  final int kia;
  final int skpwni;
  final int perekaman;

  StatistikData({
    required this.totalPengunjung,
    required this.totalSelesai,
    required this.ktp,
    required this.kk,
    required this.aktaKelahiran,
    required this.aktaKematian,
    required this.layananLainnya,
    required this.kia,
    required this.skpwni,
    required this.perekaman,
  });

  factory StatistikData.fromJson(Map<String, dynamic> json) {
    return StatistikData(
      totalPengunjung : json['total_pengunjung']  ?? 0,
      totalSelesai    : json['total_selesai']     ?? 0,
      ktp             : json['ktp']               ?? 0,
      kk              : json['kk']                ?? 0,
      aktaKelahiran   : json['akta_kelahiran']    ?? 0,
      aktaKematian    : json['akta_kematian']     ?? 0,
      layananLainnya  : json['layanan_lainnya']   ?? 0,
      kia             : json['kia']               ?? 0,
      skpwni          : json['skpwni']            ?? 0,
      perekaman       : json['perekaman']         ?? 0,
    );
  }
}
