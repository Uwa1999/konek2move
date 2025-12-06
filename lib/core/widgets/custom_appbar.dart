import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  // Leading button
  final bool showLeading;
  final VoidCallback? onLeadingTap;
  final IconData leadingIcon;

  // Trailing button
  final bool showTrailing;
  final VoidCallback? onTrailingTap;
  final IconData trailingIcon;

  const CustomAppBar({
    super.key,

    this.title, // title is now optional

    this.showLeading = true,
    this.onLeadingTap,
    this.leadingIcon = Icons.arrow_back,

    this.showTrailing = false,
    this.onTrailingTap,
    this.trailingIcon = Icons.more_horiz,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
        centerTitle: true,

        // Title is optional
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

        // Leading
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
                      icon: Icon(leadingIcon, color: Colors.black, size: 20),
                      onPressed: onLeadingTap ?? () => Navigator.pop(context),
                    ),
                  ),
                ),
              )
            : null,

        // Trailing
        actions: showTrailing
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(trailingIcon, color: Colors.black, size: 20),
                        onPressed: onTrailingTap,
                      ),
                    ),
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}
