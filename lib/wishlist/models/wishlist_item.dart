import 'dart:convert';

/// Parse list of wishlist items from JSON string
List<WishlistItem> wishlistItemFromJson(String str) {
  final jsonData = json.decode(str);
  return List<WishlistItem>.from(jsonData['data'].map((x) => WishlistItem.fromJson(x)));
}

String wishlistItemToJson(List<WishlistItem> data) {
  return json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}

class WishlistItem {
  int id;
  String addedAt;
  WishlistGunung gunung;

  WishlistItem({
    required this.id,
    required this.addedAt,
    required this.gunung,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        id: json["id"],
        addedAt: json["added_at"],
        gunung: WishlistGunung.fromJson(json["gunung"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "added_at": addedAt,
        "gunung": gunung.toJson(),
      };
}

class WishlistGunung {
  String id;
  String nama;
  int ketinggian;
  String provinsi;
  String foto;
  String deskripsi;

  WishlistGunung({
    required this.id,
    required this.nama,
    required this.ketinggian,
    required this.provinsi,
    required this.foto,
    required this.deskripsi,
  });

  factory WishlistGunung.fromJson(Map<String, dynamic> json) => WishlistGunung(
        id: json["id"],
        nama: json["nama"],
        ketinggian: json["ketinggian"],
        provinsi: json["provinsi"],
        foto: json["foto"] ?? '',
        deskripsi: json["deskripsi"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "ketinggian": ketinggian,
        "provinsi": provinsi,
        "foto": foto,
        "deskripsi": deskripsi,
      };
}