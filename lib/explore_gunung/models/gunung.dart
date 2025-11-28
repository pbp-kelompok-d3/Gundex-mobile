// To parse this JSON data, do
//
//     final gunung = gunungFromJson(jsonString);

import 'dart:convert';

Gunung gunungFromJson(String str) => Gunung.fromJson(json.decode(str));

String gunungToJson(Gunung data) => json.encode(data.toJson());

class Gunung {
    List<Result> results;

    Gunung({
        required this.results,
    });

    factory Gunung.fromJson(Map<String, dynamic> json) => Gunung(
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
    };
}

class Result {
    String id;
    String nama;
    int ketinggian;
    String foto;
    String provinsi;
    String deskripsi;

    Result({
        required this.id,
        required this.nama,
        required this.ketinggian,
        required this.foto,
        required this.provinsi,
        required this.deskripsi,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        nama: json["nama"],
        ketinggian: json["ketinggian"],
        foto: json["foto"],
        provinsi: json["provinsi"],
        deskripsi: json["deskripsi"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "ketinggian": ketinggian,
        "foto": foto,
        "provinsi": provinsi,
        "deskripsi": deskripsi,
    };
}
