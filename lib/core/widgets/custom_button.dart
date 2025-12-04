import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;
  final double horizontalPadding;

  /// ⭐ Now accepts ANY widget (CupertinoIcons, SVG, Image, etc.)
  final Widget? icon;

  final Color? borderColor;
  final double? radius;

  const CustomButton({
    super.key,
    this.text,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.horizontalPadding = 24.0,
    this.icon, // ⭐ now Widget
    this.borderColor,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 12),
              side: borderColor != null
                  ? BorderSide(color: borderColor!, width: 1.5)
                  : BorderSide.none,
            ),
          ),
          child: _buildChild(),
        ),
      ),
    );
  }

  Widget _buildChild() {
    // ICON ONLY
    if (icon != null && (text == null || text!.isEmpty)) {
      return icon!;
    }

    // TEXT ONLY
    if (icon == null && text != null) {
      return Text(
        text!,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      );
    }

    // ICON + TEXT
    if (icon != null && text != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
