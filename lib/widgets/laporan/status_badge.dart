import 'package:flutter/material.dart';

import '../../helpers/status_helper.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;
  final EdgeInsetsGeometry padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final color = StatusHelper.getColor(status);
    final backgroundColor = StatusHelper.getBackgroundColor(status);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              StatusHelper.getIcon(status),
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            StatusHelper.getLabel(status),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}