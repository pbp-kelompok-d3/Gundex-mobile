import 'package:flutter/material.dart';
import 'package:gundex_mobile/wishlist/models/wishlist_item.dart';
import 'package:gundex_mobile/wishlist/widgets/wishlist_card.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final List<WishlistItem> _items = [
    WishlistItem(
      id: 1,
      gunungNama: "Gunung Semeru",
      gunungLokasi: "Jawa Timur",
      gunungKetinggian: 3676,
      gunungFoto: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Gunung_Semeru_Mahameru.jpg/1200px-Gunung_Semeru_Mahameru.jpg",
      addedAt: DateTime.now(),
    ),
    WishlistItem(
      id: 2,
      gunungNama: "Gunung Rinjani",
      gunungLokasi: "Nusa Tenggara Barat",
      gunungKetinggian: 3726,
      gunungFoto: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Rinjani_Caldera.jpg/1200px-Rinjani_Caldera.jpg",
      addedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Warna Utama
    const Color primaryColor = Color(0xFF87A330);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2), // Warna background abu-kehijauan sangat muda
      appBar: AppBar(
        title: const Text(
          'Wishlist Saya',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _items.isEmpty
          ? _buildEmptyState(primaryColor) // Tampilan jika kosong
          : ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return WishlistCard(
                  item: _items[index],
                  onPressed: () {
                    // Placeholder aksi hapus (Week 3)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fitur hapus akan hadir di Week 3!")),
                    );
                  },
                );
              },
            ),
    );
  }

  // Widget khusus untuk tampilan kosong (Rapi & Informatif)
  Widget _buildEmptyState(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.landscape_rounded, size: 100, color: color.withOpacity(0.5)),
          const SizedBox(height: 20),
          const Text(
            "Wishlist Kosong",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          const Text(
            "Kamu belum menyimpan pendakian impianmu.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Kembali ke menu utama
            },
            icon: Icon(Icons.explore, color: color),
            label: Text("Jelajahi Gunung", style: TextStyle(color: color)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          )
        ],
      ),
    );
  }
}