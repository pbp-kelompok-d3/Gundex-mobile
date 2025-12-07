import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../models/artikel.dart';

class ArtikelService {
  static const String baseUrl = 'http://localhost:8000';

  static Uri _uri(String p) => Uri.parse('$baseUrl$p');

  // ======================
  // GET LIST
  // ======================
  static Future<List<Artikel>> fetchArtikelList() async {
    final res = await http.get(_uri('/artikel/api/artikel/'));
    if (res.statusCode != 200) throw Exception('Gagal memuat artikel');

    final List data = jsonDecode(res.body);
    return data.map((e) => Artikel.fromJson(e)).toList();
  }

  // ======================
  // GET DETAIL
  // ======================
  static Future<Artikel> fetchArtikelDetail(String id) async {
    final res = await http.get(_uri('/artikel/api/artikel/$id/'));
    if (res.statusCode != 200) throw Exception('Gagal memuat detail');

    return Artikel.fromJson(jsonDecode(res.body));
  }

  // ======================
  // CREATE
  // ======================
  static Future<void> createArtikel({
    required String title,
    required String description,
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final req = http.MultipartRequest(
      'POST',
      _uri('/artikel/api/flutter/create/'),
    );

    req.fields['title'] = title;
    req.fields['description'] = description;

    // ANDROID / IOS
    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));
    }

    // WEB
    if (imageBytes != null && imageName != null) {
      req.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName,
        ),
      );
    }

    final resp = await http.Response.fromStream(await req.send());
    if (resp.statusCode != 201) throw Exception(resp.body);
  }

  // ======================
  // EDIT
  // ======================
  static Future<bool> editArtikel({
    required String id,
    required String title,
    required String description,
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final req = http.MultipartRequest(
      'POST',
      _uri('/artikel/api/flutter/$id/edit/'),
    );

    req.fields['title'] = title;
    req.fields['description'] = description;

    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    if (imageBytes != null && imageName != null) {
      req.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName,
        ),
      );
    }

    final resp = await http.Response.fromStream(await req.send());

    if (resp.statusCode == 200) {
      return true; // ← penting
    }
    return false;
  }

  // ======================
  // DELETE
  // ======================
  static Future<void> deleteArtikel(String id) async {
    final res = await http.delete(_uri('/artikel/api/flutter/$id/delete/'));

    if (res.statusCode != 200) throw Exception(res.body);
  }
}
