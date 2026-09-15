import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/conversation.dart';
import '../pages/home_page.dart';

/// A bubble displaying a single message.
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showReadReceipt;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showReadReceipt = false,
  });

  @override
  Widget build(BuildContext context) {
    // System messages have different styling
    if (message.type == MessageType.system) {
      return _buildSystemMessage();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? HomePage.accent : HomePage.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              border: isMe ? null : Border.all(color: HomePage.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : HomePage.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.sentAt),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : HomePage.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    if (isMe && showReadReceipt) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.readAt != null ? Icons.done_all : Icons.done,
                        size: 14,
                        color: message.readAt != null
                            ? Colors.lightBlueAccent
                            : Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: HomePage.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomePage.line),
          ),
          child: Text(
            message.content,
            style: const TextStyle(
              color: HomePage.textMuted,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}
