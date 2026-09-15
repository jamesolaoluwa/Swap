// lib/pages/my_swaps_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/swap_request.dart';
import '../services/swap_request_service.dart';
import '../services/messaging_service.dart';
import 'home_page.dart';
import 'messages/chat_page.dart';
import '../widgets/app_sidebar.dart';

class MySwapsPage extends StatefulWidget {
  const MySwapsPage({super.key});

  @override
  State<MySwapsPage> createState() => _MySwapsPageState();
}

class _MySwapsPageState extends State<MySwapsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _swapService = SwapRequestService();

  List<SwapRequest> _incomingRequests = [];
  List<SwapRequest> _outgoingRequests = [];
  List<SwapRequest> _activeSwaps = [];
  List<SwapRequest> _completedSwaps = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(() => setState(() {}));
    _loadSwaps();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSwaps() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final incoming = await _swapService.getIncomingRequests(uid);
      final outgoing = await _swapService.getOutgoingRequests(uid);

      if (mounted) {
        setState(() {
          // Filter incoming: only pending requests
          _incomingRequests =
              incoming.where((r) => r.status == SwapRequestStatus.pending).toList();

          // Filter outgoing: only pending requests
          _outgoingRequests =
              outgoing.where((r) => r.status == SwapRequestStatus.pending).toList();

          // Active swaps: accepted or pending completion from both lists
          _activeSwaps = [
            ...incoming.where((r) => r.isActive),
            ...outgoing.where((r) => r.isActive),
          ];

          // Completed swaps from both lists
          _completedSwaps = [
            ...incoming.where((r) => r.isCompleted),
            ...outgoing.where((r) => r.isCompleted),
          ];

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _respondToRequest(SwapRequest request, bool accept) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await _swapService.respondToRequest(request.id, uid, accept);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Swap request accepted!' : 'Swap request declined'),
          backgroundColor: accept ? Colors.green : Colors.orange,
        ),
      );
      _loadSwaps();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelRequest(SwapRequest request) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HomePage.surface,
        title: const Text(
          'Cancel Request?',
          style: TextStyle(color: HomePage.textPrimary),
        ),
        content: Text(
          request.isIndirect
              ? 'Your ${request.pointsReserved ?? 0} reserved points will be refunded.'
              : 'Are you sure you want to cancel this swap request?',
          style: TextStyle(color: HomePage.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _swapService.cancelRequest(request.id, uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Swap request cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadSwaps();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePage.bg,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSidebar(active: 'My Swaps'),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                    child: Row(
                      children: [
                        const Text(
                          'My Swaps',
                          style: TextStyle(
                            color: HomePage.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _loadSwaps,
                          icon: const Icon(Icons.refresh),
                          color: HomePage.textMuted,
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: HomePage.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HomePage.line),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicator: BoxDecoration(
                          color: HomePage.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: HomePage.accentAlt),
                        ),
                        padding: const EdgeInsets.all(6),
                        labelColor: Colors.white,
                        unselectedLabelColor: HomePage.textMuted,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                        tabs: [
                          _buildTab('Incoming', _incomingRequests.length),
                          _buildTab('Outgoing', _outgoingRequests.length),
                          _buildTab('Active', _activeSwaps.length),
                          _buildTab('Completed', _completedSwaps.length),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                              ? _buildErrorState()
                              : TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildIncomingTab(),
                                    _buildOutgoingTab(),
                                    _buildActiveTab(),
                                    _buildCompletedTab(),
                                  ],
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: HomePage.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            'Failed to load swaps',
            style: TextStyle(color: HomePage.textPrimary, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: TextStyle(color: HomePage.textMuted),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadSwaps,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingTab() {
    if (_incomingRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_rounded,
        title: 'No incoming requests',
        subtitle: 'When someone sends you a swap request, it will appear here.',
      );
    }

    return ListView.separated(
      itemCount: _incomingRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = _incomingRequests[index];
        return _SwapRequestCard(
          request: request,
          isIncoming: true,
          onAccept: () => _respondToRequest(request, true),
          onDecline: () => _respondToRequest(request, false),
        );
      },
    );
  }

  Widget _buildOutgoingTab() {
    if (_outgoingRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send_outlined,
        title: 'No outgoing requests',
        subtitle: 'Your pending swap requests to others will appear here.',
      );
    }

    return ListView.separated(
      itemCount: _outgoingRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = _outgoingRequests[index];
        return _SwapRequestCard(
          request: request,
          isIncoming: false,
          onCancel: () => _cancelRequest(request),
        );
      },
    );
  }

  Widget _buildActiveTab() {
    if (_activeSwaps.isEmpty) {
      return _buildEmptyState(
        icon: Icons.handshake_outlined,
        title: 'No active swaps',
        subtitle: 'When a swap is accepted, it will appear here until completed.',
      );
    }

    return ListView.separated(
      itemCount: _activeSwaps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = _activeSwaps[index];
        return _ActiveSwapCard(
          request: request,
          onOpenChat: () => _openConversation(request),
        );
      },
    );
  }

  Widget _buildCompletedTab() {
    if (_completedSwaps.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'No completed swaps',
        subtitle: 'Your successfully completed swaps will appear here.',
      );
    }

    return ListView.separated(
      itemCount: _completedSwaps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = _completedSwaps[index];
        return _CompletedSwapCard(request: request);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: HomePage.textMuted),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: HomePage.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: HomePage.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _openConversation(SwapRequest request) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (request.conversationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No conversation found for this swap'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch the conversation
      final messagingService = MessagingService();
      final conversation = await messagingService.getConversation(request.conversationId!, uid);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatPage(conversation: conversation),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Swap Request Card for incoming/outgoing tabs
class _SwapRequestCard extends StatelessWidget {
  final SwapRequest request;
  final bool isIncoming;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;

  const _SwapRequestCard({
    required this.request,
    required this.isIncoming,
    this.onAccept,
    this.onDecline,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final otherUser = isIncoming ? request.requesterProfile : request.recipientProfile;
    final displayName = otherUser?.displayName ?? 'Unknown User';

    return Card(
      color: HomePage.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: HomePage.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and swap type badge
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: HomePage.surfaceAlt,
                  foregroundImage: otherUser?.photoUrl != null
                      ? NetworkImage(otherUser!.photoUrl!)
                      : null,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: HomePage.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: HomePage.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        isIncoming ? 'wants to swap with you' : 'waiting for response',
                        style: TextStyle(
                          color: HomePage.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _SwapTypeBadge(type: request.swapType),
              ],
            ),
            const SizedBox(height: 16),

            // Swap details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HomePage.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.school_outlined,
                    label: isIncoming ? 'They need' : 'You need',
                    value: request.requesterNeed,
                  ),
                  const SizedBox(height: 8),
                  if (request.isDirect)
                    _DetailRow(
                      icon: Icons.lightbulb_outline,
                      label: isIncoming ? 'They offer' : 'You offer',
                      value: request.requesterOffer ?? 'Not specified',
                    )
                  else
                    _DetailRow(
                      icon: Icons.toll,
                      label: 'Points offered',
                      value: '${request.pointsReserved ?? request.pointsOffered ?? 0} pts',
                      valueColor: HomePage.accentAlt,
                    ),
                ],
              ),
            ),

            // Message if present
            if (request.message != null && request.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HomePage.surfaceAlt.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: HomePage.line),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote, color: HomePage.textMuted, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.message!,
                        style: TextStyle(
                          color: HomePage.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Action buttons
            if (isIncoming)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onAccept,
                      style: FilledButton.styleFrom(
                        backgroundColor: HomePage.accent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Cancel Request'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Active Swap Card
class _ActiveSwapCard extends StatelessWidget {
  final SwapRequest request;
  final VoidCallback onOpenChat;

  const _ActiveSwapCard({
    required this.request,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isRequester = request.requesterUid == uid;
    final otherUser = isRequester ? request.recipientProfile : request.requesterProfile;
    final displayName = otherUser?.displayName ?? 'Unknown User';

    return Card(
      color: HomePage.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: HomePage.accentAlt.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: HomePage.surfaceAlt,
                  foregroundImage: otherUser?.photoUrl != null
                      ? NetworkImage(otherUser!.photoUrl!)
                      : null,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: HomePage.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: HomePage.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _StatusBadge(status: request.status),
                    ],
                  ),
                ),
                _SwapTypeBadge(type: request.swapType),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HomePage.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRequester ? 'You need' : 'You teach',
                          style: TextStyle(color: HomePage.textMuted, fontSize: 12),
                        ),
                        Text(
                          request.requesterNeed,
                          style: const TextStyle(
                            color: HomePage.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (request.isDirect) ...[
                    Icon(Icons.swap_horiz, color: HomePage.textMuted),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isRequester ? 'You teach' : 'You need',
                            style: TextStyle(color: HomePage.textMuted, fontSize: 12),
                          ),
                          Text(
                            request.requesterOffer ?? '',
                            style: const TextStyle(
                              color: HomePage.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onOpenChat,
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Open Chat'),
              style: FilledButton.styleFrom(
                backgroundColor: HomePage.accent,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Completed Swap Card
class _CompletedSwapCard extends StatelessWidget {
  final SwapRequest request;

  const _CompletedSwapCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isRequester = request.requesterUid == uid;
    final otherUser = isRequester ? request.recipientProfile : request.requesterProfile;
    final displayName = otherUser?.displayName ?? 'Unknown User';

    // Get earnings for the current user
    final pointsEarned = isRequester
        ? request.completion?.requesterPointsEarned
        : request.completion?.recipientPointsEarned;
    final creditsEarned = isRequester
        ? request.completion?.requesterCreditsEarned
        : request.completion?.recipientCreditsEarned;

    return Card(
      color: HomePage.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: HomePage.surfaceAlt,
                  foregroundImage: otherUser?.photoUrl != null
                      ? NetworkImage(otherUser!.photoUrl!)
                      : null,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: HomePage.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: HomePage.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Completed ${_formatDate(request.completion?.completedAt)}',
                        style: TextStyle(color: HomePage.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.green,
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

            // Earnings summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HomePage.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Hours',
                          style: TextStyle(color: HomePage.textMuted, fontSize: 12),
                        ),
                        Text(
                          '${request.completion?.finalHours ?? 0}h',
                          style: const TextStyle(
                            color: HomePage.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: HomePage.line,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Points',
                          style: TextStyle(color: HomePage.textMuted, fontSize: 12),
                        ),
                        Text(
                          '+${pointsEarned ?? 0}',
                          style: TextStyle(
                            color: pointsEarned != null && pointsEarned > 0
                                ? Colors.green
                                : HomePage.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: HomePage.line,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Credits',
                          style: TextStyle(color: HomePage.textMuted, fontSize: 12),
                        ),
                        Text(
                          '+${creditsEarned ?? 0}',
                          style: const TextStyle(
                            color: HomePage.accentAlt,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

// Swap Type Badge
class _SwapTypeBadge extends StatelessWidget {
  final SwapType type;

  const _SwapTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isDirect = type == SwapType.direct;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDirect
            ? HomePage.accent.withOpacity(0.2)
            : HomePage.accentAlt.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDirect ? Icons.swap_horiz : Icons.toll,
            size: 14,
            color: isDirect ? HomePage.accent : HomePage.accentAlt,
          ),
          const SizedBox(width: 4),
          Text(
            type.displayName,
            style: TextStyle(
              color: isDirect ? HomePage.accent : HomePage.accentAlt,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Status Badge
class _StatusBadge extends StatelessWidget {
  final SwapRequestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (status) {
      case SwapRequestStatus.accepted:
        label = 'In Progress';
        color = Colors.blue;
        break;
      case SwapRequestStatus.pendingCompletion:
        label = 'Awaiting Verification';
        color = Colors.orange;
        break;
      default:
        label = status.name;
        color = HomePage.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// Detail Row Helper
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: HomePage.textMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: HomePage.textMuted, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? HomePage.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
