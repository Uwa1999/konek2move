import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:konek2move/core/constants/app_colors.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  // Leading
  final bool showLeading;
  final VoidCallback? onLeadingTap;
  final IconData? leadingIcon;
  final String? leadingSvg;

  // Trailing
  final bool showTrailing;
  final VoidCallback? onTrailingTap;
  final IconData? trailingIcon;
  final String? trailingSvg;
  final String? trailingText; // 🔥 NEW
  final Widget? trailingBadge;

  const CustomHomeAppBar({
    super.key,
    this.title,
    this.showLeading = true,
    this.onLeadingTap,
    this.leadingIcon,
    this.leadingSvg,
    this.showTrailing = false,
    this.onTrailingTap,
    this.trailingIcon,
    this.trailingSvg,
    this.trailingText,
    this.trailingBadge,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  // Shared icon builder
  Widget _buildIcon({IconData? icon, String? svg, double size = 20}) {
    if (svg != null) {
      return SvgPicture.asset(svg, width: size, height: size);
    }
    return Icon(icon, size: size, color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.08),
      centerTitle: true,

      // TITLE
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            )
          : const SizedBox.shrink(),

      // LEADING
      leadingWidth: showLeading ? 64 : 0,
      leading: showLeading
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: _circleButton(
                  onTap: onLeadingTap ?? () => Navigator.pop(context),
                  child: _buildIcon(
                    icon: leadingIcon ?? Icons.arrow_back,
                    svg: leadingSvg,
                  ),
                ),
              ),
            )
          : null,

      // TRAILING
      actions: showTrailing ? [_buildTrailing()] : [],
    );
  }

  // 🔥 TRAILING BUTTON (supports icon, text, or both)
  Widget _buildTrailing() {
    final bool hasText = trailingText != null && trailingText!.isNotEmpty;
    final bool hasIcon = trailingIcon != null || trailingSvg != null;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: onTrailingTap,
              child: Container(
                padding: hasText && !hasIcon
                    ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                    : const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasText && !hasIcon
                      ? Colors.red.withOpacity(0.08) // 🔥 soft red pill
                      : kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasIcon)
                      _buildIcon(icon: trailingIcon, svg: trailingSvg),

                    if (hasIcon && hasText) const SizedBox(width: 6),

                    if (hasText)
                      Text(
                        trailingText!,
                        style: TextStyle(
                          color: hasText && !hasIcon
                              ? Colors
                                    .red // 🔥 red label (matches sample)
                              : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Badge (optional)
            if (trailingBadge != null)
              Positioned(right: -4, top: -4, child: trailingBadge!),
          ],
        ),
      ),
    );
  }

  // Rounded leading circle
  Widget _circleButton({required Widget child, required VoidCallback? onTap}) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(onPressed: onTap, icon: child),
    );
  }
}
