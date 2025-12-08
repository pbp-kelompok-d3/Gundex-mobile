import 'package:flutter/material.dart';
import 'package:gundex_mobile/wishlist/services/wishlist_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class GunungCard extends StatefulWidget {
  final String namaGunung;
  final String ketinggian;
  final String lokasi;
  final String imageUrl;
  final String gunungId;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GunungCard({
    super.key,
    required this.namaGunung,
    required this.ketinggian,
    required this.lokasi,
    required this.imageUrl,
    required this.gunungId, 
    this.isAdmin = false,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<GunungCard> createState() => _GunungCardState();
}

class _GunungCardState extends State<GunungCard> {
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
        widget.gunungId,
      );
      if (mounted) {
        setState(() {
          isInWishlist = status;
        });
      }
    } catch (e) {
      // Silently fail - user can still add manually
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
        // Not implemented - user can remove from wishlist page
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hapus dari halaman Wishlist'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } else {
        // Add to wishlist
        final response = await WishlistService.addToWishlist(
          request,
          widget.gunungId,
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

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color.fromARGB(255, 5, 100, 8), width: 1.5),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(widget.imageUrl)}',
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
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.namaGunung,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ketinggian: ${widget.ketinggian}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      "Lokasi: ${widget.lokasi}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

              // Actions Column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wishlist Button (shown if logged in)
                  if (request.loggedIn)
                    isLoadingWishlist
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _buildCircleButton(
                            icon: isInWishlist ? Icons.favorite : Icons.favorite_border,
                            color: isInWishlist ? Colors.red : Colors.grey,
                            onPressed: _toggleWishlist,
                          ),

                  // Admin buttons (if admin)
                  if (widget.isAdmin) ...[
                    const SizedBox(height: 8),
                    _buildCircleButton(
                      icon: Icons.edit,
                      color: const Color.fromARGB(255, 5, 100, 8),
                      onPressed: widget.onEdit,
                    ),
                    const SizedBox(height: 8),
                    _buildCircleButton(
                      icon: Icons.delete,
                      color: Colors.red,
                      onPressed: widget.onDelete,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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