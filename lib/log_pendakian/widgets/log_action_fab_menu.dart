import 'package:flutter/material.dart';
import '../models/card_action_mode.dart';

const _appleGreen = Color(0xFF87A330);
const _sage = Color(0xFFCAD593);

class LogActionFabMenu extends StatelessWidget {
  final CardActionMode mode;
  final bool isMenuOpen;
  final VoidCallback onToggleMenu;
  final VoidCallback onTapAdd;
  final VoidCallback onTapToggleEdit;

  const LogActionFabMenu({
    super.key,
    required this.mode,
    required this.isMenuOpen,
    required this.onToggleMenu,
    required this.onTapAdd,
    required this.onTapToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = mode == CardActionMode.edit;

    return Positioned(
      right: 16,
      bottom: 16,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TOMBOL KECIL (+ dan EDIT/X) DENGAN ANIMASI
            IgnorePointer(
              // jangan bisa di-tap kalau menu tertutup
              ignoring: !isMenuOpen,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                offset:
                isMenuOpen ? Offset.zero : const Offset(0, 0.2), // naik turun
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: isMenuOpen ? 1 : 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SmallSquareButton(
                        icon: Icons.add,
                        backgroundColor: _sage, // kecil: sage
                        onTap: onTapAdd,
                      ),
                      const SizedBox(height: 12),
                      _SmallSquareButton(
                        icon: isEditMode ? Icons.close : Icons.edit,
                        backgroundColor: _sage,
                        onTap: onTapToggleEdit,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            // KOTAK MENU BESAR
            GestureDetector(
              onTap: onToggleMenu,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _appleGreen, // besar
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallSquareButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _SmallSquareButton({
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
