import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? prefixSvg;
  final String? suffixSvg;
  final bool obscure;
  final VoidCallback? onSuffixTap;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.prefixSvg,
    this.suffixSvg,
    this.obscure = false,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            // Borders
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimaryColor, width: 1.6),
            ),

            // PREFIX SVG
            prefixIcon: (prefixSvg != null)
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      prefixSvg!,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        Colors.grey.shade600,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                : null,

            // SUFFIX SVG (for eye icon)
            suffixIcon: (suffixSvg != null)
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        suffixSvg!,
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          Colors.grey.shade600,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
