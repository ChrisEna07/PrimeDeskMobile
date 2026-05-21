import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DialogHelper {
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Aceptar',
    String cancelText = 'Cancelar',
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        );
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOut),
        );
        return ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E2124),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              title: Row(
                children: [
                  const Icon(LucideIcons.helpCircle, color: Color(0xFFFF6B00), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: BorderSide(color: Colors.white.withOpacity(0.1)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(cancelText, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(confirmText, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    final Future<void> dialogFuture = showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        );
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOut),
        );
        return ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E2124),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B00).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.checkCircle, color: Color(0xFFFF6B00), size: 48),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '¡Éxito!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(duration, () {
      try {
        Navigator.pop(context);
      } catch (_) {}
    });

    return dialogFuture;
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        );
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOut),
        );
        return ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E2124),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              title: Row(
                children: [
                  const Icon(LucideIcons.xCircle, color: Colors.redAccent, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.2),
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      side: const BorderSide(color: Colors.redAccent, width: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
