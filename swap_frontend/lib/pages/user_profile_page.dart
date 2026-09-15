import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;

import 'home_page.dart';
import '../models/swap_request.dart';
import '../services/swap_request_service.dart';
import '../services/points_service.dart';

/// Page to view another user's profile (read-only)
class UserProfilePage extends StatelessWidget {
  final String uid;
  final String? initialName;
  final String? initialPhotoUrl;

  const UserProfilePage({
    super.key,
    required this.uid,
    this.initialName,
    this.initialPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwnProfile = currentUid == uid;

    return Scaffold(
      backgroundColor: HomePage.bg,
      appBar: AppBar(
        backgroundColor: HomePage.bg,
        foregroundColor: HomePage.textPrimary,
        elevation: 0,
        title: Text(initialName ?? 'Profile'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('profiles')
            .doc(uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_off, size: 64, color: HomePage.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'Profile not found',
                    style: TextStyle(color: HomePage.textMuted, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final data = snap.data!.data()!;
          final name = (data['fullName'] ?? data['displayName'] ?? '')
              .toString()
              .trim();
          final username = (data['username'] ?? '').toString().trim();
          final city = (data['city'] ?? '').toString().trim();
          final bio = (data['bio'] ?? '').toString().trim();
          final photoUrl = data['photoUrl'] as String?;
          final timezone = (data['timezone'] ?? '').toString().trim();

          final verified = (data['verified'] ?? false) == true;
          final topRated = (data['topRated'] ?? false) == true;

          // Stats
          final swapsCompleted = (data['completed_swap_count'] ??
              data['swapsCompleted'] ??
              0) as int;
          final swapCredits = (data['swap_credits'] ?? 0) as int;

          // Skills
          final skillsToOffer =
              (data['skillsToOffer'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              const [];
          final servicesNeeded =
              (data['servicesNeeded'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              const [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile header card
                    Card(
                      color: HomePage.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Banner
                          Container(
                            height: 100,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              gradient: LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 50),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(width: 100),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Wrap(
                                                  spacing: 8,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  children: [
                                                    Text(
                                                      name.isEmpty
                                                          ? 'User'
                                                          : name,
                                                      style: const TextStyle(
                                                        color:
                                                            HomePage.textPrimary,
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                    if (verified)
                                                      _badge(
                                                        Icons.verified,
                                                        'Verified',
                                                        const Color(0xFF22C55E),
                                                      ),
                                                    if (topRated)
                                                      _badge(
                                                        Icons
                                                            .emoji_events_outlined,
                                                        'Top Rated',
                                                        const Color(0xFFF59E0B),
                                                      ),
                                                  ],
                                                ),
                                                if (username.isNotEmpty)
                                                  Text(
                                                    '@$username',
                                                    style: TextStyle(
                                                      color: HomePage.textMuted,
                                                    ),
                                                  ),
                                                const SizedBox(height: 4),
                                                Wrap(
                                                  spacing: 16,
                                                  children: [
                                                    if (city.isNotEmpty)
                                                      _infoRow(
                                                        Icons
                                                            .location_on_outlined,
                                                        city,
                                                      ),
                                                    if (timezone.isNotEmpty)
                                                      _infoRow(
                                                        Icons.access_time,
                                                        timezone,
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Action buttons
                                      if (!isOwnProfile)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: FilledButton.icon(
                                                onPressed: () {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Send a swap request to start messaging!',
                                                      ),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(
                                                    Icons.message_outlined),
                                                label: const Text('Message'),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      HomePage.accent,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () => _showSwapRequestDialog(
                                                  context,
                                                  recipientUid: uid,
                                                  recipientName: name,
                                                  recipientSkills: skillsToOffer,
                                                ),
                                                icon: const Icon(
                                                    Icons.swap_horiz),
                                                label:
                                                    const Text('Request Swap'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      HomePage.textPrimary,
                                                  side: BorderSide(
                                                    color: HomePage.line,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                // Avatar
                                Positioned(
                                  left: 0,
                                  top: -40,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF9F67FF),
                                          Color(0xFF7C3AED),
                                        ],
                                      ),
                                    ),
                                    child: FutureBuilder<String?>(
                                      future: _resolvePhotoUrl(photoUrl),
                                      builder: (context, snap) {
                                        final url = snap.data;
                                        return CircleAvatar(
                                          radius: 44,
                                          backgroundColor: HomePage.surfaceAlt,
                                          foregroundImage:
                                              (url != null && url.isNotEmpty)
                                                  ? NetworkImage(url)
                                                  : null,
                                          child: (url == null || url.isEmpty)
                                              ? Text(
                                                  name.isNotEmpty
                                                      ? name[0].toUpperCase()
                                                      : 'U',
                                                  style: const TextStyle(
                                                    color: HomePage.textPrimary,
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                )
                                              : null,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            Icons.swap_horiz,
                            'Swaps',
                            swapsCompleted.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            Icons.monetization_on_outlined,
                            'Credits',
                            swapCredits.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            Icons.lightbulb_outline,
                            'Skills',
                            skillsToOffer.length.toString(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Bio
                    if (bio.isNotEmpty)
                      _sectionCard(
                        'About',
                        Text(
                          bio,
                          style: const TextStyle(color: HomePage.textPrimary),
                        ),
                      ),

                    if (bio.isNotEmpty) const SizedBox(height: 16),

                    // Skills to offer
                    if (skillsToOffer.isNotEmpty)
                      _sectionCard(
                        'Skills to Offer',
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: skillsToOffer
                              .map(
                                (e) => _skillChip(
                                  '${e['name']} • ${e['level']}',
                                ),
                              )
                              .toList(),
                        ),
                      ),

                    if (skillsToOffer.isNotEmpty) const SizedBox(height: 16),

                    // Services needed
                    if (servicesNeeded.isNotEmpty)
                      _sectionCard(
                        'Looking For',
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: servicesNeeded
                              .map(
                                (e) => _skillChip(
                                  '${e['name']} • ${e['level']}',
                                ),
                              )
                              .toList(),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Swap History
                    _SwapHistorySection(uid: uid),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Future<String?> _resolvePhotoUrl(String? raw) async {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('gs://')) {
      try {
        return await storage.FirebaseStorage.instance
            .refFromURL(raw)
            .getDownloadURL();
      } catch (_) {
        return null;
      }
    }
    return raw;
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: HomePage.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomePage.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: HomePage.textMuted),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: HomePage.textMuted, fontSize: 14)),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value) {
    return Card(
      color: HomePage.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: HomePage.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: HomePage.accentAlt, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: HomePage.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(label, style: TextStyle(color: HomePage.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, Widget child) {
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
            Text(
              title,
              style: const TextStyle(
                color: HomePage.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _skillChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: HomePage.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomePage.line),
      ),
      child: Text(
        text,
        style: const TextStyle(color: HomePage.textPrimary, fontSize: 13),
      ),
    );
  }
}

/// Dialog for creating a swap request (private version for profile page)
void _showSwapRequestDialog(
  BuildContext context, {
  required String recipientUid,
  required String recipientName,
  required List<Map<String, dynamic>> recipientSkills,
}) {
  showSwapRequestDialog(
    context,
    recipientUid: recipientUid,
    recipientName: recipientName,
    recipientSkills: recipientSkills,
  );
}

/// Public function to show swap request dialog - can be called from anywhere
void showSwapRequestDialog(
  BuildContext context, {
  required String recipientUid,
  required String recipientName,
  List<Map<String, dynamic>> recipientSkills = const [],
  String? preSelectedSkill,
}) {
  showDialog(
    context: context,
    builder: (context) => SwapRequestDialog(
      recipientUid: recipientUid,
      recipientName: recipientName,
      recipientSkills: recipientSkills,
      preSelectedSkill: preSelectedSkill,
    ),
  );
}

class SwapRequestDialog extends StatefulWidget {
  final String recipientUid;
  final String recipientName;
  final List<Map<String, dynamic>> recipientSkills;
  final String? preSelectedSkill;

  const SwapRequestDialog({
    super.key,
    required this.recipientUid,
    required this.recipientName,
    this.recipientSkills = const [],
    this.preSelectedSkill,
  });

  @override
  State<SwapRequestDialog> createState() => _SwapRequestDialogState();
}

class _SwapRequestDialogState extends State<SwapRequestDialog> {
  SwapType _swapType = SwapType.direct;
  String? _selectedSkillNeed;
  String? _selectedSkillOffer;
  final _messageController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');
  
  bool _isLoading = false;
  int _userPoints = 0;
  List<Map<String, dynamic>> _userSkills = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Use pre-selected skill if provided, otherwise use first from list
    if (widget.preSelectedSkill != null && widget.preSelectedSkill!.isNotEmpty) {
      _selectedSkillNeed = widget.preSelectedSkill;
    } else if (widget.recipientSkills.isNotEmpty) {
      _selectedSkillNeed = widget.recipientSkills.first['name'] as String?;
    }
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('SwapDialog: Loading data for uid: $uid');
    if (uid == null) return;

    // Load points balance (try backend first, fallback to Firestore)
    int points = 0;
    try {
      final pointsService = PointsService();
      final balance = await pointsService.getBalance(uid);
      points = balance.swapPoints;
      debugPrint('SwapDialog: Points from backend: $points');
    } catch (e) {
      debugPrint('SwapDialog: Points service unavailable: $e');
      // Fallback: try loading from Firestore profile
      try {
        final profileDoc = await FirebaseFirestore.instance
            .collection('profiles')
            .doc(uid)
            .get();
        points = (profileDoc.data()?['swap_points'] ??
                  profileDoc.data()?['swapPoints'] ?? 0) as int;
        debugPrint('SwapDialog: Points from Firestore fallback: $points');
      } catch (e2) {
        debugPrint('SwapDialog: Firestore points fallback failed: $e2');
      }
    }

    try {
      // Load user's skills from profile
      final profileDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(uid)
          .get();

      // Also get points from profile if not already loaded from backend
      if (points == 0) {
        points = (profileDoc.data()?['swap_points'] ??
                  profileDoc.data()?['swapPoints'] ?? 0) as int;
        debugPrint('SwapDialog: Points from profile: $points');
      }

      final profileSkills = (profileDoc.data()?['skillsToOffer'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ?? [];
      debugPrint('SwapDialog: Profile skills: ${profileSkills.length}');
      
      // Also load user's posted skills from skills collection
      final postedSkillsSnapshot = await FirebaseFirestore.instance
          .collection('skills')
          .where('creatorUid', isEqualTo: uid)
          .get();
      
      debugPrint('SwapDialog: Posted skills docs: ${postedSkillsSnapshot.docs.length}');
      
      final postedSkills = postedSkillsSnapshot.docs.map((doc) {
        final data = doc.data();
        debugPrint('SwapDialog: Found posted skill: ${data['title']}');
        return {
          'name': data['title'] ?? '',
          'level': data['difficulty'] ?? 'Intermediate',
          'category': data['category'] ?? '',
        };
      }).toList();
      
      // Merge skills, avoiding duplicates by name
      final allSkillNames = <String>{};
      final mergedSkills = <Map<String, dynamic>>[];
      
      for (final skill in [...profileSkills, ...postedSkills]) {
        final name = skill['name'] as String? ?? '';
        if (name.isNotEmpty && !allSkillNames.contains(name)) {
          allSkillNames.add(name);
          mergedSkills.add(skill);
        }
      }
      
      debugPrint('SwapDialog: Total merged skills: ${mergedSkills.length}');
      
      if (mounted) {
        setState(() {
          _userPoints = points;
          _userSkills = mergedSkills;
        });
      }
    } catch (e) {
      debugPrint('SwapDialog: Error loading skills: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  int get _pointsOffered => int.tryParse(_pointsController.text) ?? 0;

  bool get _canSubmit {
    if (_selectedSkillNeed == null || _selectedSkillNeed!.isEmpty) return false;
    
    if (_swapType == SwapType.direct) {
      return _selectedSkillOffer != null && _selectedSkillOffer!.isNotEmpty;
    } else {
      return _pointsOffered > 0 && _pointsOffered <= _userPoints;
    }
  }

  Future<void> _submitRequest() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      final service = SwapRequestService();
      await service.createRequest(
        requesterUid: uid,
        recipientUid: widget.recipientUid,
        requesterNeed: _selectedSkillNeed!,
        requesterOffer: _swapType == SwapType.direct 
            ? _selectedSkillOffer 
            : null,
        message: _messageController.text.trim().isEmpty 
            ? null 
            : _messageController.text.trim(),
        swapType: _swapType,
        pointsOffered: _swapType == SwapType.indirect ? _pointsOffered : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Swap request sent to ${widget.recipientName}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HomePage.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: HomePage.line),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.swap_horiz, color: HomePage.accent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Request Swap',
                          style: TextStyle(
                            color: HomePage.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'with ${widget.recipientName}',
                          style: TextStyle(
                            color: HomePage.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: HomePage.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Swap Type Toggle
              Container(
                decoration: BoxDecoration(
                  color: HomePage.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: HomePage.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SwapTypeOption(
                        type: SwapType.direct,
                        selected: _swapType == SwapType.direct,
                        onTap: () => setState(() => _swapType = SwapType.direct),
                      ),
                    ),
                    Expanded(
                      child: _SwapTypeOption(
                        type: SwapType.indirect,
                        selected: _swapType == SwapType.indirect,
                        onTap: () => setState(() => _swapType = SwapType.indirect),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // What you need (dropdown of recipient's skills or pre-selected)
              Text(
                'What skill do you need?',
                style: TextStyle(
                  color: HomePage.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // If pre-selected skill, show as read-only; otherwise show dropdown
              if (widget.preSelectedSkill != null && widget.preSelectedSkill!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: HomePage.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: HomePage.accent.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: HomePage.accent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.preSelectedSkill!,
                          style: const TextStyle(
                            color: HomePage.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedSkillNeed,
                  dropdownColor: HomePage.surface,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: HomePage.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: HomePage.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: HomePage.line),
                    ),
                  ),
                  style: const TextStyle(color: HomePage.textPrimary),
                  items: widget.recipientSkills.map((skill) {
                    final name = skill['name'] as String? ?? 'Unknown';
                    final level = skill['level'] as String? ?? '';
                    return DropdownMenuItem(
                      value: name,
                      child: Text('$name${level.isNotEmpty ? ' ($level)' : ''}'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedSkillNeed = value),
                  hint: Text(
                    'Select a skill',
                    style: TextStyle(color: HomePage.textMuted),
                  ),
                ),
              const SizedBox(height: 20),

              // Conditional: Direct swap - what you offer
              if (_swapType == SwapType.direct) ...[
                Text(
                  'What skill will you offer in return?',
                  style: TextStyle(
                    color: HomePage.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (_userSkills.isEmpty)
                  // No skills message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange, size: 24),
                        const SizedBox(height: 8),
                        const Text(
                          'You haven\'t added any skills to your profile yet.',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Go to Profile → Edit to add skills you can offer in swaps.',
                          style: TextStyle(
                            color: HomePage.textMuted,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  // Dropdown of user's skills
                  DropdownButtonFormField<String>(
                    value: _selectedSkillOffer,
                    dropdownColor: HomePage.surface,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: HomePage.surfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: HomePage.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: HomePage.line),
                      ),
                    ),
                    style: const TextStyle(color: HomePage.textPrimary),
                    items: _userSkills.map((skill) {
                      final name = skill['name'] as String? ?? 'Unknown';
                      final level = skill['level'] as String? ?? '';
                      return DropdownMenuItem(
                        value: name,
                        child: Text('$name${level.isNotEmpty ? ' ($level)' : ''}'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedSkillOffer = value),
                    hint: Text(
                      'Select a skill to offer',
                      style: TextStyle(color: HomePage.textMuted),
                    ),
                  ),
              ],

              // Conditional: Indirect swap - points offered
              if (_swapType == SwapType.indirect) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HomePage.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: HomePage.accentAlt.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.toll, color: HomePage.accentAlt, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Your Points: $_userPoints',
                            style: TextStyle(
                              color: HomePage.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Points to offer:',
                        style: TextStyle(
                          color: HomePage.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _pointsController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: HomePage.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: HomePage.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: HomePage.line),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: HomePage.line),
                          ),
                          suffixText: 'pts',
                          suffixStyle: TextStyle(
                            color: HomePage.textMuted,
                            fontSize: 16,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_pointsOffered > _userPoints)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Insufficient points',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Optional message
              Text(
                'Message (optional)',
                style: TextStyle(
                  color: HomePage.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                style: const TextStyle(color: HomePage.textPrimary),
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Introduce yourself and explain what you\'re looking for...',
                  hintStyle: TextStyle(color: HomePage.textMuted),
                  filled: true,
                  fillColor: HomePage.surfaceAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: HomePage.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: HomePage.line),
                  ),
                  counterStyle: TextStyle(color: HomePage.textMuted),
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              FilledButton(
                onPressed: _canSubmit && !_isLoading ? _submitRequest : null,
                style: FilledButton.styleFrom(
                  backgroundColor: HomePage.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: HomePage.surfaceAlt,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _swapType == SwapType.direct
                            ? 'Send Swap Request'
                            : 'Send Request ($_pointsOffered pts)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwapTypeOption extends StatelessWidget {
  final SwapType type;
  final bool selected;
  final VoidCallback onTap;

  const _SwapTypeOption({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? HomePage.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: HomePage.accent, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              type == SwapType.direct ? Icons.swap_horiz : Icons.toll,
              color: selected ? HomePage.accent : HomePage.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              type.displayName,
              style: TextStyle(
                color: selected ? HomePage.accent : HomePage.textPrimary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            Text(
              type == SwapType.direct ? 'Trade skills' : 'Pay with points',
              style: TextStyle(
                color: HomePage.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapHistorySection extends StatefulWidget {
  const _SwapHistorySection({required this.uid});
  final String uid;

  @override
  State<_SwapHistorySection> createState() => _SwapHistorySectionState();
}

class _SwapHistorySectionState extends State<_SwapHistorySection> {
  final _swapService = SwapRequestService();
  List<SwapRequest>? _swaps;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSwapHistory();
  }

  Future<void> _loadSwapHistory() async {
    try {
      final swaps = await _swapService.getCompletedSwaps(widget.uid, limit: 10);
      if (mounted) {
        setState(() {
          _swaps = swaps;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading swap history: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Card(
        color: HomePage.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: HomePage.line),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
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
              const Text(
                'Swap History',
                style: TextStyle(
                  color: HomePage.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load swap history.',
                style: TextStyle(color: HomePage.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    if (_swaps == null || _swaps!.isEmpty) {
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
              const Text(
                'Swap History',
                style: TextStyle(
                  color: HomePage.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No completed swaps yet.',
                style: TextStyle(color: HomePage.textMuted),
              ),
            ],
          ),
        ),
      );
    }

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
            const Text(
              'Swap History',
              style: TextStyle(
                color: HomePage.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ..._swaps!.map((swap) => _SwapRequestHistoryCard(swap: swap, viewerUid: widget.uid)),
          ],
        ),
      ),
    );
  }
}

class _SwapRequestHistoryCard extends StatelessWidget {
  const _SwapRequestHistoryCard({required this.swap, required this.viewerUid});
  final SwapRequest swap;
  final String viewerUid;

  @override
  Widget build(BuildContext context) {
    // Determine if this user is the requester or recipient
    final isRequester = swap.requesterUid == viewerUid;
    final partnerName = isRequester
        ? swap.recipientProfile?.displayName
        : swap.requesterProfile?.displayName;
    final partnerPhoto = isRequester
        ? swap.recipientProfile?.photoUrl
        : swap.requesterProfile?.photoUrl;

    // What the viewer taught vs learned
    final skillTaught = isRequester ? swap.requesterOffer : swap.requesterNeed;
    final skillLearned = isRequester ? swap.requesterNeed : swap.requesterOffer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HomePage.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HomePage.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: HomePage.surface,
                backgroundImage: partnerPhoto != null
                    ? NetworkImage(partnerPhoto)
                    : null,
                child: partnerPhoto == null
                    ? Text(
                        (partnerName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: HomePage.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Swap with ${partnerName ?? "Unknown"}',
                      style: const TextStyle(
                        color: HomePage.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (swap.completion?.finalHours != null)
                      Text(
                        '${swap.completion!.finalHours!.toStringAsFixed(1)} hours',
                        style: TextStyle(
                          color: HomePage.textMuted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (skillTaught != null || skillLearned != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (skillTaught != null && skillTaught.isNotEmpty)
                  _skillPill('Offered: $skillTaught', const Color(0xFF7C3AED)),
                if (skillLearned != null && skillLearned.isNotEmpty)
                  _skillPill('Received: $skillLearned', const Color(0xFF0EA5E9)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _skillPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
