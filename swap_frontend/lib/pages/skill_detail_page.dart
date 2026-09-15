import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'user_profile_page.dart' show showSwapRequestDialog;
import '../models/swap_request.dart';
import '../services/swap_request_service.dart';

class SkillDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int durationHours;
  final String mode;
  final double rating;
  final List<String> tags;
  final List<String> deliverables;
  final bool verified;
  final String creatorUid;
  final String creatorName;
  final String? creatorPhotoUrl;
  final String? servicesNeeded;

  const SkillDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.durationHours,
    required this.mode,
    required this.rating,
    required this.tags,
    required this.deliverables,
    required this.verified,
    required this.creatorUid,
    required this.creatorName,
    this.creatorPhotoUrl,
    this.servicesNeeded,
  });

  @override
  State<SkillDetailPage> createState() => _SkillDetailPageState();
}

class _SkillDetailPageState extends State<SkillDetailPage> {
  int _selectedSegment = 0;
  Map<String, dynamic>? _profileData;
  bool _loadingProfile = true;
  List<SwapRequest>? _swapHistory;
  bool _loadingSwapHistory = true;
  String? _creatorServicesNeeded;

  @override
  void initState() {
    super.initState();
    _creatorServicesNeeded = widget.servicesNeeded;
    _loadProfileData();
    _loadSwapHistory();
  }

  Future<void> _loadSwapHistory() async {
    try {
      final swapService = SwapRequestService();
      final swaps = await swapService.getCompletedSwaps(widget.creatorUid, limit: 5);
      if (mounted) {
        setState(() {
          _swapHistory = swaps;
          _loadingSwapHistory = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading swap history: $e');
      if (mounted) setState(() => _loadingSwapHistory = false);
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final profileDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.creatorUid)
          .get();

      if (mounted) {
        final profileData = profileDoc.data();
        String? servicesNeeded = _creatorServicesNeeded;

        if ((servicesNeeded == null || servicesNeeded.isEmpty) && profileData != null) {
          final rawNeeds = profileData['servicesNeeded'] ?? profileData['services_needed'];
          if (rawNeeds is String) {
            servicesNeeded = rawNeeds;
          } else if (rawNeeds is List) {
            servicesNeeded = rawNeeds.map((need) {
              if (need is Map) {
                final name = need['name'] ?? need['title'] ?? '';
                final level = need['level'] ?? '';
                return level.toString().isNotEmpty ? '$name ($level)' : name;
              }
              return need.toString();
            }).join(', ');
          }
        }

        setState(() {
          _profileData = profileData;
          _creatorServicesNeeded = servicesNeeded;
          _loadingProfile = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePage.bg,
      appBar: AppBar(
        backgroundColor: HomePage.bg,
        foregroundColor: HomePage.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          // Segmented Picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: HomePage.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HomePage.line),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentButton(
                      label: 'Skill Details',
                      icon: Icons.article_outlined,
                      isSelected: _selectedSegment == 0,
                      onTap: () => setState(() => _selectedSegment = 0),
                    ),
                  ),
                  Expanded(
                    child: _SegmentButton(
                      label: 'Profile',
                      icon: Icons.person_outline,
                      isSelected: _selectedSegment == 1,
                      onTap: () => setState(() => _selectedSegment = 1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _selectedSegment == 0
                  ? _buildSkillDetails()
                  : _buildProfileView(),
            ),
          ),
        ],
      ),
      // Bottom Request Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: HomePage.surface,
          border: Border(top: BorderSide(color: HomePage.line)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: () {
              showSwapRequestDialog(
                context,
                recipientUid: widget.creatorUid,
                recipientName: widget.creatorName,
                preSelectedSkill: widget.title,
              );
            },
            icon: const Icon(Icons.swap_horiz, size: 22),
            label: const Text(
              'Request Swap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: HomePage.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Creator info at the top
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: HomePage.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HomePage.line),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: HomePage.bg,
                backgroundImage: widget.creatorPhotoUrl != null && widget.creatorPhotoUrl!.isNotEmpty
                    ? NetworkImage(widget.creatorPhotoUrl!)
                    : null,
                child: widget.creatorPhotoUrl == null || widget.creatorPhotoUrl!.isEmpty
                    ? Text(
                        widget.creatorName.isNotEmpty ? widget.creatorName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: HomePage.textMuted, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posted by',
                      style: TextStyle(color: HomePage.textMuted, fontSize: 12),
                    ),
                    Text(
                      widget.creatorName,
                      style: const TextStyle(color: HomePage.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ],
                ),
              ),
              // Tap "Profile" tab hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: HomePage.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('View Profile →', style: TextStyle(color: HomePage.accent, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Header with category and badges
        Row(
          children: [
            _Pill(widget.category),
            const SizedBox(width: 8),
            _Pill(widget.difficulty, color: _difficultyColor),
            if (widget.verified) ...[
              const SizedBox(width: 8),
              const _Pill('Verified', icon: Icons.verified, color: Color(0xFF22C55E)),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          widget.title,
          style: const TextStyle(
            color: HomePage.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Quick info row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HomePage.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HomePage.line),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoItem(
                icon: Icons.access_time,
                label: 'Duration',
                value: '${widget.durationHours}h',
              ),
              _InfoItem(
                icon: Icons.public,
                label: 'Format',
                value: widget.mode,
              ),
              _InfoItem(
                icon: Icons.star,
                label: 'Rating',
                value: widget.rating.toStringAsFixed(1),
                iconColor: Colors.amber,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // About section
        const Text(
          'About This Skill',
          style: TextStyle(
            color: HomePage.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HomePage.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HomePage.line),
          ),
          child: Text(
            widget.description,
            style: const TextStyle(
              color: HomePage.textPrimary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Looking for section
        if (_creatorServicesNeeded != null && _creatorServicesNeeded!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HomePage.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HomePage.accent.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.search, size: 20, color: HomePage.accentAlt),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Looking for:',
                        style: TextStyle(
                          color: HomePage.accentAlt,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _creatorServicesNeeded!,
                        style: const TextStyle(
                          color: HomePage.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Deliverables
        const Text(
          'What You\'ll Get',
          style: TextStyle(
            color: HomePage.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.deliverables.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HomePage.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: HomePage.line),
            ),
            child: const Text(
              'No deliverables specified for this skill.',
              style: TextStyle(color: HomePage.textMuted, fontSize: 14),
            ),
          )
        else
          ...widget.deliverables.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    d,
                    style: const TextStyle(color: HomePage.textPrimary, fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        const SizedBox(height: 20),

        // Tags
        const Text(
          'Topics',
          style: TextStyle(
            color: HomePage.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.tags.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HomePage.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: HomePage.line),
            ),
            child: const Text(
              'No topics specified.',
              style: TextStyle(color: HomePage.textMuted, fontSize: 14),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HomePage.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: HomePage.line),
              ),
              child: Text(t, style: const TextStyle(color: HomePage.textMuted, fontSize: 13)),
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildProfileView() {
    if (_loadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }

    final name = (_profileData?['fullName'] ?? _profileData?['displayName'] ?? widget.creatorName).toString().trim();
    final username = (_profileData?['username'] ?? '').toString().trim();
    final city = (_profileData?['city'] ?? '').toString().trim();
    final bio = (_profileData?['bio'] ?? '').toString().trim();
    final photoUrl = _profileData?['photoUrl'] ?? widget.creatorPhotoUrl;
    final timezone = (_profileData?['timezone'] ?? '').toString().trim();
    final swapsCompleted = (_profileData?['completed_swap_count'] ?? _profileData?['swapsCompleted'] ?? 0) as int;
    final swapCredits = (_profileData?['swap_credits'] ?? 0) as int;
    final skillsToOffer = (_profileData?['skillsToOffer'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    return Column(
      children: [
        // Profile Header Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: HomePage.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomePage.line),
          ),
          child: Column(
            children: [
              // Banner
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [HomePage.accent, HomePage.accent.withOpacity(0.6)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -30),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: HomePage.surface,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: HomePage.bg,
                        backgroundImage: photoUrl != null && photoUrl.toString().isNotEmpty
                            ? NetworkImage(photoUrl.toString())
                            : null,
                        child: photoUrl == null || photoUrl.toString().isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(color: HomePage.textMuted, fontSize: 28, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name.isEmpty ? 'User' : name,
                      style: const TextStyle(color: HomePage.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (username.isNotEmpty) Text('@$username', style: const TextStyle(color: HomePage.textMuted)),
                    const SizedBox(height: 8),
                    if (city.isNotEmpty || timezone.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (city.isNotEmpty) ...[
                            const Icon(Icons.location_on_outlined, size: 14, color: HomePage.textMuted),
                            const SizedBox(width: 4),
                            Text(city, style: const TextStyle(color: HomePage.textMuted, fontSize: 13)),
                          ],
                          if (city.isNotEmpty && timezone.isNotEmpty) const SizedBox(width: 12),
                          if (timezone.isNotEmpty) ...[
                            const Icon(Icons.schedule, size: 14, color: HomePage.textMuted),
                            const SizedBox(width: 4),
                            Text(timezone, style: const TextStyle(color: HomePage.textMuted, fontSize: 13)),
                          ],
                        ],
                      ),
                    const SizedBox(height: 16),
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatItem(value: '$swapsCompleted', label: 'Swaps'),
                        Container(width: 1, height: 30, color: HomePage.line, margin: const EdgeInsets.symmetric(horizontal: 20)),
                        _StatItem(value: '$swapCredits', label: 'Credits'),
                        Container(width: 1, height: 30, color: HomePage.line, margin: const EdgeInsets.symmetric(horizontal: 20)),
                        _StatItem(value: widget.rating.toStringAsFixed(1), label: 'Rating', showStar: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bio
        if (bio.isNotEmpty) ...[
          _SectionCard(
            title: 'About',
            child: Text(bio, style: const TextStyle(color: HomePage.textPrimary, height: 1.5)),
          ),
          const SizedBox(height: 16),
        ],

        // Skills Offered
        if (skillsToOffer.isNotEmpty) ...[
          _SectionCard(
            title: 'Skills Offered',
            titleColor: const Color(0xFF22C55E),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skillsToOffer.map((skill) {
                final skillName = skill['name'] ?? skill['title'] ?? '';
                final skillLevel = skill['level'] ?? '';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    skillLevel.toString().isNotEmpty ? '$skillName ($skillLevel)' : skillName.toString(),
                    style: const TextStyle(color: Color(0xFF22C55E), fontSize: 13),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Swap History
        _SectionCard(
          title: 'Swap History',
          child: _loadingSwapHistory
              ? const Center(child: CircularProgressIndicator())
              : (_swapHistory == null || _swapHistory!.isEmpty)
                  ? const Text('No completed swaps yet', style: TextStyle(color: HomePage.textMuted))
                  : Column(
                      children: _swapHistory!.take(5).map((swap) {
                        final isRequester = swap.requesterUid == widget.creatorUid;
                        final partnerName = isRequester ? swap.recipientProfile?.displayName : swap.requesterProfile?.displayName;
                        final skillOffered = isRequester ? swap.requesterOffer : swap.requesterNeed;
                        final skillReceived = isRequester ? swap.requesterNeed : swap.requesterOffer;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: HomePage.bg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: HomePage.surfaceAlt,
                                    child: Text(
                                      (partnerName ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(color: HomePage.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Swap with ${partnerName ?? "Unknown"}',
                                      style: const TextStyle(color: HomePage.textPrimary, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('Completed', style: TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              if ((skillOffered != null && skillOffered.isNotEmpty) || (skillReceived != null && skillReceived.isNotEmpty)) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (skillOffered != null && skillOffered.isNotEmpty)
                                      _SwapBadge(label: 'Offered: $skillOffered', color: HomePage.accent),
                                    if (skillReceived != null && skillReceived.isNotEmpty)
                                      _SwapBadge(label: 'Received: $skillReceived', color: const Color(0xFF3B82F6)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
        ),
      ],
    );
  }

  Color get _difficultyColor {
    switch (widget.difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF22C55E);
      case 'intermediate':
        return const Color(0xFFF59E0B);
      case 'advanced':
        return const Color(0xFFEF4444);
      default:
        return HomePage.accent;
    }
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? HomePage.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : HomePage.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : HomePage.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;

  const _Pill(this.text, {this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? HomePage.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 4),
          ],
          Text(text, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _InfoItem({required this.icon, required this.label, required this.value, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? HomePage.textMuted, size: 22),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: HomePage.textMuted, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: HomePage.textPrimary, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool showStar;

  const _StatItem({required this.value, required this.label, this.showStar = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showStar) ...[
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
            ],
            Text(value, style: const TextStyle(color: HomePage.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: HomePage.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? titleColor;

  const _SectionCard({required this.title, required this.child, this.titleColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomePage.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HomePage.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: titleColor ?? HomePage.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SwapBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SwapBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
