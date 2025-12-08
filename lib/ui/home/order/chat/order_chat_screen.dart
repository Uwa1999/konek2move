// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:konek2move/core/constants/app_colors.dart';
// import 'package:konek2move/core/services/api_services.dart';
// import 'package:konek2move/core/services/model_services.dart';
// import 'package:konek2move/core/services/provider_services.dart';
// import 'package:shimmer/shimmer.dart';
//
// // Transparent placeholder for FadeInImage
// final kTransparentImage = Uint8List.fromList(List.generate(40, (i) => 0));
//
// class OrderChatScreen extends StatefulWidget {
//   const OrderChatScreen({super.key});
//
//   @override
//   State<OrderChatScreen> createState() => _OrderChatScreenState();
// }
//
// class _OrderChatScreenState extends State<OrderChatScreen> {
//   final ScrollController _scroll = ScrollController();
//   final TextEditingController _msgCtrl = TextEditingController();
//   final picker = ImagePicker();
//
//   final int chatId = 2;
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.microtask(() async {
//       final provider = context.read<ChatProvider>();
//       await provider.loadMessages(chatId);
//       scrollToBottom();
//       ApiServices().markChatAsRead(chatId);
//     });
//   }
//
//   void scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_scroll.hasClients) return;
//
//       _scroll.animateTo(
//         _scroll.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 350),
//         curve: Curves.easeOut,
//       );
//     });
//   }
//
//   // PICK IMAGE
//   Future<void> _pickImage(ChatProvider provider) async {
//     final source = await showModalBottomSheet<ImageSource>(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//       ),
//       builder: (_) => _imagePickerBottomSheet(),
//     );
//
//     if (source == null) return;
//
//     final XFile? picked = await picker.pickImage(
//       source: source,
//       imageQuality: 70,
//     );
//     if (picked == null) return;
//
//     final file = File(picked.path);
//
//     final tempMsg = ChatMessage(
//       id: 0,
//       senderType: "driver",
//       senderCode: "DRV",
//       messageType: "image",
//       attachmentUrl: file.path,
//       createdAt: DateTime.now(),
//     );
//
//     provider.addLocal(tempMsg);
//     scrollToBottom();
//
//     final ok = await ApiServices().uploadChatImage(
//       chatId: chatId,
//       orderNo: "SO-100001",
//       file: file,
//     );
//
//     provider.removeLocal(tempMsg); // FIX
//     if (ok == true) {
//       await provider.loadMessages(chatId);
//     }
//
//     scrollToBottom();
//   }
//
//   // SEND TEXT MESSAGE
//   Future<void> _send(ChatProvider provider) async {
//     final txt = _msgCtrl.text.trim();
//     if (txt.isEmpty) return;
//
//     final tempMsg = ChatMessage(
//       id: 0,
//       senderType: "driver",
//       senderCode: "DRV",
//       messageType: "text",
//       message: txt,
//       attachmentUrl: null,
//       createdAt: DateTime.now(),
//     );
//
//     provider.addLocal(tempMsg);
//     _msgCtrl.clear();
//     scrollToBottom();
//
//     await ApiServices().sendChatMessage(
//       chatId: chatId,
//       orderNo: "SO-100001",
//       message: txt,
//     );
//
//     provider.removeLocal(tempMsg); // FIX: remove temp first
//     await provider.loadMessages(chatId);
//     scrollToBottom();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<ChatProvider>();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
//
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       body: Column(
//         children: [
//           _buildHeader(),
//
//           Expanded(
//             child: provider.initialLoad
//                 ? _shimmer()
//                 : ListView.builder(
//                     controller: _scroll,
//                     padding: const EdgeInsets.all(12),
//                     itemCount: provider.allMessages.length,
//                     itemBuilder: (_, i) =>
//                         ChatBubble(msg: provider.allMessages[i]),
//                   ),
//           ),
//
//           _inputBar(provider),
//         ],
//       ),
//     );
//   }
//
//   // HEADER ---------------------
//   Widget _buildHeader() {
//     return Container(
//       height: 80,
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 10,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 12),
//         child: Stack(
//           alignment: Alignment.bottomCenter,
//           children: [
//             const Text(
//               "Messages",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Positioned(
//               left: 16,
//               child: GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.06),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(Icons.arrow_back, size: 20),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // INPUT BAR ---------------------
//   Widget _inputBar(ChatProvider provider) {
//     return Container(
//       height: 90,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(22),
//           topRight: Radius.circular(22),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 8,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => _pickImage(provider),
//             child: CircleAvatar(
//               radius: 22,
//               backgroundColor: kPrimaryColor.withOpacity(.15),
//               child: const Icon(Icons.add_circle, color: kPrimaryColor),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: TextField(
//               controller: _msgCtrl,
//               decoration: InputDecoration(
//                 hintText: "Message…",
//                 filled: true,
//                 fillColor: Colors.grey.shade200,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 14,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               onSubmitted: (_) => _send(provider),
//             ),
//           ),
//           const SizedBox(width: 10),
//           GestureDetector(
//             onTap: () => _send(provider),
//             child: CircleAvatar(
//               radius: 24,
//               backgroundColor: kPrimaryColor,
//               child: const Icon(Icons.send, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // IMAGE PICKER SHEET --------------------
//   Widget _imagePickerBottomSheet() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text(
//             "Select Image",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 10),
//           Text(
//             "Choose where to get your image from",
//             style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _pickerButton(
//                 "Camera",
//                 "assets/icons/camera.svg",
//                 ImageSource.camera,
//               ),
//               _pickerButton(
//                 "Gallery",
//                 "assets/icons/gallery.svg",
//                 ImageSource.gallery,
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           const Divider(),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _pickerButton(String label, String icon, ImageSource source) {
//     return GestureDetector(
//       onTap: () => Navigator.pop(context, source),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.grey.shade200,
//             child: SvgPicture.asset(icon, width: 28),
//           ),
//           const SizedBox(height: 6),
//           Text(label),
//         ],
//       ),
//     );
//   }
//
//   // SHIMMER PLACEHOLDER
//   Widget _shimmer() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 10,
//       itemBuilder: (_, i) {
//         return Align(
//           alignment: (i % 2 == 0)
//               ? Alignment.centerLeft
//               : Alignment.centerRight,
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             height: 24,
//             width: 150 + (i % 3) * 30,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(18),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:konek2move/core/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/services/model_services.dart';
import 'package:konek2move/core/services/provider_services.dart';
import 'package:shimmer/shimmer.dart';

// Transparent placeholder for FadeInImage
final kTransparentImage = Uint8List.fromList(List.generate(40, (i) => 0));

class OrderChatScreen extends StatefulWidget {
  const OrderChatScreen({super.key});

  @override
  State<OrderChatScreen> createState() => _OrderChatScreenState();
}

class _OrderChatScreenState extends State<OrderChatScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _msgCtrl = TextEditingController();
  final picker = ImagePicker();

  StreamSubscription? notifSub;

  final int chatId = 2;

  final String userCode = "DRV-000003"; // your driver code
  final String userType = "driver";

  // @override
  // void initState() {
  //   super.initState();
  //
  //   Future.microtask(() async {
  //     final provider = Provider.of<ChatProvider>(context, listen: false);
  //     provider.setChatOpen(true);
  //     // provider.markAsRead(widget.chatId);
  //     await provider.loadMessages(chatId);
  //     scrollToBottom(force: true);
  //
  //     ApiServices().markChatAsRead(chatId);
  //
  //     // Start SSE Listener
  //     notifSub = ApiServices()
  //         .listenNotifications(userCode: userCode, userType: userType)
  //         .listen(handleRealtime);
  //   });
  // }
  //
  // @override
  // void dispose() {
  //   notifSub?.cancel();
  //   Provider.of<ChatProvider>(context, listen: false).setChatOpen(false);
  //
  //   super.dispose();
  // }
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = Provider.of<ChatProvider>(context, listen: false);

      // Mark chat as active to prevent unread increments from SSE
      provider.setChatOpen(true);

      // Load messages first
      await provider.loadMessages(chatId);
      scrollToBottom(force: true);

      // Mark ALL messages as read on backend
      await ApiServices().markChatAsRead(chatId);

      // Also update provider badge (instant clear)
      provider.clearUnread();

      // Start SSE listener
      notifSub = ApiServices()
          .listenNotifications(userCode: userCode, userType: userType)
          .listen(handleRealtime);
    });
  }

  @override
  void dispose() {
    // Stop SSE when leaving chat
    notifSub?.cancel();

    // IMPORTANT: set to false so unread increments again
    Provider.of<ChatProvider>(context, listen: false).setChatOpen(false);

    super.dispose();
  }

  // ========================= SSE REALTIME HANDLER =========================

  void handleRealtime(Map<String, dynamic> event) {
    final provider = context.read<ChatProvider>();

    final data = event["data"];
    if (data == null) return;

    // Accept only chat.new_message SSE events
    if (!(data["topic"]?.toString().contains("chat.new_message") ?? false)) {
      return;
    }

    final meta = data["meta"];
    if (meta == null) return;

    // Only process messages for this chat
    if (meta["chat_id"] != chatId) return;

    // Build real server message
    final msg = ChatMessage(
      id: meta["message_id"],
      senderType: meta["sender_type"] ?? "",
      senderCode: meta["sender_code"] ?? "",
      messageType: meta["message_type"],
      message: meta["message"],
      attachmentUrl: meta["attachment_url"],
      createdAt:
          DateTime.tryParse(meta["created_at"] ?? "")?.toLocal() ??
          DateTime.now(),
    );

    // 🧠 REMOVE TEMP if matches (your own message)
    provider.removeTempIfMatched(msg);

    // 🧠 ADD REAL message
    provider.addLocal(msg);

    // Auto-scroll
    scrollToBottom();
  }

  // ========================= SCROLL HELPERS =========================

  void scrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_scroll.hasClients) return;

      await Future.delayed(const Duration(milliseconds: 40));

      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  // ========================= PICK IMAGE =========================

  // Future<void> _pickImage(ChatProvider provider) async {
  //   final source = await showModalBottomSheet<ImageSource>(
  //     context: context,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
  //     ),
  //     builder: (_) => _imagePickerBottomSheet(),
  //   );
  //
  //   if (source == null) return;
  //
  //   final XFile? picked = await picker.pickImage(
  //     source: source,
  //     imageQuality: 70,
  //   );
  //
  //   if (picked == null) return;
  //
  //   final file = File(picked.path);
  //
  //   // FIX: senderCode must match SSE senderCode
  //   final tempMsg = ChatMessage(
  //     id: 0,
  //     senderType: "driver",
  //     senderCode: userCode,
  //     messageType: "image",
  //     attachmentUrl: file.path,
  //     createdAt: DateTime.now(),
  //   );
  //
  //   provider.addLocal(tempMsg);
  //   scrollToBottom();
  //
  //   await ApiServices().uploadChatImage(
  //     chatId: chatId,
  //     orderNo: "SO-100001",
  //     file: file,
  //   );
  //
  //   provider.removeLocal(tempMsg);
  //
  //   // SSE gives real message
  //   scrollToBottom();
  // }
  Future<void> _pickImage(ChatProvider provider) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _imagePickerBottomSheet(),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 70);

    if (picked == null) return;

    final file = File(picked.path);

    // TEMP MESSAGE (id = 0)
    final tempMsg = ChatMessage(
      id: 0,
      senderType: "driver",
      senderCode: userCode,
      messageType: "image",
      attachmentUrl: file.path, // LOCAL PATH
      createdAt: DateTime.now(),
    );

    // 1️⃣ Add temp bubble immediately
    provider.addLocal(tempMsg);
    scrollToBottom();

    // 2️⃣ Upload image
    final success = await ApiServices().uploadChatImage(
      chatId: chatId,
      orderNo: "SO-100001",
      file: file,
    );

    // If upload failed → Stop temp removal
    if (success == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed. Try again.")),
      );
      return;
    }

    // 3️⃣ Remove temp bubble after real upload (before SSE arrives)
    provider.removeLocal(tempMsg);

    // OPTIONAL (if you want instant refresh before SSE)
    await provider.refreshAfterSend(chatId);

    scrollToBottom();
  }

  // ========================= SEND TEXT =========================

  Future<void> _send(ChatProvider provider) async {
    final txt = _msgCtrl.text.trim();
    if (txt.isEmpty) return;

    // TEMP bubble
    final tempMsg = ChatMessage(
      id: 0,
      senderType: "driver",
      senderCode: userCode,
      messageType: "text",
      message: txt,
      attachmentUrl: null,
      createdAt: DateTime.now(),
    );

    provider.addLocal(tempMsg);
    _msgCtrl.clear();
    scrollToBottom();

    // Call API
    await ApiServices().sendChatMessage(
      chatId: chatId,
      orderNo: "SO-100001",
      message: txt,
    );

    // ❗ DO NOT REMOVE TEMP (SSE will NOT return your own message)
    // provider.removeLocal(tempMsg);

    // Convert temp -> "sent" state
    final real = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch, // temporary ID
      senderType: "driver",
      senderCode: userCode,
      messageType: "text",
      message: txt,
      attachmentUrl: null,
      createdAt: DateTime.now(),
    );

    provider.removeLocal(tempMsg);
    provider.addLocal(real);

    scrollToBottom();
  }

  // ========================= UI BUILD =========================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());

    return Scaffold(
      backgroundColor: Colors.white,

      // ---------- FIXED DEFAULT APP BAR ----------
      appBar: CustomAppBar(title: "Messages", leadingIcon: Icons.arrow_back),

      // ---------- MESSAGE LIST ----------
      body: provider.initialLoad
          ? _shimmer()
          : SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true, // IMPORTANT (inside column)
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.allMessages.length,
                    itemBuilder: (_, i) =>
                        ChatBubble(msg: provider.allMessages[i]),
                  ),

                  const SizedBox(height: 120), // space before input bar
                ],
              ),
            ),

      // ---------- FIXED INPUT BAR ----------
      bottomNavigationBar: _inputBar(provider),
    );
  }

  // ========================= INPUT BAR =========================

  Widget _inputBar(ChatProvider provider) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    // Detect 3-button navigation (no bottom inset)
    final bool isThreeButtonNav = safeBottom == 0;

    return SafeArea(
      bottom: false, // Prevents overlap with 3-button nav
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              isThreeButtonNav ? 16 : safeBottom + 24,
            ),
            child: Row(
              children: [
                // ------------ Add Image Button ------------
                GestureDetector(
                  onTap: () => _pickImage(provider),
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: kPrimaryColor,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ------------ Text Field ------------
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: TextField(
                      controller: _msgCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(provider),
                      decoration: const InputDecoration(
                        hintText: "Message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ------------ Send Button ------------
                GestureDetector(
                  onTap: () => _send(provider),
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: const BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================= IMAGE PICKER SHEET =========================

  Widget _imagePickerBottomSheet() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select Image",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Choose where to get your image from",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _pickerButton(
                "Camera",
                "assets/icons/camera.svg",
                ImageSource.camera,
              ),
              _pickerButton(
                "Gallery",
                "assets/icons/gallery.svg",
                ImageSource.gallery,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _pickerButton(String label, String icon, ImageSource source) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, source),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            child: SvgPicture.asset(icon, width: 28),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  // ========================= SHIMMER =========================

  Widget _shimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (_, i) {
        return Align(
          alignment: (i % 2 == 0)
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 24,
            width: 150 + (i % 3) * 30,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        );
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  const ChatBubble({super.key, required this.msg});

  bool get isMe => msg.senderType == "driver";

  @override
  Widget build(BuildContext context) {
    final isImage = msg.messageType == "image" || msg.messageType == "file";
    final isSending = msg.id == 0 && msg.attachmentUrl != null;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: isSending ? 0.6 : 1,
            child: Container(
              padding: isImage ? EdgeInsets.zero : const EdgeInsets.all(14),
              margin: const EdgeInsets.symmetric(vertical: 6),
              constraints: const BoxConstraints(maxWidth: 260),
              decoration: BoxDecoration(
                color: isMe ? kPrimaryColor : kLightButtonColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: isImage ? _image(msg, isSending) : _text(msg),
            ),
          ),

          // timestamp
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Time
              Text(
                formatTime(msg.createdAt),
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  Widget _text(ChatMessage msg) {
    return Text(
      msg.message ?? "",
      style: TextStyle(
        fontSize: 16,
        color: isMe ? Colors.white : Colors.black87,
      ),
    );
  }

  // FAST Image Loader (NO packages)
  Widget _image(ChatMessage msg, bool isSending) {
    final path = msg.attachmentUrl ?? "";
    final isNetwork = path.startsWith("https");

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 230,
            height: 230,
            child: isNetwork
                ? FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage(path),
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 180),
                    placeholderErrorBuilder: (_, __, ___) => _loadingShimmer(),
                    imageErrorBuilder: (_, __, ___) => _imageErrorPlaceholder(),
                  )
                : Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageErrorPlaceholder(),
                  ),
          ),
        ),

        // Upload overlay
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

  // Modern shimmer
  Widget _loadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 230,
        height: 230,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // error fallback
  Widget _imageErrorPlaceholder() {
    return Container(
      width: 230,
      height: 230,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.broken_image, size: 40, color: Colors.black38),
      ),
    );
  }
}

// TIME FORMATTER AM/PM
String formatTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? "PM" : "AM";
  return "$hour:$minute $period";
}

// FAST Image Loader
Widget _image(ChatMessage msg, bool isSending) {
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
              ? FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: NetworkImage(path),
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 180),
                  placeholderErrorBuilder: (_, __, ___) => _loadingShimmer(),
                  imageErrorBuilder: (_, __, ___) => _imageErrorPlaceholder(),
                )
              : Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imageErrorPlaceholder(),
                ),
        ),
      ),

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

Widget _loadingShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: 230,
      height: 230,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

Widget _imageErrorPlaceholder() {
  return Container(
    width: 230,
    height: 230,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(
      child: Icon(Icons.broken_image, size: 40, color: Colors.black38),
    ),
  );
}
