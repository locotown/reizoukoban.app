import 'package:flutter/material.dart';

/// ソート切り替えボタンウィジェット
class SortButton extends StatelessWidget {
  final String sortMode;
  final VoidCallback onTap;

  const SortButton({
    super.key,
    required this.sortMode,
    required this.onTap,
  });

  String get _label {
    switch (sortMode) {
      case 'expiration':
        return '期限順';
      case 'status':
        return '緊急度順';
      case 'added':
        return '追加順';
      default:
        return '期限順';
    }
  }

  IconData get _icon {
    switch (sortMode) {
      case 'expiration':
        return Icons.schedule;
      case 'status':
        return Icons.priority_high;
      case 'added':
        return Icons.history;
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2196F3).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 14,
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(width: 4),
            Text(
              _label,
              style: const TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
