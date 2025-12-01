import 'package:flutter/material.dart';
import 'package:gundex_mobile/menu.dart';
import 'package:gundex_mobile/wishlist/screens/wishlist_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF243010),
              Colors.green.shade700,
              Colors.green.shade500,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.terrain,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Gun',
                          style: TextStyle(color: Color(0xFFCAD593)),
                        ),
                        TextSpan(
                          text: 'Dex',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hike More and Get More',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.home,
              title: 'Halaman Utama',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.terrain,
              title: 'Explore Gunung',
              onTap: () {
                // TODO: Navigate to Explore page
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Halaman Explore Gunung akan segera hadir'),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.article,
              title: 'Artikel',
              onTap: () {
                // TODO: Navigate to Artikel page
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Halaman Artikel akan segera hadir'),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.hiking,
              title: 'Log Pendakian',
              onTap: () {
                // TODO: Navigate to Log Pendakian page
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Halaman Log Pendakian akan segera hadir'),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.favorite,
              title: 'Wishlist',
              subtitle: request.loggedIn ? null : 'Login required',
              onTap: () {
                if (!request.loggedIn) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Silakan login terlebih dahulu'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WishlistPage(),
                  ),
                );
              },
            ),
            const Divider(color: Colors.white30),
            _buildDrawerItem(
              context: context,
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                // TODO: Navigate to Profile page
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Halaman Profile akan segera hadir'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            )
          : null,
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}