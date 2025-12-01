// To parse this JSON data, do
//
//     final gunung = gunungFromJson(jsonString);

import 'dart:convert';

List<Gunung> gunungFromJson(String str) => List<Gunung>.from(json.decode(str).map((x) => Gunung.fromJson(x)));

String gunungToJson(List<Gunung> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Gunung {
    String id;
    String nama;
    int ketinggian;
    String provinsi;
    String? foto;
    String deskripsi;

    Gunung({
        required this.id,
        required this.nama,
        required this.ketinggian,
        required this.provinsi,
        this.foto,
        required this.deskripsi,
    });

    factory Gunung.fromJson(Map<String, dynamic> json) => Gunung(
        id: json["id"],
        nama: json["nama"],
        ketinggian: json["ketinggian"],
        provinsi: json["provinsi"],
        foto: json["foto"],
        deskripsi: json["deksripsi"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "ketinggian": ketinggian,
        "provinsi": provinsi,
        "foto": foto,
        "deksripsi": deskripsi,
    };
}