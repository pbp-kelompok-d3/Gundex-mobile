import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'menu.dart';
import 'artikel/screens/artikel_list_page.dart';

void main() {
  runApp(const GunDexApp());
}

class GunDexApp extends StatelessWidget {
  const GunDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'GunDex Mobile',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        ),
        home: const ArtikelListPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
