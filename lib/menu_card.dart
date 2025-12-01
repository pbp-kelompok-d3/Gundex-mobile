import 'package:flutter/material.dart';
import 'package:gundex_mobile/menu.dart';
import 'package:gundex_mobile/wishlist/screens/wishlist_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MenuCard extends StatelessWidget {
  final MenuItem item;

  const MenuCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _handleMenuTap(context, request);
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color,
                item.color.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuTap(BuildContext context, CookieRequest request) {
    // Show snackbar
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Kamu menekan tombol ${item.name}'),
          duration: const Duration(seconds: 2),
        ),
      );

    // Handle navigation based on menu name
    switch (item.name) {
      case 'Wishlist':
        // Check if user is logged in
        if (!request.loggedIn) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Silakan login terlebih dahulu untuk mengakses Wishlist'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          return;
        }
        
        // Navigate to Wishlist page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WishlistPage(),
          ),
        );
        break;

      case 'Explore Gunung':
        // TODO: Navigate to Explore page when ready
        break;

      case 'Artikel':
        // TODO: Navigate to Artikel page when ready
        break;

      case 'Log Pendakian':
        // TODO: Navigate to Log Pendakian page when ready
        break;

      case 'Profile':
        // TODO: Navigate to Profile page when ready
        break;

      default:
        break;
    }
  }
}