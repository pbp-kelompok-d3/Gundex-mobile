// To parse this JSON data, do
//
//     final wishlistItem = wishlistItemFromJson(jsonString);

import 'dart:convert';

List<WishlistItem> wishlistItemFromJson(String str) => List<WishlistItem>.from(json.decode(str).map((x) => WishlistItem.fromJson(x)));

String wishlistItemToJson(List<WishlistItem> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WishlistItem {
    int id;
    String gunungId;
    String gunungNama;
    String addedAt;

    WishlistItem({
        required this.id,
        required this.gunungId,
        required this.gunungNama,
        required this.addedAt,
    });

    factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        id: json["id"],
        gunungId: json["gunung_id"],
        gunungNama: json["gunung_nama"],
        addedAt: json["added_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "gunung_id": gunungId,
        "gunung_nama": gunungNama,
        "added_at": addedAt,
    };
}