import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../home_page.dart';
import '../../services/b2c_auth_service.dart';
import '../../services/swap_request_service.dart';
import '../../models/conversation.dart';
import '../../models/swap_request.dart';
import '../../services/messaging_service.dart';
import '../../services/swap_request_service.dart';
import '../../services/review_service.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/message_input.dart';

/// Page for a single chat conversation.
class ChatPage extends StatefulWidget {
  final Conversation conversation;

  const ChatPage({super.key, required this.conversation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messagingService = MessagingService();
  final _swapRequestService = SwapRequestService();
  final _reviewService = ReviewService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  List<Message> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  Timer? _pollTimer;

  // Swap request tracking for completion banner
  SwapRequest? _swapRequest;
  bool _loadingSwapRequest = true;

  String get _currentUid => B2CAuthService.instance.currentUser?.uid ?? '';

  String get _otherUid => widget.conversation.participantUids
      .firstWhere((uid) => uid != _currentUid, orElse: () => '');

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadSwapRequest();
    _markAsRead();
    _startPolling();
    _loadSwapRequest();
  }

  Future<void> _loadSwapRequest() async {
    if (widget.conversation.swapRequestId.isEmpty) {
      setState(() => _loadingSwap = false);
      return;
    }

    try {
      final request = await _swapRequestService.getRequest(
        widget.conversation.swapRequestId,
        _currentUid,
      );
      if (mounted) {
        setState(() {
          _swapRequest = request;
          _loadingSwap = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading swap request: $e');
      if (mounted) {
        setState(() => _loadingSwap = false);
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        _loadMessages(silent: true);
        _loadSwapRequest(silent: true);
      },
    );
  }

  Future<void> _loadSwapRequest({bool silent = false}) async {
    try {
      final sr = await SwapRequestService().getRequest(
        widget.conversation.swapRequestId,
        _currentUid,
      );
      if (mounted) {
        setState(() {
          _swapRequest = sr;
          _loadingSwapRequest = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading swap request: $e');
      if (mounted && !silent) {
        setState(() => _loadingSwapRequest = false);
      }
    }
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final messages = await _messagingService.getMessages(
        widget.conversation.id,
        _currentUid,
      );
      if (mounted) {
        setState(() {
          _messages = messages.reversed.toList();
          _loading = false;
        });

        if (!silent) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      if (mounted && !silent) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _markAsRead() async {
    try {
      await _messagingService.markConversationRead(
        widget.conversation.id,
        _currentUid,
      );
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      final message = await _messagingService.sendMessage(
        widget.conversation.id,
        _currentUid,
        content,
      );

      if (mounted) {
        setState(() {
          _messages.add(message);
          _messageController.clear();
          _sending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'block':
        _showBlockDialog();
        break;
      case 'report':
        _showReportDialog();
        break;
    }
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: HomePage.surface,
        title: const Text(
          'Block User',
          style: TextStyle(color: HomePage.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to block this user? You won\'t be able to message each other anymore.',
          style: TextStyle(color: HomePage.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                final uri = Uri.parse(
                  '${AppConfig.apiBaseUrl}/moderation/block',
                ).replace(queryParameters: {'uid': _currentUid});
                final response = await http.post(
                  uri,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'blocked_uid': _otherUid,
                    'reason': 'blocked_from_chat',
                  }),
                );
                if (!mounted) return;
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User blocked')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to block user: ${response.statusCode}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error blocking user: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    String selectedReason = 'spam';
    final detailsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: HomePage.surface,
          title: const Text(
            'Report User',
            style: TextStyle(color: HomePage.textPrimary),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why are you reporting this user?',
                  style: TextStyle(color: HomePage.textMuted),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  dropdownColor: HomePage.surface,
                  style: const TextStyle(color: HomePage.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    labelStyle: const TextStyle(color: HomePage.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: HomePage.line),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'spam', child: Text('Spam')),
                    DropdownMenuItem(value: 'harassment', child: Text('Harassment')),
                    DropdownMenuItem(
                      value: 'inappropriate_content',
                      child: Text('Inappropriate Content'),
                    ),
                    DropdownMenuItem(value: 'scam', child: Text('Scam')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedReason = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: detailsController,
                  maxLines: 3,
                  style: const TextStyle(color: HomePage.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Details',
                    hintText: 'Please describe the issue...',
                    labelStyle: const TextStyle(color: HomePage.textMuted),
                    hintStyle: const TextStyle(color: HomePage.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: HomePage.line),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 10) {
                      return 'Please provide at least 10 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(dialogContext).pop();
                try {
                  final uri = Uri.parse(
                    '${AppConfig.apiBaseUrl}/moderation/report',
                  ).replace(queryParameters: {'uid': _currentUid});
                  final response = await http.post(
                    uri,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'reported_uid': _otherUid,
                      'reason': selectedReason,
                      'details': detailsController.text.trim(),
                      'conversation_id': widget.conversation.id,
                    }),
                  );
                  if (!mounted) return;
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report submitted. Our team will review it.'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to submit report: ${response.statusCode}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error submitting report: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('Report'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    final hoursCtrl = TextEditingController(text: '1');
    String skillLevel = 'intermediate';
    final notesCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: HomePage.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: HomePage.line),
          ),
          title: const Text(
            'Confirm Swap Completion',
            style: TextStyle(
              color: HomePage.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: hoursCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: HomePage.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Hours spent',
                    hintText: 'e.g. 2',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: skillLevel,
                  dropdownColor: HomePage.surface,
                  style: const TextStyle(color: HomePage.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Skill Level',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                    DropdownMenuItem(
                        value: 'intermediate', child: Text('Intermediate')),
                    DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => skillLevel = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  style: const TextStyle(color: HomePage.textPrimary),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'How did the swap go?',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: HomePage.textMuted)),
            ),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      final hours = double.tryParse(hoursCtrl.text.trim());
                      if (hours == null || hours <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter valid hours.')),
                        );
                        return;
                      }
                      setDialogState(() => submitting = true);
                      try {
                        final updated = await SwapRequestService()
                            .confirmCompletion(
                          _swapRequest!.id,
                          _currentUid,
                          hours: hours,
                          skillLevel: skillLevel,
                          notes: notesCtrl.text.trim().isNotEmpty
                              ? notesCtrl.text.trim()
                              : null,
                        );
                        if (mounted) {
                          setState(() => _swapRequest = updated);
                          _loadMessages(silent: true);
                        }
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      } catch (e) {
                        debugPrint('Confirm error: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      } finally {
                        if (ctx.mounted) {
                          setDialogState(() => submitting = false);
                        }
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: HomePage.accent,
                foregroundColor: Colors.white,
              ),
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionBanner() {
    final sr = _swapRequest;
    if (sr == null || _loadingSwapRequest) return const SizedBox.shrink();

    // Only show for accepted or completed swaps
    if (sr.status != SwapRequestStatus.accepted &&
        sr.status != SwapRequestStatus.completed) {
      return const SizedBox.shrink();
    }

    final isRequester = _currentUid == sr.requesterUid;
    final iConfirmed =
        isRequester ? sr.requesterConfirmed : sr.recipientConfirmed;
    final theyConfirmed =
        isRequester ? sr.recipientConfirmed : sr.requesterConfirmed;

    final other = widget.conversation.otherParticipant;
    final otherName = other?.displayName ?? 'the other user';

    // Both confirmed / completed
    if (sr.isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: const Color(0xFF0D2818),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: HomePage.success, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Swap completed! Points have been awarded.',
                style: TextStyle(
                  color: HomePage.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // I confirmed, waiting for them
    if (iConfirmed && !theyConfirmed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: const Color(0xFF1A1333),
        child: Row(
          children: [
            const Icon(Icons.hourglass_top, color: HomePage.accentAlt, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Waiting for $otherName to confirm completion...',
                style: const TextStyle(
                  color: HomePage.accentAlt,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // They confirmed, I haven't
    if (!iConfirmed && theyConfirmed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: const Color(0xFF1A2B1A),
        child: Row(
          children: [
            const Icon(Icons.celebration, color: Color(0xFFF59E0B), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$otherName has confirmed completion! Confirm your side to earn points.',
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 30,
              child: FilledButton(
                onPressed: _showCompletionDialog,
                style: FilledButton.styleFrom(
                  backgroundColor: HomePage.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Confirm', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      );
    }

    // Neither confirmed
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: HomePage.surface,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Swap in progress. Done exchanging skills?',
              style: TextStyle(
                color: HomePage.textMuted,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 32,
            child: FilledButton.icon(
              onPressed: _showCompletionDialog,
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Mark Complete', style: TextStyle(fontSize: 12)),
              style: FilledButton.styleFrom(
                backgroundColor: HomePage.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final other = widget.conversation.otherParticipant;
    final displayName = other?.displayName ?? 'User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: HomePage.bg,
      appBar: AppBar(
        backgroundColor: HomePage.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HomePage.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: other?.photoUrl != null && other!.photoUrl!.isNotEmpty
                  ? NetworkImage(other.photoUrl!)
                  : null,
              backgroundColor: HomePage.surfaceAlt,
              child: other?.photoUrl == null || other!.photoUrl!.isEmpty
                  ? Text(
                      initial,
                      style: const TextStyle(
                        color: HomePage.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: HomePage.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (other?.skillsToOffer != null) ...[
                  Text(
                    other!.skillsToOffer!.length > 30
                        ? '${other.skillsToOffer!.substring(0, 30)}...'
                        : other.skillsToOffer!,
                    style: const TextStyle(
                      color: HomePage.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            icon: const Icon(Icons.more_vert, color: HomePage.textMuted),
            color: HomePage.surface,
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Block User', style: TextStyle(color: HomePage.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text('Report', style: TextStyle(color: HomePage.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCompletionBanner(),
          Expanded(child: _buildMessageList()),
          MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            sending: _sending,
          ),
        ],
      ),
    );
  }

  Widget _buildSwapStatusBanner() {
    final swap = _swapRequest!;
    final isRequester = swap.requesterUid == _currentUid;

    // Determine banner based on status
    if (swap.isCompleted) {
      // Show earnings summary
      final pointsEarned = isRequester
          ? swap.completion?.requesterPointsEarned ?? 0
          : swap.completion?.recipientPointsEarned ?? 0;
      final creditsEarned = isRequester
          ? swap.completion?.requesterCreditsEarned ?? 0
          : swap.completion?.recipientCreditsEarned ?? 0;

      return _buildCompletedBanner(
        pointsEarned: pointsEarned,
        creditsEarned: creditsEarned,
        hours: swap.completion?.finalHours ?? 0,
        swapType: swap.swapType,
        onReview: () => _showReviewDialog(),
      );
    }

    if (swap.isPendingCompletion) {
      final completion = swap.completion;
      final iMarkedComplete = isRequester
          ? completion?.requester.markedComplete ?? false
          : completion?.recipient.markedComplete ?? false;

      if (iMarkedComplete) {
        return _buildBanner(
          icon: Icons.hourglass_top,
          color: const Color(0xFFF59E0B),
          text: 'Waiting for your partner to verify completion...',
          actionLabel: null,
          onAction: null,
        );
      } else {
        final partnerHours = isRequester
            ? completion?.recipient.hoursClaimed
            : completion?.requester.hoursClaimed;
        return _buildBanner(
          icon: Icons.pending_actions,
          color: const Color(0xFF0EA5E9),
          text: 'Your partner marked ${partnerHours ?? 0} hours complete. Verify?',
          actionLabel: 'Respond',
          onAction: () => _showVerifyDialog(),
        );
      }
    }

    if (swap.isDisputed) {
      return _buildBanner(
        icon: Icons.warning_amber_rounded,
        color: Colors.red,
        text: 'This swap is disputed. Our team is reviewing it.',
        actionLabel: null,
        onAction: null,
      );
    }

    if (swap.isAccepted) {
      final swapTypeText = swap.isDirect 
          ? 'Skill exchange' 
          : 'Points-based (${swap.pointsReserved ?? swap.pointsOffered ?? 0} pts)';
      return _buildBanner(
        icon: Icons.handshake,
        color: const Color(0xFF7C3AED),
        text: '$swapTypeText swap accepted! Mark complete when done.',
        actionLabel: 'Mark Complete',
        onAction: () => _showMarkCompleteDialog(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBanner({
    required IconData icon,
    required Color color,
    required String text,
    required String? actionLabel,
    required VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: color.withOpacity(0.1),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedBanner({
    required int pointsEarned,
    required int creditsEarned,
    required double hours,
    required SwapType swapType,
    required VoidCallback onReview,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF22C55E).withOpacity(0.15),
            const Color(0xFF10B981).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF22C55E).withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF22C55E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Swap Completed!',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${hours.toStringAsFixed(1)} hours exchanged',
                      style: TextStyle(
                        color: HomePage.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: swapType == SwapType.direct
                      ? HomePage.accent.withOpacity(0.2)
                      : HomePage.accentAlt.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      swapType == SwapType.direct ? Icons.swap_horiz : Icons.toll,
                      size: 14,
                      color: swapType == SwapType.direct
                          ? HomePage.accent
                          : HomePage.accentAlt,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      swapType.displayName,
                      style: TextStyle(
                        color: swapType == SwapType.direct
                            ? HomePage.accent
                            : HomePage.accentAlt,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Earnings row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HomePage.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: HomePage.line),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.toll, color: Color(0xFFF59E0B), size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '+$pointsEarned',
                        style: TextStyle(
                          color: pointsEarned > 0 ? const Color(0xFFF59E0B) : HomePage.textMuted,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'pts',
                        style: TextStyle(
                          color: HomePage.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: HomePage.line),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars, color: HomePage.accentAlt, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '+$creditsEarned',
                        style: const TextStyle(
                          color: HomePage.accentAlt,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'credits',
                        style: TextStyle(
                          color: HomePage.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onReview,
              icon: const Icon(Icons.rate_review, size: 18),
              label: const Text('Leave a Review'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkCompleteDialog() {
    double hours = 1.0;
    String skillLevel = 'intermediate';
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: HomePage.surface,
          title: const Text(
            'Mark Swap Complete',
            style: TextStyle(color: HomePage.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How many hours did you exchange?',
                style: TextStyle(color: HomePage.textMuted),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (hours > 0.5) {
                        setDialogState(() => hours -= 0.5);
                      }
                    },
                    icon: const Icon(Icons.remove_circle, color: HomePage.accent),
                  ),
                  Text(
                    '${hours.toStringAsFixed(1)} hours',
                    style: const TextStyle(
                      color: HomePage.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (hours < 20) {
                        setDialogState(() => hours += 0.5);
                      }
                    },
                    icon: const Icon(Icons.add_circle, color: HomePage.accent),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Partner\'s skill level:',
                style: TextStyle(color: HomePage.textMuted),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'beginner', label: Text('Beginner')),
                  ButtonSegment(value: 'intermediate', label: Text('Intermediate')),
                  ButtonSegment(value: 'advanced', label: Text('Advanced')),
                ],
                selected: {skillLevel},
                onSelectionChanged: (value) {
                  setDialogState(() => skillLevel = value.first);
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(HomePage.textPrimary),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  hintText: 'Optional notes...',
                  hintStyle: const TextStyle(color: HomePage.textMuted),
                  filled: true,
                  fillColor: HomePage.surfaceAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: HomePage.textPrimary),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _markComplete(hours, skillLevel, notesController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: HomePage.accent),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markComplete(double hours, String skillLevel, String notes) async {
    try {
      final updated = await _swapRequestService.markComplete(
        requestId: widget.conversation.swapRequestId,
        uid: _currentUid,
        hoursExchanged: hours,
        skillLevel: skillLevel,
        notes: notes.isEmpty ? null : notes,
      );
      if (mounted) {
        setState(() => _swapRequest = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swap marked as complete! Waiting for partner verification.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showVerifyDialog() {
    final disputeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HomePage.surface,
        title: const Text(
          'Verify Completion',
          style: TextStyle(color: HomePage.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your partner has marked this swap as complete. Do you agree?',
              style: TextStyle(color: HomePage.textMuted),
            ),
            const SizedBox(height: 16),
            const Text(
              'If you dispute, please explain why:',
              style: TextStyle(color: HomePage.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: disputeController,
              decoration: InputDecoration(
                hintText: 'Reason for dispute (optional)...',
                hintStyle: const TextStyle(color: HomePage.textMuted),
                filled: true,
                fillColor: HomePage.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: HomePage.textPrimary),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _verifyCompletion(false, disputeController.text);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Dispute'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _verifyCompletion(true, null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyCompletion(bool verify, String? disputeReason) async {
    try {
      final updated = await _swapRequestService.verifyCompletion(
        requestId: widget.conversation.swapRequestId,
        uid: _currentUid,
        verify: verify,
        disputeReason: disputeReason,
      );
      if (mounted) {
        setState(() => _swapRequest = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verify ? 'Swap completed!' : 'Swap disputed. Our team will review.'),
            backgroundColor: verify ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReviewDialog() {
    int rating = 5;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: HomePage.surface,
          title: const Text(
            'Leave a Review',
            style: TextStyle(color: HomePage.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How was your experience?',
                style: TextStyle(color: HomePage.textMuted),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    onPressed: () => setDialogState(() => rating = i + 1),
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF59E0B),
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  hintText: 'Write your review...',
                  hintStyle: const TextStyle(color: HomePage.textMuted),
                  filled: true,
                  fillColor: HomePage.surfaceAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: HomePage.textPrimary),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _submitReview(rating, reviewController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: HomePage.accent),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview(int rating, String reviewText) async {
    try {
      await _reviewService.submitReview(
        uid: _currentUid,
        swapRequestId: widget.conversation.swapRequestId,
        rating: rating,
        reviewText: reviewText.isEmpty ? null : reviewText,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted! Thank you.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMessageList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: HomePage.accent),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: HomePage.textMuted),
            const SizedBox(height: 16),
            Text(
              'Error loading messages',
              style: const TextStyle(color: HomePage.textPrimary),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadMessages,
              style: ElevatedButton.styleFrom(backgroundColor: HomePage.accent),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet. Say hello!',
          style: TextStyle(color: HomePage.textMuted),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final message = _messages[i];
        final isMe = message.senderUid == _currentUid;
        final isLast = i == _messages.length - 1;

        return MessageBubble(
          message: message,
          isMe: isMe,
          showReadReceipt: isMe && isLast,
        );
      },
    );
  }
}
