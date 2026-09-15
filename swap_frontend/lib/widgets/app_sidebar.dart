// lib/widgets/app_sidebar.dart
import 'package:flutter/material.dart';
import '../pages/post_skill_page.dart';
import '../pages/home_page.dart';
import '../pages/landing_page.dart';
import '../pages/profile_page.dart';
import '../pages/request_page.dart';
import '../pages/wallet_page.dart';
import '../pages/messages/conversations_page.dart';
import '../services/b2c_auth_service.dart';
import '../services/messaging_service.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({super.key, this.active = 'Home'});

  final String active;

  static const double width = 260;

  // Local theme colors (matching HomePage)
  static const Color bg = Color(0xFF0A0A0C);
  static const Color surface = Color(0xFF0F0F11);
  static const Color border = Color(0xFF27272A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFA1A1AA);
  static const Color accent = Color(0xFF7C3AED);
  static const Color accentLight = Color(0xFF9F67FF);

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  final _messagingService = MessagingService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    final uid = B2CAuthService.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    try {
      final count = await _messagingService.getTotalUnreadCount(uid);
      if (mounted) {
        setState(() => _unreadCount = count);
      }
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isActive(String label) =>
        widget.active.toLowerCase() == label.toLowerCase();

    return Container(
      width: AppSidebar.width,
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          right: BorderSide(color: border.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          // Logo section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 56,
                child: Image.asset(
                  'assets/Swap-removebg-preview.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          Divider(color: border.withOpacity(0.5), height: 1),
          const SizedBox(height: 16),

          // Navigation items
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            active: isActive('Home'),
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomePage()),
              (route) => false,
            ),
          ),
          _NavItem(
            icon: Icons.add_circle_outline_rounded,
            label: 'Post Skill',
            active: isActive('Post Skill'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PostSkillPage()),
            ),
          ),
          _NavItem(
            icon: Icons.inbox_rounded,
            label: 'Requests',
            active: isActive('Requests'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RequestsPage()),
            ),
          ),
          _NavItem(
            icon: Icons.swap_horiz_rounded,
            label: 'My Swaps',
            active: isActive('My Swaps'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MySwapsPage()),
            ),
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Messages',
            badge: _unreadCount > 0 ? '$_unreadCount' : null,
            active: isActive('Messages'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConversationsPage()),
            ),
          ),
          _NavItem(
            icon: Icons.analytics_outlined,
            label: 'Dashboard',
            active: isActive('Dashboard'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WalletPage()),
            ),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            active: isActive('Profile'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),

          const Spacer(),
          _NavItem(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            onTap: () async {
              await B2CAuthService.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LandingPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withOpacity(0.15),
                    surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: accent.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accent, accentLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Share Your Skills',
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start earning by helping others learn what you know.',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: _GradientButton(
                      label: 'Post a Skill',
                      onTap: () {
                        final currentRoute = ModalRoute.of(context)?.settings.name;
                        if (currentRoute != 'post_skill') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PostSkillPage(),
                              settings: const RouteSettings(name: 'post_skill'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final String? badge;
  final VoidCallback? onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.active;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isActive 
                ? AppSidebar.accent.withOpacity(0.15)
                : _hovering 
                    ? AppSidebar.surface
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive 
                ? Border.all(color: AppSidebar.accent.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 22,
                color: isActive 
                    ? AppSidebar.accentLight
                    : _hovering 
                        ? AppSidebar.textPrimary
                        : AppSidebar.textMuted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: isActive 
                        ? AppSidebar.textPrimary
                        : _hovering 
                            ? AppSidebar.textPrimary
                            : AppSidebar.textMuted,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              if (widget.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppSidebar.accent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    widget.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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

class _GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppSidebar.accent, AppSidebar.accentLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppSidebar.accent.withOpacity(_hovering ? 0.5 : 0.3),
                blurRadius: _hovering ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
