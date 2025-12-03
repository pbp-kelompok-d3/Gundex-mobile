import 'package:flutter/material.dart';
import 'package:gundex_mobile/explore_gunung/screens/explore.dart';
import 'package:gundex_mobile/menu.dart';
import 'package:gundex_mobile/userprofile/edit_profile.dart';
import 'package:gundex_mobile/userprofile/login.dart';
import 'package:gundex_mobile/userprofile/register.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  void _showLoginRequired(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: Text('You need to login to access $feature'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close drawer
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
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF243010), // Dark moss green
                  Color(0xFF87A330), // Olive green
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.terrain,
                  size: 60,
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
                        style: TextStyle(color: Color(0xFFA1C349)),
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
                    fontSize: 14,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: Color(0xFF87A330)),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.terrain, color: Color(0xFF87A330)),
            title: const Text('Explore Gunung'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExploreGunungScreen()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You pressed Explore Gunung'),
                  backgroundColor: Color(0xFF87A330),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined, color: Color(0xFF87A330)),
            title: const Text('Artikel'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Artikel page when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Artikel - Coming soon!'),
                  backgroundColor: Color(0xFF87A330),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.hiking, color: Color(0xFF87A330)),
            title: const Text('Log Pendakian'),
            onTap: () {
              if (!request.loggedIn) {
                _showLoginRequired(context, 'Log Pendakian');
              } else {
                Navigator.pop(context);
                // TODO: Navigate to Log Pendakian page when implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Log Pendakian - Coming soon!'),
                    backgroundColor: Color(0xFF87A330),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outline, color: Color(0xFF87A330)),
            title: const Text('Wishlist'),
            onTap: () {
              if (!request.loggedIn) {
                _showLoginRequired(context, 'Wishlist');
              } else {
                Navigator.pop(context);
                // TODO: Navigate to Wishlist page when implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wishlist - Coming soon!'),
                    backgroundColor: Color(0xFF87A330),
                  ),
                );
              }
            },
          ),
          const Divider(),
          
          // Conditional Profile/Login button
          if (request.loggedIn)
            ListTile(
              leading: const Icon(Icons.person_outline, color: Color(0xFF87A330)),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login, color: Color(0xFF87A330)),
              title: const Text('Login'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          
          // Conditional Logout/Register button
          if (request.loggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                final response = await request.logout(
                  "http://localhost:8000/userprofile/flutter/logout/",
                );

                if (context.mounted) {
                  if (response['status'] == true) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyHomePage(),
                      ),
                      (route) => false,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response['message'] ?? 'Logged out successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response['message'] ?? 'Logout failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.app_registration, color: Color(0xFF87A330)),
              title: const Text('Register'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}