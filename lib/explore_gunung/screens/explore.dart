import 'package:flutter/material.dart';
import 'package:gundex_mobile/explore_gunung/widgets/gunung_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Daftar Gunung")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Contoh penggunaan widget
              GunungCard(
                namaGunung: "Gunung Semeru",
                ketinggian: "3.676 mdpl",
                lokasi: "Jawa Timur",
                imageUrl: "https://picsum.photos/id/1018/200", // Placeholder gambar
                onEdit: () {
                  print("Tombol Edit ditekan");
                },
                onDelete: () {
                  print("Tombol Delete ditekan");
                },
              ),
              const SizedBox(height: 16),
              GunungCard(
                namaGunung: "Gunung Rinjani",
                ketinggian: "3.726 mdpl",
                lokasi: "Lombok",
                imageUrl: "https://picsum.photos/id/1036/200",
                onEdit: () {},
                onDelete: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}