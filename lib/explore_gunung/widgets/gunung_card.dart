import 'package:flutter/material.dart';

class GunungCard extends StatelessWidget {
  final String namaGunung;
  final String ketinggian;
  final String lokasi;
  final String imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GunungCard({
    super.key,
    required this.namaGunung,
    required this.ketinggian,
    required this.lokasi,
    required this.imageUrl,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Memberikan efek bayangan
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Sudut membulat
        side: const BorderSide(color: Color.fromARGB(255, 5, 100, 8), width: 1.5), // Border biru sesuai sketsa
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Bagian Foto Gunung (Kiri)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(imageUrl)}',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 16), // Jarak antara foto dan teks

            // 2. Bagian Informasi Text (Tengah)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    namaGunung,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ketinggian: $ketinggian",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  Text(
                    "Lokasi: $lokasi",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // 3. Bagian Tombol Aksi (Kanan)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Edit (Lingkaran)
                _buildCircleButton(
                  icon: Icons.edit,
                  color: Color.fromARGB(255, 5, 100, 8),
                  onPressed: onEdit,
                ),
                const SizedBox(width: 8),
                // Tombol Delete (Lingkaran)
                _buildCircleButton(
                  icon: Icons.delete,
                  color: Colors.red,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat tombol bulat kecil
  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color),
          color: color.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }
}