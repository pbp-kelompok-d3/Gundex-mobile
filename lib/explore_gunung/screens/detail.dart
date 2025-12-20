import 'package:flutter/material.dart';
import 'package:gundex_mobile/explore_gunung/models/gunung.dart';
import 'package:gundex_mobile/wishlist/services/wishlist_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class GunungDetailScreen extends StatefulWidget {
  final Result gunung;

  const GunungDetailScreen({super.key, required this.gunung});

  @override
  State<GunungDetailScreen> createState() => _GunungDetailScreenState();
}

class _GunungDetailScreenState extends State<GunungDetailScreen> {
  bool isInWishlist = false;
  bool isLoadingWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) return;

    try {
      final status = await WishlistService.checkWishlistStatus(
        request,
        widget.gunung.id,
      );
      if (mounted) {
        setState(() {
          isInWishlist = status;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _toggleWishlist() async {
    final request = context.read<CookieRequest>();

    if (!request.loggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan login terlebih dahulu'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      isLoadingWishlist = true;
    });

    try {
      if (isInWishlist) {
        // REMOVE from wishlist
        final items = await WishlistService.fetchWishlist(request);
        final item = items.firstWhere(
          (item) => item.gunung.id == widget.gunung.id,
          orElse: () => throw Exception('Item not found'),
        );

        final response = await WishlistService.removeFromWishlist(
          request,
          item.id,
        );

        if (mounted) {
          if (response['status'] == true) {
            setState(() {
              isInWishlist = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Berhasil dihapus'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Gagal menghapus'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // ADD to wishlist
        final response = await WishlistService.addToWishlist(
          request,
          widget.gunung.id,
        );

        if (mounted) {
          if (response['status'] == true) {
            setState(() {
              isInWishlist = true;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Berhasil ditambahkan'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (response['already_exists'] == true) {
            setState(() {
              isInWishlist = true;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message']),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Gagal menambahkan'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingWishlist = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gunung.nama),
        backgroundColor: const Color.fromARGB(255, 5, 100, 8),
        foregroundColor: Colors.white,
        actions: [
          // WISHLIST BUTTON IN APPBAR
          if (request.loggedIn)
            isLoadingWishlist
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : Colors.white,
                    ),
                    onPressed: _toggleWishlist,
                    tooltip: isInWishlist
                        ? 'Hapus dari wishlist'
                        : 'Tambah ke wishlist',
                  ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(
                    'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(widget.gunung.foto)}',
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
                  // Badges
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.indigo.shade200),
                        ),
                        child: Text(
                          widget.gunung.provinsi.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                            Icon(Icons.bar_chart,
                                size: 14, color: Colors.orange.shade800),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.gunung.ketinggian} mdpl',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nama Gunung
                  Text(
                    widget.gunung.nama,
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 30, 30, 30),
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Divider(color: Colors.grey),
                  const SizedBox(height: 8),

                  // Label Deskripsi
                  const Text(
                    "Deskripsi",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 5, 100, 8),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Isi Deskripsi
                  Text(
                    widget.gunung.deskripsi,
                    style: const TextStyle(
                      fontSize: 16.0,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 24),

                  // Tombol Kembali
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