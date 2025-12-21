import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/artikel.dart';

class ArtikelService {
  static const String baseUrl = 'http://localhost:8000';

  // ======================
  // GET LIST ARTIKEL (PUBLIC)
  // ======================
  static Future<List<Artikel>> fetchArtikelList(
    CookieRequest request,
  ) async {
    final response =
        await request.get('$baseUrl/artikel/api/artikel/');

    return response
        .map<Artikel>((e) => Artikel.fromJson(e))
        .toList();
  }

  // ======================
  // GET DETAIL ARTIKEL (LOGIN REQUIRED)
  // ======================
  static Future<Artikel> fetchArtikelDetail(
    CookieRequest request,
    String id,
  ) async {
    final response =
        await request.get('$baseUrl/artikel/api/artikel/$id/');

    if (response is Map && response['error'] == 'LOGIN_REQUIRED') {
      throw Exception('LOGIN_REQUIRED');
    }

    return Artikel.fromJson(response);
  }

  // ======================
  // LIKE / UNLIKE ARTIKEL (LOGIN REQUIRED)
  // ======================
  static Future<void> likeArtikel(
    CookieRequest request,
    String id,
  ) async {
    final response = await request.post(
      '$baseUrl/artikel/api/flutter/like-artikel/$id/',
      {},
    );

    if (response is Map && response['error'] == 'LOGIN_REQUIRED') {
      throw Exception('LOGIN_REQUIRED');
    }
  }

  // ======================
  // TAMBAH VIEW (LOGIN REQUIRED)
  // ======================
  static Future<void> addView(
    CookieRequest request,
    String id,
  ) async {
    await request.post(
      '$baseUrl/artikel/artikel/$id/view/',
      {},
    );
  }

  // ========================
  // ARTIKEL TERBARU (PUBLIC)
  // ========================
  static Future<List<Artikel>> fetchLatest(
    CookieRequest request,
  ) async {
    final response =
        await request.get('$baseUrl/artikel/api/latest/');

    return response
        .map<Artikel>((e) => Artikel.fromJson(e))
        .toList();
  }

  // ========================
  // ARTIKEL REKOMENDASI (PUBLIC)
  // ========================
  static Future<List<Artikel>> fetchRecommendations(
    CookieRequest request,
  ) async {
    final response =
        await request.get('$baseUrl/artikel/api/recommended/');

    return response
        .map<Artikel>((e) => Artikel.fromJson(e))
        .toList();
  }

  // ========================
  // ARTIKEL TERPOPULER (PUBLIC)
  // ========================
  static Future<List<Artikel>> fetchPopular(
    CookieRequest request,
  ) async {
    final response =
        await request.get('$baseUrl/artikel/api/popular/');

    return response
        .map<Artikel>((e) => Artikel.fromJson(e))
        .toList();
  }

  // ========================
  // ARTIKEL TERHANGAT (PUBLIC)
  // ========================
  static Future<List<Artikel>> fetchHottest(
    CookieRequest request,
  ) async {
    final response =
        await request.get('$baseUrl/artikel/api/hottest/');

    return response
        .map<Artikel>((e) => Artikel.fromJson(e))
        .toList();
  }
}
