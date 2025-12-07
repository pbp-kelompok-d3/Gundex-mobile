import 'package:flutter/material.dart';
import '../models/artikel.dart';
import '../services/artikel_service.dart';
import 'artikel_detail_page.dart';
import 'artikel_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ArtikelListPage extends StatefulWidget {
  const ArtikelListPage({super.key});

  @override
  State<ArtikelListPage> createState() => _ArtikelListPageState();
}

class _ArtikelListPageState extends State<ArtikelListPage> {
  late Future<List<Artikel>> _futureArtikel;

  @override
  void initState() {
    super.initState();
    _futureArtikel = ArtikelService.fetchArtikelList();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureArtikel = ArtikelService.fetchArtikelList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GunDex — Artikel Pendakian'),
      ),
      body: FutureBuilder<List<Artikel>>(
        future: _futureArtikel,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final artikels = snapshot.data ?? [];

          if (artikels.isEmpty) {
            return const Center(child: Text('Belum ada artikel.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: artikels.length,
              itemBuilder: (context, index) {
                final a = artikels[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: a.image.isNotEmpty
                        ? Image.network(
                          a.proxied(ArtikelService.baseUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.image),
                    title: Text(a.title),
                    subtitle: Text(
                      a.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite, size: 16),
                        Text(a.likes.toString()),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArtikelDetailPage(artikelId: a.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const ArtikelFormPage()),
          );
          if (created == true) {
            _refresh();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
