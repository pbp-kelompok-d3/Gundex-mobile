import 'package:flutter/material.dart';
import 'package:gundex_mobile/wishlist/models/wishlist_item.dart';

class WishlistCard extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback onPressed; 

  // Palet Warna GunDex
  final Color darkGreen = const Color(0xFF2A3C24);
  final Color mediumGreen = const Color(0xFF87A330);

  const WishlistCard({
    super.key,
    required this.item,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // Memberikan efek bayangan
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Sudut membulat
      ),
      clipBehavior: Clip.antiAlias, // Agar gambar mengikuti sudut membulat
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Bagian Foto Gunung
          Stack(
            children: [
              Image.network(
                item.gunungFoto,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                  );
                },
              ),
              // Label "Wishlist" di pojok kanan atas
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: mediumGreen.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Saved",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          // 2. Bagian Informasi Text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Gunung
                Text(
                  item.gunungNama,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                
                // Lokasi & Ketinggian
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: mediumGreen),
                    const SizedBox(width: 4),
                    Text(
                      "${item.gunungLokasi} • ${item.gunungKetinggian} mdpl",
                      style: TextStyle(
                        color: mediumGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 24, thickness: 1), // Garis pemisah tipis

                // Tanggal & Tombol Hapus
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ditambahkan: ${item.addedAt.day}/${item.addedAt.month}/${item.addedAt.year}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    InkWell(
                      onTap: onPressed,
                      child: const Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          SizedBox(width: 4),
                          Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}