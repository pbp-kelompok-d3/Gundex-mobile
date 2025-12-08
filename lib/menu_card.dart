import 'package:flutter/material.dart';
import 'package:gundex_mobile/explore_gunung/screens/explore.dart';
import 'package:gundex_mobile/menu.dart';
import 'package:gundex_mobile/userprofile/edit_profile.dart';
import 'package:gundex_mobile/log_pendakian/screens/lod_pendakian_list.dart';
import 'package:gundex_mobile/userprofile/login.dart';
import 'package:gundex_mobile/wishlist/screens/wishlist_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MenuCard extends StatelessWidget {
  final MenuItem item;

  const MenuCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Features that require login
          final requiresLogin = [
            "Log Pendakian",
            "Wishlist",
            "Profile"
          ];

          // Check if feature requires login and user is not logged in
          if (requiresLogin.contains(item.name) && !request.loggedIn) {
            // Show dialog and redirect to login
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Login Required'),
                content: Text('You need to login to access ${item.name}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
            return;
          }

          // Show snackbar
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text("You pressed ${item.name}"),
                backgroundColor: item.color,
                duration: const Duration(seconds: 2),
              ),
            );

          // Handle navigation
          if (item.name == "Profile") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfilePage(),
              ),
            );
          } else if (item.name == "Explore Gunung") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExploreGunungScreen(),
              ),
            );
          } else if (item.name == "Wishlist") {
            // Navigate to Wishlist
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WishlistPage(),
              ),
            );
          } else if (item.name == "Artikel") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Artikel - Coming soon!'),
                backgroundColor: Color(0xFFA1C349),
              ),
            );
          } else if (item.name == "Log Pendakian") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LogPendakianListPage(),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color,
                item.color.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: Colors.white,
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}