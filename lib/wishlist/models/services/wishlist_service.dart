import 'package:gundex_mobile/wishlist/models/wishlist_item.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';

class WishlistService {
  // GANTI dengan URL Django Anda
  static const String baseUrl = 'http://localhost:8000';
  
  // Fetch wishlist user yang sedang login
  static Future<List<WishlistItem>> fetchWishlist(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/wishlist/json/');
      
      // Convert response to List<WishlistItem>
      List<WishlistItem> wishlistItems = [];
      for (var item in response) {
        wishlistItems.add(WishlistItem.fromJson(item));
      }
      
      return wishlistItems;
    } catch (e) {
      throw Exception('Failed to load wishlist: $e');
    }
  }

  // Add gunung to wishlist
  static Future<Map<String, dynamic>> addToWishlist(
    CookieRequest request,
    String gunungId,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl/wishlist/add/',
        jsonEncode({
          'gunung_id': gunungId,
        }),
      );
      
      return response;
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  // Remove item from wishlist
  static Future<Map<String, dynamic>> removeFromWishlist(
    CookieRequest request,
    int itemId,
  ) async {
    try {
      final response = await request.post(
        '$baseUrl/wishlist/remove/$itemId/',
        {},
      );
      
      return response;
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }
}