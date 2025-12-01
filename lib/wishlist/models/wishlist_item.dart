class WishlistItem {
  final int id;
  final String gunungNama;
  final String gunungLokasi;
  final int gunungKetinggian;
  final String gunungFoto; // URL foto
  final DateTime addedAt;

  WishlistItem({
    required this.id,
    required this.gunungNama,
    required this.gunungLokasi,
    required this.gunungKetinggian,
    required this.gunungFoto,
    required this.addedAt,
  });
}