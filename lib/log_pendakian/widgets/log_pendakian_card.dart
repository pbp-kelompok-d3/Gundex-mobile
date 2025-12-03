import 'package:flutter/material.dart';
import '../models/log_pendakian.dart';

class LogPendakianCard extends StatelessWidget {
  final LogPendakian log;
  final bool showInlineActions;
  final VoidCallback? onTapDetails;
  final VoidCallback? onTapInlineEdit;
  final VoidCallback? onTapInlineDelete;

  const LogPendakianCard({
    super.key,
    required this.log,
    this.showInlineActions = false,
    this.onTapDetails,
    this.onTapInlineEdit,
    this.onTapInlineDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = log.photoUrl != null && log.photoUrl!.trim().isNotEmpty;

    final dateText = (log.startDate != null && log.endDate != null)
        ? '${log.startDate} → ${log.endDate}'
        : (log.startDate ?? '');

    final metaParts = <String>[];
    metaParts.add(log.summitReached ? 'Tercapai puncak' : 'Belum sampai puncak');
    if (log.teamSize != null) {
      metaParts.add('${log.teamSize} orang');
    }
    if (log.rating != null) {
      metaParts.add('⭐ ${log.rating}/5');
    }
    final metaText = metaParts.join(' • ');

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hasPhoto
                  ? AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  log.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                ),
              )
                  : AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildPlaceholder(),
              ),
              Container(
                color: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.gunungNama,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (dateText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        dateText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                    ],
                    if (metaText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        metaText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                    ],
                    if (log.notes != null && log.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        log.notes!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),

                    // ROW DETAILS + INLINE ACTION (DENGAN ANIMASI)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _InlineActions(
                          showInlineActions: showInlineActions,
                          onTapInlineDelete: onTapInlineDelete,
                          onTapInlineEdit: onTapInlineEdit,
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: onTapDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB3D7FF),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Icon(
        Icons.terrain,
        size: 56,
        color: Colors.grey[400],
      ),
    );
  }
}

class _InlineActions extends StatelessWidget {
  final bool showInlineActions;
  final VoidCallback? onTapInlineEdit;
  final VoidCallback? onTapInlineDelete;

  const _InlineActions({
    required this.showInlineActions,
    this.onTapInlineEdit,
    this.onTapInlineDelete,
  });

  @override
  Widget build(BuildContext context) {

    // Dua tombol kecil akan "keluar" dari arah tombol Details (kanan)
    return ClipRect(
      child: IgnorePointer(
        ignoring: !showInlineActions,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 390),
          curve: Curves.easeOutCubic,
          // kalau disembunyikan: geser jauh ke kanan (seolah di belakang Details)
          offset: showInlineActions
              ? Offset.zero
              : const Offset(1.0, 0.0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 290),
            opacity: showInlineActions ? 1 : 0,
            child: Row(
              children: [
                if (onTapInlineDelete != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _SmallCircleButton(
                      icon: Icons.delete,
                      backgroundColor: Colors.red,
                      onTap: onTapInlineDelete!,
                    ),
                  ),
                if (onTapInlineEdit != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _SmallCircleButton(
                      icon: Icons.edit,
                      backgroundColor: const Color(0xFF87A330),
                      onTap: onTapInlineEdit!,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallCircleButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _SmallCircleButton({
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
