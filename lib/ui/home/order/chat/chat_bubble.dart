import 'dart:io';
import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/model_services.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageResponse msg;
  final String userType;

  const ChatBubble({super.key, required this.msg, required this.userType});

  bool get isMe => msg.senderType == userType;

  @override
  Widget build(BuildContext context) {
    final isImage = msg.messageType == "image" || msg.messageType == "file";
    final isSending = msg.id == 0;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            constraints: const BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: isImage
                  ? Colors.transparent
                  : isMe
                  ? kPrimaryColor
                  : kLightButtonColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: isImage ? _imageWithLoading(isSending) : _text(isSending),
          ),

          // time
          Text(
            _formatTime(msg.createdAt),
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _text(bool isSending) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isSending ? 0.6 : 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          msg.message ?? "",
          style: TextStyle(
            fontSize: 16,
            height: 1.35,
            color: isMe ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _imageWithLoading(bool isSending) {
    final path = msg.attachmentUrl ?? "";
    final isNetwork = path.startsWith("http");

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 230,
            height: 230,
            child: isNetwork
                ? Image.network(
                    path,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => _imageError(),
                  )
                : Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageError(),
                  ),
          ),
        ),

        // ⏳ UPLOADING OVERLAY
        if (isSending)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _imageError() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final m = time.minute.toString().padLeft(2, '0');
    final p = time.hour >= 12 ? "PM" : "AM";
    return "$h:$m $p";
  }
}
