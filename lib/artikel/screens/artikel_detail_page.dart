import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/artikel.dart';
import '../services/artikel_service.dart';
import 'artikel_form.dart';
import 'package:gundex_mobile/userprofile/login.dart';

class ArtikelDetailPage extends StatefulWidget {
  final String artikelId;

  const ArtikelDetailPage({super.key, required this.artikelId});

  @override
  State<ArtikelDetailPage> createState() => _ArtikelDetailPageState();
}

class _ArtikelDetailPageState extends State<ArtikelDetailPage> {
  late Future<Artikel> _future;
  bool _isUpdated = false;

  bool isAdmin = false;
  bool isAuthLoaded = false;

  @override
  void initState() {
    super.initState();
    // Future di-set di build karena butuh CookieRequest
  }

  void _reload(CookieRequest request) {
    setState(() {
      _future =
          ArtikelService.fetchArtikelDetail(request, widget.artikelId);
    });
  }

  Future<void> _loadAuth(CookieRequest request) async {
    try {
      final res =
          await request.get('${ArtikelService.baseUrl}/artikel/api/whoami/');

      setState(() {
        isAdmin = res is Map && res['is_admin'] == true;
        isAuthLoaded = true;
      });
    } catch (_) {
      setState(() {
        isAdmin = false;
        isAuthLoaded = true;
      });
    }
  }

  Future<void> _delete(
    CookieRequest request,
  ) async {
    await request.post(
      '${ArtikelService.baseUrl}/artikel/api/flutter/${widget.artikelId}/delete/',
      {},
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    _future =
        ArtikelService.fetchArtikelDetail(request, widget.artikelId);

    if (!isAuthLoaded) {
      _loadAuth(request);
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _isUpdated);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Artikel'),
          actions: [
            if (isAuthLoaded && isAdmin)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus artikel?'),
                      content: const Text(
                          'Apakah kamu yakin ingin menghapus artikel ini?'),
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
                    await _delete(request);
                  }
                },
              ),
          ],
        ),
        body: FutureBuilder<Artikel>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final err = snapshot.error.toString();

              if (err.contains('LOGIN_REQUIRED')) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage()),
                  );
                });
                return const SizedBox.shrink();
              }

              return Center(child: Text('Error: $err'));
            }

            if (!snapshot.hasData) {
              return const Center(
                  child: Text('Data tidak ditemukan'));
            }

            final a = snapshot.data!;

            // tambah view SETELAH sukses load
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ArtikelService.addView(request, widget.artikelId);
            });

            final proxied = a.proxied(ArtikelService.baseUrl);

            // === WIDGET GAMBAR (BENAR) ===
            Widget imageWidget;

            if (proxied == null || proxied.isEmpty) {
              imageWidget = _defaultImage();
            } else {
              imageWidget = ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  proxied,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _defaultImage(),
                ),
              );
            }

            // === UI ===
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageWidget,
                  const SizedBox(height: 16),

                  Text(
                    a.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
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

                  if (isAuthLoaded && isAdmin)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArtikelFormPage(artikel: a),
                          ),
                        );

                        if (updated == true) {
                          _isUpdated = true;
                          _reload(request);
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
      ),
    );
  }

  Widget _defaultImage() {
  return Container(
    height: 220,
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(12),
    ),
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.terrain, size: 64, color: Colors.green),
        SizedBox(height: 8),
        Text(
          'Gambar tidak tersedia',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
}