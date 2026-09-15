/// Models for messaging conversations and messages.

enum MessageType { text, system }

enum ConversationStatus { active, blocked, archived }

/// A single message in a conversation.
class Message {
  final String id;
  final String conversationId;
  final String senderUid;
  final String content;
  final DateTime sentAt;
  final DateTime? readAt;
  final List<String> readBy;
  final MessageType type;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderUid,
    required this.content,
    required this.sentAt,
    this.readAt,
    this.readBy = const [],
    this.type = MessageType.text,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String? ?? '',
        conversationId: json['conversation_id'] as String? ?? '',
        senderUid: json['sender_uid'] as String? ?? '',
        content: json['content'] as String? ?? '',
        sentAt: json['sent_at'] != null
            ? DateTime.parse(json['sent_at'] as String)
            : DateTime.now(),
        readAt: json['read_at'] != null
            ? DateTime.parse(json['read_at'] as String)
            : null,
        readBy: (json['read_by'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        type: json['type'] == 'system' ? MessageType.system : MessageType.text,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'sender_uid': senderUid,
        'content': content,
        'sent_at': sentAt.toIso8601String(),
        'read_at': readAt?.toIso8601String(),
        'read_by': readBy,
        'type': type == MessageType.system ? 'system' : 'text',
      };

  bool isReadBy(String uid) => readBy.contains(uid);
}

/// Preview of the last message in a conversation.
class LastMessage {
  final String content;
  final String senderUid;
  final DateTime sentAt;

  LastMessage({
    required this.content,
    required this.senderUid,
    required this.sentAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
        content: json['content'] as String? ?? '',
        senderUid: json['sender_uid'] as String? ?? '',
        sentAt: json['sent_at'] != null
            ? DateTime.parse(json['sent_at'] as String)
            : DateTime.now(),
      );
}

/// Other participant's profile info for display.
class OtherParticipant {
  final String uid;
  final String? displayName;
  final String? photoUrl;
  final String? skillsToOffer;

  OtherParticipant({
    required this.uid,
    this.displayName,
    this.photoUrl,
    this.skillsToOffer,
  });

  factory OtherParticipant.fromJson(Map<String, dynamic> json) =>
      OtherParticipant(
        uid: json['uid'] as String? ?? '',
        displayName: json['display_name'] as String?,
        photoUrl: json['photo_url'] as String?,
        skillsToOffer: json['skills_to_offer'] as String?,
      );
}

/// A conversation between two users.
class Conversation {
  final String id;
  final List<String> participantUids;
  final String swapRequestId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LastMessage? lastMessage;
  final int unreadCount;
  final ConversationStatus status;
  final OtherParticipant? otherParticipant;

  Conversation({
    required this.id,
    required this.participantUids,
    required this.swapRequestId,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.status = ConversationStatus.active,
    this.otherParticipant,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String? ?? '',
        participantUids: (json['participant_uids'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        swapRequestId: json['swap_request_id'] as String? ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        lastMessage: json['last_message'] != null
            ? LastMessage.fromJson(json['last_message'] as Map<String, dynamic>)
            : null,
        unreadCount: json['unread_count'] as int? ?? 0,
        status: _parseConversationStatus(json['status'] as String?),
        otherParticipant: json['other_participant'] != null
            ? OtherParticipant.fromJson(
                json['other_participant'] as Map<String, dynamic>)
            : null,
      );

  static ConversationStatus _parseConversationStatus(String? status) {
    switch (status) {
      case 'blocked':
        return ConversationStatus.blocked;
      case 'archived':
        return ConversationStatus.archived;
      default:
        return ConversationStatus.active;
    }
  }
}

/// Response for paginated conversation list.
class ConversationListResponse {
  final List<Conversation> conversations;
  final int total;
  final bool hasMore;

  ConversationListResponse({
    required this.conversations,
    required this.total,
    required this.hasMore,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) =>
      ConversationListResponse(
        conversations: (json['conversations'] as List<dynamic>?)
                ?.map((e) => Conversation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        total: json['total'] as int? ?? 0,
        hasMore: json['has_more'] as bool? ?? false,
      );
}
