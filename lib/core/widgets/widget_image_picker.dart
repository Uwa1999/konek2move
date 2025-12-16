import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

Future<void> pickChatImage(
  BuildContext context,
  Function(File) onImagePicked,
) async {
  final ImagePicker picker = ImagePicker();
  final bottom = MediaQuery.of(context).padding.bottom;

  final ImageSource? source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.white,
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
            const Text(
              "Select Image",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // --- SUBTITLE ---
            Text(
              "Choose where to get your image from",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 24),

            // --- OPTIONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickerOption(
                  context: context,
                  label: "Camera",
                  iconPath: "assets/icons/camera.svg",
                  bgColor: Colors.blue[50]!,
                  source: ImageSource.camera,
                ),
                _pickerOption(
                  context: context,
                  label: "Gallery",
                  iconPath: "assets/icons/gallery.svg",
                  bgColor: Colors.green[50]!,
                  source: ImageSource.gallery,
                ),
              ],
            ),

            const SizedBox(height: 28),
            const Divider(),

            // --- CANCEL ---
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (source == null) return;

  final XFile? pickedFile = await picker.pickImage(
    source: source,
    imageQuality: 80,
  );

  if (pickedFile != null) {
    onImagePicked(File(pickedFile.path));
  }
}

Widget _pickerOption({
  required BuildContext context,
  required String label,
  required String iconPath,
  required Color bgColor,
  required ImageSource source,
}) {
  return GestureDetector(
    onTap: () => Navigator.pop(context, source),
    child: Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: bgColor,
          child: SvgPicture.asset(iconPath, width: 32, height: 32),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}
