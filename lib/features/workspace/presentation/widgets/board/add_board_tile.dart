import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

class AddBoardTile extends StatelessWidget {
  final VoidCallback onTap;

  const AddBoardTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mutedColor = context.colorScheme.onSurface.withValues(alpha: 0.5);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: mutedColor,
            borderRadius: AppTheme.borderRadiusMd,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            child: Row(
              children: [
                Icon(Icons.add, size: 18, color: mutedColor),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Add Board',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: mutedColor,
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

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  static const double dashWidth = 5;
  static const double dashGap = 4;

  const _DashedBorderPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}
