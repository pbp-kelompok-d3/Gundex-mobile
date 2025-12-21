import 'package:gundex_mobile/wishlist/models/wishlist_item.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';

class WishlistService {
  static const String baseUrl = 'https://rasyad-zulham-gundex.pbp.cs.ui.ac.id/';

  // Fetch wishlist user yang sedang login
  // Returns List<WishlistItem> with full gunung data
  static Future<List<WishlistItem>> fetchWishlist(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/wishlist/flutter/json/');

      if (response['status'] == true) {
        List<WishlistItem> wishlistItems = [];
        for (var item in response['data']) {
          wishlistItems.add(WishlistItem.fromJson(item));
        }
        return wishlistItems;
      } else {
        throw Exception(response['message'] ?? 'Failed to load wishlist');
      }
    } catch (e) {
      throw Exception('Failed to load wishlist: $e');
    }
  }

  // Add gunung to wishlist
  // Returns Map with status and message
  static Future<Map<String, dynamic>> addToWishlist(
    CookieRequest request,
    String gunungId,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl/wishlist/flutter/add/',
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
  // Returns Map with status and message
  static Future<Map<String, dynamic>> removeFromWishlist(
    CookieRequest request,
    int itemId,
  ) async {
    try {
      final response = await request.post(
        '$baseUrl/wishlist/flutter/remove/$itemId/',
        {},
      );

      return response;
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  // Check if a gunung is in user's wishlist
  // Returns bool
  static Future<bool> checkWishlistStatus(
    CookieRequest request,
    String gunungId,
  ) async {
    try {
      final response = await request.get(
        '$baseUrl/wishlist/flutter/check/$gunungId/',
      );

      return response['in_wishlist'] ?? false;
    } catch (e) {
      // If error, assume not in wishlist
      return false;
    }
  }
}