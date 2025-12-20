import 'package:flutter/material.dart';

Future<void> showInternetDialog({
  required BuildContext context,
  required String title,
  required String message,
  required IconData icon,
  required Color color,
  required String buttonText,
  required Future<void> Function()? onRetry,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (_) {
      bool isLoading = false;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            elevation: 12,
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 42, color: color),
                  ),

                  const SizedBox(height: 18),

                  // TITLE
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // MESSAGE
                  Text(
                    isLoading
                        ? "Checking your internet connection..."
                        : message,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Colors.grey.shade700,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                        if (onRetry == null) return;

                        setDialogState(() => isLoading = true);
                        await onRetry();
                        setDialogState(() => isLoading = false);
                      },
                      child: isLoading
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
