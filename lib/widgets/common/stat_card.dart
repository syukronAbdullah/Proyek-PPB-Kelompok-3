import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool showBadge;
  final bool expanded;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
    this.icon,
    this.showBadge = false,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(height: 6),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showBadge) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );

    if (!expanded) return card;

    return Expanded(child: card);
  }
}