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
    this.trailingBadge,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  // Shared icon builder
  Widget _buildIcon({IconData? icon, String? svg, double size = 26}) {
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
                child: _roundedIconButton(
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
      actions: showTrailing
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _roundedIconButton(
                        onTap: onTrailingTap,
                        child: _buildIcon(icon: trailingIcon, svg: trailingSvg),
                      ),
                      if (trailingBadge != null)
                        Positioned(right: -2, top: -2, child: trailingBadge!),
                    ],
                  ),
                ),
              ),
            ]
          : [],
    );
  }

  // Rounded circle button used for leading/trailing
  Widget _roundedIconButton({
    required Widget child,
    required VoidCallback? onTap,
  }) {
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
