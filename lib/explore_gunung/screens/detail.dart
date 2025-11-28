import 'package:flutter/material.dart';
import 'package:gundex_mobile/explore_gunung/models/gunung.dart'; // Pastikan import model Result kamu

class GunungDetailScreen extends StatelessWidget {
  final Result gunung;

  const GunungDetailScreen({super.key, required this.gunung});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gunung.nama),
        backgroundColor: const Color.fromARGB(255, 5, 100, 8), // Hijau sesuai tema
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Header
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(
                    'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(gunung.foto)}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 60, color: Colors.grey),
                          Text("Gagal memuat gambar"),
                        ],
                      ),
                    ),
                  ),
                ),
                // Dekorasi gradasi hitam di bawah gambar agar teks terlihat jelas jika ingin ditaruh di atas gambar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Badges (Provinsi & Ketinggian)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Provinsi (Mirip Category)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.indigo.shade200),
                        ),
                        child: Text(
                          gunung.provinsi.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Badge Ketinggian (Mirip Featured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.bar_chart, size: 14, color: Colors.orange.shade800),
                            const SizedBox(width: 4),
                            Text(
                              '${gunung.ketinggian} mdpl',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  ),
                  const SizedBox(height: 16),
                
                  // 3. Nama Gunung (Title)
                  Text(
                    gunung.nama,
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 30, 30, 30),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Divider (Pemisah)
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 8),

                  // 4. Label Deskripsi
                  const Text(
                    "Deskripsi",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 5, 100, 8),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 5. Isi Deskripsi
                  Text(
                    gunung.deskripsi,
                    style: const TextStyle(
                      fontSize: 16.0,
                      height: 1.6, // Line height agar enak dibaca
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tombol Kembali (Opsional)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 5, 100, 8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Kembali"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}