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

class _GunungCardState extends State<GunungCard> with SingleTickerProviderStateMixin {
  bool isInWishlist = false;
  bool isLoadingWishlist = false;
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            behavior: SnackBarBehavior.floating,
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
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hapus dari halaman Wishlist'),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        final response = await WishlistService.addToWishlist(
          request,
          widget.gunungId,
        );

        if (mounted) {
          if (response['status'] == true || response['already_exists'] == true) {
            setState(() {
              isInWishlist = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Berhasil ditambahkan'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Gagal menambahkan'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
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
            behavior: SnackBarBehavior.floating,
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

    final imageUrl = 'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(widget.imageUrl)}';

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20), 
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08), 
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'gunung-${widget.gunungId}', 
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        widget.namaGunung,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800, 
                          color: Color(0xFF243010),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      _buildInfoRow(Icons.height, widget.ketinggian),
                      const SizedBox(height: 4),
                      
                      _buildInfoRow(Icons.location_on_outlined, widget.lokasi),
                    ],
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (request.loggedIn)
                      InkWell(
                        onTap: isLoadingWishlist ? null : _toggleWishlist,
                        borderRadius: BorderRadius.circular(50),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: isLoadingWishlist
                            ? const SizedBox(
                                width: 24, 
                                height: 24, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF243010))
                              )
                            : AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return ScaleTransition(scale: animation, child: child);
                                },
                                child: Icon(
                                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                                  key: ValueKey<bool>(isInWishlist), 
                                  color: isInWishlist ? const Color(0xFFE53935) : Colors.grey[400],
                                  size: 28,
                                ),
                              ),
                        ),
                      ),
                    
                    if (widget.isAdmin) const SizedBox(height: 12),

                    if (widget.isAdmin) ...[
                      _buildAdminAction(
                        icon: Icons.edit_outlined,
                        color: Colors.blueAccent,
                        onTap: widget.onEdit,
                      ),
                      const SizedBox(height: 8),
                      _buildAdminAction(
                        icon: Icons.delete_outline,
                        color: Colors.redAccent,
                        onTap: widget.onDelete,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}