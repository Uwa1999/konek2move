import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:konek2move/core/constants/app_colors.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  // Leading
  final bool showLeading;
  final VoidCallback? onLeadingTap;
  final IconData? leadingIcon;
  final String? leadingSvg; // SVG support

  // Trailing
  final bool showTrailing;
  final VoidCallback? onTrailingTap;
  final IconData? trailingIcon;
  final String? trailingSvg; // SVG support
  final Widget? trailingBadge; // Badge support

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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // Reusable icon builder (SVG or normal icon)
  Widget _buildIcon({IconData? icon, String? svg, double size = 28}) {
    if (svg != null) {
      return SvgPicture.asset(svg, width: size, height: size);
    }
    return Icon(icon, size: size, color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
        centerTitle: true,

        // Title
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
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _buildIcon(
                        icon: leadingIcon ?? Icons.arrow_back,
                        svg: leadingSvg,
                      ),
                      onPressed: onLeadingTap ?? () => Navigator.pop(context),
                    ),
                  ),
                ),
              )
            : null,

        // ACTIONS (Trailing)
        actions: showTrailing
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: _buildIcon(
                              icon: trailingIcon,
                              svg: trailingSvg,
                            ),
                            onPressed: onTrailingTap,
                          ),
                        ),

                        // Badge
                        if (trailingBadge != null)
                          Positioned(right: -2, top: -2, child: trailingBadge!),
                      ],
                    ),
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}
