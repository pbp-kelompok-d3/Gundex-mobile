import 'package:flutter/material.dart';
import 'package:gundex_mobile/left_drawer.dart';
import 'package:gundex_mobile/menu_card.dart';
import 'package:gundex_mobile/userprofile/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Menu items for the home page
    final List<MenuItem> items = [
      MenuItem(
        name: "Explore Gunung",
        icon: Icons.terrain,
        color: const Color(0xFF87A330), // Olive green
      ),
      MenuItem(
        name: "Artikel",
        icon: Icons.article,
        color: const Color(0xFFA1C349), // Android green
      ),
      MenuItem(
        name: "Log Pendakian",
        icon: Icons.hiking,
        color: const Color(0xFFCAD593), // Sage green
      ),
      MenuItem(
        name: "Wishlist",
        icon: Icons.favorite,
        color: const Color(0xFF2A3C24), // Pine tree green
      ),
      MenuItem(
        name: "Profile",
        icon: Icons.person,
        color: const Color(0xFF87A330), // Olive green
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'Gun',
                style: TextStyle(color: Color(0xFF87A330)),
              ),
              TextSpan(
                text: 'Dex',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF243010), // Dark moss green
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Show Login button if not logged in
          if (!request.loggedIn)
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const LeftDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF243010), // Dark moss green
              Colors.green.shade700,
              Colors.green.shade500,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.terrain,
                      size: 80,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'Gun',
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                          const TextSpan(
                            text: 'Dex',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hike More and Get More',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Section Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Explore Features',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Menu Grid
              GridView.count(
                primary: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: items.map((item) {
                  return MenuCard(item: item);
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Info Cards
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About GunDex',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'GunDex is your ultimate companion for exploring Indonesia\'s beautiful mountains. Track your hikes, discover new peaks, read articles, and connect with the hiking community.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// MenuItem model
class MenuItem {
  final String name;
  final IconData icon;
  final Color color;

  MenuItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}