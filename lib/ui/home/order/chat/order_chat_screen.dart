import 'dart:async';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:konek2move/core/widgets/custom_appbar.dart';
import 'package:konek2move/core/widgets/widget_image_picker.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/services/model_services.dart';
import 'package:konek2move/core/services/provider_services.dart';
import 'package:shimmer/shimmer.dart';

import 'chat_bubble.dart';

class OrderChatScreen extends StatefulWidget {
  final int chatId;
  final String orderNo;
  final String userType;
  final String userCode;

  const OrderChatScreen({
    super.key,
    required this.chatId,
    required this.orderNo,
    required this.userType,
    required this.userCode,
  });

  @override
  State<OrderChatScreen> createState() => _OrderChatScreenState();
}

class _OrderChatScreenState extends State<OrderChatScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _msgCtrl = TextEditingController();

  late ChatProvider _chatProvider;
  StreamSubscription? _notifSub;

  // ================= SHIMMER =================

  Widget _shimmerBubble(bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          height: 22,
          width: isMe ? 140 : 180,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _shimmer() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 16),
      itemCount: 12,
      itemBuilder: (_, i) => _shimmerBubble(i.isEven),
    );
  }

  // ================= LIFECYCLE =================

  @override
  void initState() {
    super.initState();

    _chatProvider = context.read<ChatProvider>();
    _chatProvider.setChatOpen(true);

    _chatProvider.loadMessages(widget.chatId).then((_) {
      if (!mounted) return;
      ApiServices().markChatAsRead(widget.chatId);
      _chatProvider.clearUnread();
    });

    _notifSub = ApiServices().listenNotifications().listen(_handleRealtime);
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    _chatProvider.setChatOpen(false, notify: false);
    _scroll.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  // ================= SSE =================

  void _handleRealtime(Map<String, dynamic> event) {
    if (!mounted) return;

    final data = event["data"];
    final meta = data?["meta"];
    if (meta == null) return;
    if (meta["chat_id"] != widget.chatId) return;

    final msg = ChatMessageResponse(
      id: meta["message_id"] ?? 0,
      senderType: data["recipient_type"] == widget.userType
          ? "customer"
          : widget.userType,
      senderCode: data["recipient_code"] ?? "",
      messageType: meta["message_type"] ?? "text",
      message: meta["message"],
      attachmentUrl: meta["attachment_url"],
      createdAt: DateTime.now(),
    );

    _chatProvider.appendFromServer(msg);
  }

  // ================= SEND =================

  Future<void> _sendText() async {
    final txt = _msgCtrl.text.trim();
    if (txt.isEmpty) return;

    _msgCtrl.clear();
    FocusScope.of(context).unfocus();

    final temp = ChatMessageResponse(
      id: 0,
      senderType: widget.userType,
      senderCode: widget.userCode,
      messageType: "text",
      message: txt,
      createdAt: DateTime.now(),
    );

    _chatProvider.addLocal(temp);

    try {
      final res = await ApiServices().sendChatMessage(
        chatId: widget.chatId,
        orderNo: widget.orderNo,
        message: txt,
      );

      _chatProvider.removeLocal(temp);

      if (res.retCode == "200") {
        await _chatProvider.refreshAfterSend(widget.chatId);
        return;
      }

      _showError(res.message);
    } catch (_) {
      _chatProvider.removeLocal(temp);
      _showError("Failed to send message");
    }
  }

  Future<void> _sendImage(File file) async {
    final temp = ChatMessageResponse(
      id: 0,
      senderType: widget.userType,
      senderCode: widget.userCode,
      messageType: "image",
      attachmentUrl: file.path,
      createdAt: DateTime.now(),
    );

    _chatProvider.addLocal(temp);

    final res = await ApiServices().uploadChatImage(
      chatId: widget.chatId,
      orderNo: widget.orderNo,
      file: file,
    );

    _chatProvider.removeLocal(temp);

    if (res.retCode == "200") {
      await _chatProvider.refreshAfterSend(widget.chatId);
      return;
    }

    _showError(res.message);
  }

  void _showError(String message) {
    if (!mounted) return;
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.red.shade600,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    ).show(context);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final safeBottom = MediaQuery.of(context).padding.bottom;
    const inputBarHeight = 100.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Messages",
        onLeadingTap: () {
          provider.clearUnread();
          Navigator.pop(context);
        },
      ),

      body: provider.initialLoad
          ? _shimmer()
          : ListView.builder(
              controller: _scroll,
              reverse: true,
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                inputBarHeight + safeBottom,
              ),
              itemCount: provider.allMessages.length,
              itemBuilder: (_, i) {
                final msg =
                    provider.allMessages[provider.allMessages.length - 1 - i];
                return ChatBubble(msg: msg, userType: widget.userType);
              },
            ),

      bottomSheet: _inputBar(),
    );
  }

  // ================= INPUT =================

  Widget _inputBar() {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.10),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, safeBottom + 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => pickChatImage(context, _sendImage),
                  child: CircleAvatar(
                    backgroundColor: kPrimaryColor.withOpacity(.12),
                    child: const Icon(Icons.add, color: kPrimaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendText(),
                      decoration: const InputDecoration(
                        hintText: "Message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendText,
                  child: const CircleAvatar(
                    backgroundColor: kPrimaryColor,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
