import 'package:flutter/material.dart';
import '../models/artikel.dart';
import '../services/artikel_service.dart';
import 'artikel_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ArtikelDetailPage extends StatefulWidget {
  final String artikelId;

  const ArtikelDetailPage({super.key, required this.artikelId});

  @override
  State<ArtikelDetailPage> createState() => _ArtikelDetailPageState();
}

class _ArtikelDetailPageState extends State<ArtikelDetailPage> {
  late Future<Artikel> _future;

  @override
  void initState() {
    super.initState();
    _future = ArtikelService.fetchArtikelDetail(widget.artikelId);
  }

  void _reload() {
    setState(() {
      _future = ArtikelService.fetchArtikelDetail(widget.artikelId);
    });
  }

  Future<void> _delete() async {
    await ArtikelService.deleteArtikel(widget.artikelId);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus artikel?'),
                  content: const Text('Apakah kamu yakin ingin menghapus artikel ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await _delete();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Artikel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error: ${snapshot.error ?? "Data tidak ditemukan"}'));
          }
          final a = snapshot.data!;
          final proxied = a.proxied(ArtikelService.baseUrl);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (proxied != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      proxied,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  a.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye, size: 16),
                    const SizedBox(width: 4),
                    Text('${a.views} views'),
                    const SizedBox(width: 16),
                    const Icon(Icons.favorite, size: 16),
                    const SizedBox(width: 4),
                    Text('${a.likes} likes'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  a.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArtikelFormPage(artikel: a),
                      ),
                    );
                    if (updated == true) {
                      _reload();
                      Navigator.pop(context, true);
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Artikel'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
