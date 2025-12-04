import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';

class CustomDropdownField extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> options;
  final String? value;
  final bool required;
  final ValueChanged<String?> onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.value,
    required this.onChanged,
    this.required = false,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  bool isFocused = false; // ⭐ controls green border

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------- LABEL -------
        RichText(
          text: TextSpan(
            text: widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: widget.required
                ? const [
                    TextSpan(
                      text: " *",
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),

        const SizedBox(height: 8),

        // ------- FIELD -------
        GestureDetector(
          onTap: () => _openBottomSheet(context),
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),

              // ------- BORDER -------
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isFocused
                      ? kPrimaryColor // ⭐ green on focus
                      : Colors.grey.shade400, // grey default
                  width: isFocused ? 1.6 : 1.2, // same as CustomInputField
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kPrimaryColor, width: 1.6),
              ),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.value ?? widget.hint,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.value == null
                        ? Colors.grey.shade500
                        : Colors.black87,
                    fontWeight: widget.value == null
                        ? FontWeight.w400
                        : FontWeight.w500,
                  ),
                ),

                Icon(
                  Icons.keyboard_arrow_down,
                  color: isFocused
                      ? kPrimaryColor // ⭐ green arrow when active
                      : Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // BOTTOM SHEET — turns green on open, resets on close
  // ---------------------------------------------------------
  void _openBottomSheet(BuildContext context) async {
    final bottom = MediaQuery.of(context).padding.bottom;

    setState(() => isFocused = true); // ⭐ activate green border

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- DRAG HANDLE ---
              Container(
                height: 5,
                width: 50,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // --- TITLE ---
              Text(
                widget.hint,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // --- OPTIONS ---
              ...widget.options.map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e, style: const TextStyle(fontSize: 16)),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onChanged(e);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    setState(() => isFocused = false); // ⭐ remove green border after closing
  }
}
