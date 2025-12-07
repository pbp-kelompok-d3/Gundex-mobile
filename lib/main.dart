import 'package:flutter/material.dart';
import 'artikel/screens/artikel_list_page.dart';

void main() {
  runApp(const GunDexApp());
}

class GunDexApp extends StatelessWidget {
  const GunDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GunDex Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ArtikelListPage(),
    );
  }
}
