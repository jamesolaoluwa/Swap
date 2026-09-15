import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'login_page.dart';
import 'signup_page.dart';
import 'onboarding.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  // Modern dark theme - Apple-inspired
  static const Color bg = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0C);
  static const Color surfaceAlt = Color(0xFF111113);
  static const Color card = Color(0xFF0F0F11);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);
  static const Color accent = Color(0xFF7C3AED);
  static const Color accentLight = Color(0xFF9F67FF);
  static const Color accentGlow = Color(0xFF7C3AED);
  static const Color border = Color(0xFF27272A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Content with scroll
          SingleChildScrollView(
            child: Column(
              children: [
                // Hero with animated blur
                Stack(
                  children: [
                    const _AnimatedBlurBackground(),
                    Column(
                      children: [
                        _NavBar(),
                        _HeroSection(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                _StatsRow(),
                const SizedBox(height: 100),
                _HowItWorks(),
                const SizedBox(height: 100),
                _SuccessStories(),
                const SizedBox(height: 100),
                _SocialCreditSystem(),
                const SizedBox(height: 100),
                _WhyThisMatters(),
                const SizedBox(height: 100),
                _PopularCategories(),
                const SizedBox(height: 100),
                _FAQSection(),
                const SizedBox(height: 80),
                _CTASection(),
                const SizedBox(height: 80),
                _Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= ANIMATED BLUR BACKGROUND ================= */

class _AnimatedBlurBackground extends StatefulWidget {
  const _AnimatedBlurBackground();

  @override
  State<_AnimatedBlurBackground> createState() => _AnimatedBlurBackgroundState();
}

class _AnimatedBlurBackgroundState extends State<_AnimatedBlurBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _controller3 = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700,
      child: Stack(
        children: [
          // Primary purple blob
          AnimatedBuilder(
            animation: _controller1,
            builder: (context, child) {
              final value = _controller1.value;
              return Positioned(
                left: 100 + (math.sin(value * math.pi * 2) * 150),
                top: 50 + (math.cos(value * math.pi * 2) * 100),
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        LandingPage.accent.withOpacity(0.4),
                        LandingPage.accent.withOpacity(0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          // Secondary purple blob
          AnimatedBuilder(
            animation: _controller2,
            builder: (context, child) {
              final value = _controller2.value;
              return Positioned(
                right: 50 + (math.cos(value * math.pi * 2) * 120),
                top: 150 + (math.sin(value * math.pi * 2) * 80),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        LandingPage.accentLight.withOpacity(0.3),
                        LandingPage.accentLight.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          // Tertiary blue accent blob
          AnimatedBuilder(
            animation: _controller3,
            builder: (context, child) {
              final value = _controller3.value;
              return Positioned(
                left: 300 + (math.sin(value * math.pi * 1.5) * 100),
                bottom: 100 + (math.cos(value * math.pi * 1.5) * 60),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.2),
                        const Color(0xFF3B82F6).withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* ================= NAV BAR ================= */

class _NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _MaxWidth(
        child: Row(
          children: [
            SizedBox(
              height: 48,
              child: Image.asset(
                'assets/Swap-removebg-preview.png',
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            if (MediaQuery.of(context).size.width >= 768) ...[
              _NavLink(label: 'How it works', onTap: () {}),
              const SizedBox(width: 32),
              _NavLink(label: 'Success Stories', onTap: () {}),
              const SizedBox(width: 32),
              _NavLink(label: 'FAQ', onTap: () {}),
              const SizedBox(width: 40),
            ],
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: LandingPage.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text(
                'Log in',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 12),
            _GlowButton(
              label: 'Get Started',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            color: _hovering ? LandingPage.textPrimary : LandingPage.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

/* ================= GLOW BUTTON ================= */

class _GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool large;

  const _GlowButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.large = false,
  });

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> {
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
          padding: EdgeInsets.symmetric(
            horizontal: widget.large ? 28 : 20,
            vertical: widget.large ? 16 : 12,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [LandingPage.accent, LandingPage.accentLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: LandingPage.accent.withOpacity(_hovering ? 0.5 : 0.3),
                blurRadius: _hovering ? 24 : 16,
                spreadRadius: _hovering ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.large ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(widget.icon, color: Colors.white, size: widget.large ? 20 : 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= HERO SECTION ================= */

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 768;

    return Padding(
      padding: EdgeInsets.only(top: isWide ? 80 : 40, bottom: 40),
      child: _MaxWidth(
        child: Column(
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: LandingPage.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: LandingPage.accent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: LandingPage.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: LandingPage.accent.withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'AI-powered skill barter',
                    style: TextStyle(
                      color: LandingPage.accentLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Main headline
            Text(
              'Trade skills,',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: LandingPage.textPrimary,
                fontSize: isWide ? 72 : 48,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: -2,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [LandingPage.accent, LandingPage.accentLight, Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'not money.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWide ? 72 : 48,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Subtitle
            SizedBox(
              width: 680,
              child: Text(
                'People are often skill-rich but cash-constrained. \$wap uses AI to scale skill exchange — a behavior that has existed for thousands of years.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: LandingPage.textSecondary,
                  fontSize: isWide ? 18 : 16,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // CTAs
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _GlowButton(
                  label: 'Start Swapping',
                  icon: Icons.arrow_forward_rounded,
                  large: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileSetupFlow()),
                    );
                  },
                ),
                _GhostButton(
                  label: 'See how it works',
                  icon: Icons.play_circle_outline,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const _GhostButton({required this.label, required this.onTap, this.icon});

  @override
  State<_GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<_GhostButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: _hovering ? LandingPage.surfaceAlt : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovering ? LandingPage.border : LandingPage.border.withOpacity(0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: LandingPage.textSecondary, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: _hovering ? LandingPage.textPrimary : LandingPage.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= STATS ROW ================= */

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;
    
    return _MaxWidth(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: isWide ? 40 : 20),
        decoration: BoxDecoration(
          color: LandingPage.surfaceAlt.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: LandingPage.border.withOpacity(0.5)),
        ),
        child: isWide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _StatItem(value: '10+', label: 'Completed Swaps'),
                  _StatDivider(),
                  _StatItem(value: '20+', label: 'Active Swappers'),
                  _StatDivider(),
                  _StatItem(value: '100', label: 'Satisfaction Rate', suffix: '%'),
                  _StatDivider(),
                  _StatItem(value: '0', label: 'Money Exchanged', prefix: r'$'),
                ],
              )
            : Wrap(
                alignment: WrapAlignment.center,
                spacing: 32,
                runSpacing: 24,
                children: const [
                  _StatItem(value: '10+', label: 'Completed Swaps'),
                  _StatItem(value: '20+', label: 'Active Swappers'),
                  _StatItem(value: '100', label: 'Satisfaction Rate', suffix: '%'),
                  _StatItem(value: '0', label: 'Money Exchanged', prefix: r'$'),
                ],
              ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final String? suffix;
  final String? prefix;

  const _StatItem({required this.value, required this.label, this.suffix, this.prefix});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (prefix != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  prefix!,
                  style: const TextStyle(
                    color: LandingPage.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Text(
              value,
              style: const TextStyle(
                color: LandingPage.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
            if (suffix != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  suffix!,
                  style: const TextStyle(
                    color: LandingPage.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: LandingPage.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: LandingPage.border,
    );
  }
}

/* ================= HOW IT WORKS ================= */

class _HowItWorks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _MaxWidth(
      child: Column(
        children: [
          const _SectionHeader(
            title: 'How it works',
            subtitle: 'Two ways to exchange value — Direct and Indirect swaps',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final cards = [
                const _StepCard(
                  step: '01',
                  icon: Icons.person_add_outlined,
                  title: 'Share Your Skills',
                  description: 'List what you can offer and what you need. Our AI understands your skills semantically — not just by keywords.',
                  gradient: [Color(0xFF7C3AED), Color(0xFF9F67FF)],
                ),
                const _StepCard(
                  step: '02',
                  icon: Icons.swap_horiz_rounded,
                  title: 'Direct Swap',
                  description: 'Both users exchange skills directly. Both earn Swap Credits (reputation) and Swap Points (redeemable value).',
                  gradient: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                ),
                const _StepCard(
                  step: '03',
                  icon: Icons.autorenew_rounded,
                  title: 'Indirect Swap',
                  description: 'No direct match? Use Swap Points to redeem services. The provider earns Points and Credits. Everyone wins.',
                  gradient: [Color(0xFF10B981), Color(0xFF34D399)],
                ),
              ];

              if (isWide) {
                return Row(
                  children: cards.map((card) => Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: card,
                  ))).toList(),
                );
              }
              return Column(
                children: cards.map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: card,
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatefulWidget {
  final String step;
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _StepCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _hovering ? LandingPage.surfaceAlt : LandingPage.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovering ? widget.gradient[0].withOpacity(0.3) : LandingPage.border.withOpacity(0.5),
          ),
          boxShadow: _hovering ? [
            BoxShadow(
              color: widget.gradient[0].withOpacity(0.15),
              blurRadius: 32,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: widget.gradient[0].withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 28),
                ),
                Text(
                  widget.step,
                  style: TextStyle(
                    color: LandingPage.textMuted.withOpacity(0.5),
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: const TextStyle(
                color: LandingPage.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              style: const TextStyle(
                color: LandingPage.textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= SUCCESS STORIES ================= */

class _SuccessStories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _MaxWidth(
      child: Column(
        children: [
          const _SectionHeader(
            title: 'Real Swaps, Real Value',
            subtitle: 'Validated exchanges with 100% satisfaction — no money exchanged',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final stories = [
                const _SuccessStoryCard(
                  icon1: Icons.car_repair,
                  skill1: 'Paintless Dent Repair',
                  icon2: Icons.code,
                  skill2: 'Web Developer',
                  description: 'Car repair services exchanged for website development',
                  color: Color(0xFFF59E0B),
                ),
                const _SuccessStoryCard(
                  icon1: Icons.computer,
                  skill1: 'Software Engineer',
                  icon2: Icons.gavel,
                  skill2: 'Immigration Lawyer',
                  description: 'Technical services exchanged for legal consultation',
                  color: Color(0xFF3B82F6),
                ),
                const _SuccessStoryCard(
                  icon1: Icons.face,
                  skill1: 'Hair Braider',
                  icon2: Icons.plumbing,
                  skill2: 'Plumber',
                  description: 'Hair braiding services exchanged for plumbing work',
                  color: Color(0xFF10B981),
                ),
              ];

              if (isWide) {
                return Row(
                  children: stories.map((card) => Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: card,
                  ))).toList(),
                );
              }
              return Column(
                children: stories.map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: card,
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          // Success badges
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 12,
            children: [
              _SuccessBadge(icon: Icons.money_off, label: 'No money exchanged'),
              _SuccessBadge(icon: Icons.check_circle, label: 'Work completed'),
              _SuccessBadge(icon: Icons.thumb_up, label: 'Both satisfied'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuccessStoryCard extends StatefulWidget {
  final IconData icon1;
  final String skill1;
  final IconData icon2;
  final String skill2;
  final String description;
  final Color color;

  const _SuccessStoryCard({
    required this.icon1,
    required this.skill1,
    required this.icon2,
    required this.skill2,
    required this.description,
    required this.color,
  });

  @override
  State<_SuccessStoryCard> createState() => _SuccessStoryCardState();
}

class _SuccessStoryCardState extends State<_SuccessStoryCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hovering ? LandingPage.surfaceAlt : LandingPage.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovering ? widget.color.withOpacity(0.3) : LandingPage.border.withOpacity(0.5),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SkillBubble(icon: widget.icon1, label: widget.skill1, color: widget.color),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.swap_horiz, color: widget.color, size: 28),
                ),
                _SkillBubble(icon: widget.icon2, label: widget.skill2, color: widget.color),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: LandingPage.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SkillBubble({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: LandingPage.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SuccessBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= SOCIAL CREDIT SYSTEM ================= */

class _SocialCreditSystem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: LandingPage.surface,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: _MaxWidth(
        child: Column(
          children: [
            const _SectionHeader(
              title: 'More Than a Marketplace',
              subtitle: r'$wap functions as a social credit system that separates reputation from spending',
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(child: _CreditCard(
                        title: 'Swap Credits',
                        subtitle: 'Social Credit & Portfolio',
                        icon: Icons.verified_user,
                        color: Color(0xFF7C3AED),
                        items: [
                          'Earned automatically from completed swaps',
                          'Directly linked to your skill portfolio',
                          'Non-spendable and non-transferable',
                          'Shows how much value you\'ve contributed',
                        ],
                        footer: 'Your reputation grows with every successful exchange',
                      )),
                      SizedBox(width: 24),
                      Expanded(child: _CreditCard(
                        title: 'Swap Points',
                        subtitle: 'Redeemable Value',
                        icon: Icons.toll,
                        color: Color(0xFF3B82F6),
                        items: [
                          'Earned only through real skill exchanges',
                          'Cannot be purchased with money',
                          'Used for indirect swaps when no direct match exists',
                          'Decrease when spent — providing flexibility',
                        ],
                        footer: 'Spend points to access services without a direct swap',
                      )),
                    ],
                  );
                }
                return Column(
                  children: const [
                    _CreditCard(
                      title: 'Swap Credits',
                      subtitle: 'Social Credit & Portfolio',
                      icon: Icons.verified_user,
                      color: Color(0xFF7C3AED),
                      items: [
                        'Earned automatically from completed swaps',
                        'Directly linked to your skill portfolio',
                        'Non-spendable and non-transferable',
                        'Shows how much value you\'ve contributed',
                      ],
                      footer: 'Your reputation grows with every successful exchange',
                    ),
                    SizedBox(height: 24),
                    _CreditCard(
                      title: 'Swap Points',
                      subtitle: 'Redeemable Value',
                      icon: Icons.toll,
                      color: Color(0xFF3B82F6),
                      items: [
                        'Earned only through real skill exchanges',
                        'Cannot be purchased with money',
                        'Used for indirect swaps when no direct match exists',
                        'Decrease when spent — providing flexibility',
                      ],
                      footer: 'Spend points to access services without a direct swap',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 48),
            // Skill Portfolio
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    LandingPage.accent.withOpacity(0.1),
                    LandingPage.surfaceAlt,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: LandingPage.accent.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.folder_special, color: LandingPage.accent, size: 40),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Skill Portfolio',
                    style: TextStyle(
                      color: LandingPage.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A living portfolio backed by real outcomes, not claims',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: LandingPage.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _PortfolioChip(icon: Icons.swap_horiz, label: 'Completed Swaps'),
                      _PortfolioChip(icon: Icons.verified, label: 'Earned Credits'),
                      _PortfolioChip(icon: Icons.toll, label: 'Available Points'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> items;
  final String footer;

  const _CreditCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.items,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: LandingPage.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: LandingPage.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: color, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: LandingPage.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: color, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    footer,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PortfolioChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: LandingPage.surfaceAlt,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: LandingPage.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: LandingPage.accentLight, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: LandingPage.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= WHY THIS MATTERS ================= */

class _WhyThisMatters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _MaxWidth(
      child: Column(
        children: [
          const _SectionHeader(
            title: 'Why This Matters',
            subtitle: 'Barter has always worked — technology finally allows it to scale',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              final items = [
                const _WhyItem(
                  icon: Icons.accessibility_new,
                  title: 'Expands Access',
                  description: 'For people without disposable income, skills become their currency',
                ),
                const _WhyItem(
                  icon: Icons.verified_user,
                  title: 'Separates Trust',
                  description: 'Your reputation is built on contribution, not spending power',
                ),
                const _WhyItem(
                  icon: Icons.badge,
                  title: 'Portable Credit',
                  description: 'Skills become verified, portable social credit',
                ),
                const _WhyItem(
                  icon: Icons.rocket_launch,
                  title: 'Ancient System, Modern Tech',
                  description: 'AI scales behavior that has existed for thousands of years',
                ),
              ];

              if (isWide) {
                return Row(
                  children: items.map((item) => Expanded(child: item)).toList(),
                );
              }
              return Column(
                children: items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: item,
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WhyItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _WhyItem({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LandingPage.accent, LandingPage.accentLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: LandingPage.accent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: LandingPage.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: LandingPage.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= POPULAR CATEGORIES ================= */

class _PopularCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryData('Design', Icons.palette_outlined, ['UI/UX', 'Graphic', 'Branding']),
      _CategoryData('Development', Icons.code_rounded, ['Web', 'Mobile', 'Backend']),
      _CategoryData('Services', Icons.handyman_outlined, ['Repair', 'Legal', 'Consulting']),
      _CategoryData('Language', Icons.translate_rounded, ['Spanish', 'French', 'Mandarin']),
      _CategoryData('Beauty', Icons.face_retouching_natural, ['Hair', 'Makeup', 'Skincare']),
      _CategoryData('Business', Icons.trending_up_rounded, ['Marketing', 'Finance', 'Strategy']),
    ];

    return _MaxWidth(
      child: Column(
        children: [
          const _SectionHeader(
            title: 'Popular categories',
            subtitle: 'From professional services to everyday skills',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int crossAxisCount = 1;
              if (width >= 1000) crossAxisCount = 3;
              else if (width >= 600) crossAxisCount = 2;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: categories.map((cat) => SizedBox(
                  width: (width - (20 * (crossAxisCount - 1))) / crossAxisCount,
                  child: _CategoryCard(data: cat),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryData {
  final String title;
  final IconData icon;
  final List<String> chips;

  _CategoryData(this.title, this.icon, this.chips);
}

class _CategoryCard extends StatefulWidget {
  final _CategoryData data;

  const _CategoryCard({required this.data});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hovering ? LandingPage.surfaceAlt : LandingPage.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovering ? LandingPage.accent.withOpacity(0.3) : LandingPage.border.withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: LandingPage.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.data.icon, color: LandingPage.accent, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              widget.data.title,
              style: const TextStyle(
                color: LandingPage.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.data.chips.map((chip) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LandingPage.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: LandingPage.border.withOpacity(0.5)),
                ),
                child: Text(
                  chip,
                  style: const TextStyle(
                    color: LandingPage.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= FAQ SECTION ================= */

class _FAQSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final faqs = [
      _FAQData(
        r'What is $wap?',
        r'$wap is an AI-powered skill-exchange platform built on a barter system, allowing people to trade skills instead of money. At its core, people are often skill-rich but cash-constrained, and value can be exchanged without money if trust, fairness, and intelligent matching exist.',
      ),
      _FAQData(
        r'How does $wap use AI?',
        r'We use Azure AI Foundry to generate semantic embeddings of skills and Azure AI Search for vector similarity matching. This allows skills to be understood by meaning, not just keywords — so "web development" matches with "building websites" and "programming."',
      ),
      _FAQData(
        'What are Swap Credits?',
        'Swap Credits represent your social credit and reputation. They\'re earned automatically from completed swaps, directly linked to your skill portfolio, non-spendable and non-transferable. They show how much value you\'ve contributed over time.',
      ),
      _FAQData(
        'What are Swap Points?',
        'Swap Points are the spendable unit within the ecosystem. Earned only through real skill exchanges (cannot be purchased with money), used to redeem services when no direct swap exists, and decrease when used.',
      ),
      _FAQData(
        'What\'s a Direct Swap?',
        'Both users exchange skills directly. Both earn Swap Credits (reputation) and Swap Points (redeemable value). It\'s the ideal scenario where both parties get exactly what they need.',
      ),
      _FAQData(
        'What\'s an Indirect Swap?',
        'When no direct match exists, one user redeems Swap Points to get a service. The provider earns Swap Points and Swap Credits. This provides flexibility while preserving fairness.',
      ),
      _FAQData(
        'Has this been validated?',
        'Yes! Before building any software, we validated skill exchanges offline with pen-and-paper tests. Real swaps included: paintless dent repair ↔ web development, software engineer ↔ immigration lawyer, and hair braider ↔ plumber. All with 100% satisfaction.',
      ),
      _FAQData(
        'Why does this work now?',
        'Barter always worked but didn\'t scale — people could only trade with those they personally knew, trusted, and could physically reach. The internet + AI removes the discovery and trust bottleneck that historically prevented barter from scaling.',
      ),
    ];

    return _MaxWidth(
      child: Column(
        children: [
          const _SectionHeader(
            title: 'Frequently Asked Questions',
            subtitle: 'Everything you need to know about skill swapping',
          ),
          const SizedBox(height: 48),
          ...faqs.map((faq) => _FAQItem(data: faq)),
        ],
      ),
    );
  }
}

class _FAQData {
  final String question;
  final String answer;

  _FAQData(this.question, this.answer);
}

class _FAQItem extends StatefulWidget {
  final _FAQData data;

  const _FAQItem({required this.data});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: LandingPage.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded ? LandingPage.accent.withOpacity(0.3) : LandingPage.border.withOpacity(0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.data.question,
                        style: const TextStyle(
                          color: LandingPage.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: _expanded ? LandingPage.accent : LandingPage.textMuted,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      widget.data.answer,
                      style: const TextStyle(
                        color: LandingPage.textSecondary,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                  crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= SECTION HEADER ================= */

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: LandingPage.textPrimary,
            fontSize: 40,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: LandingPage.textSecondary,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

/* ================= CTA SECTION ================= */

class _CTASection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _MaxWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              LandingPage.accent.withOpacity(0.15),
              LandingPage.surfaceAlt,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: LandingPage.accent.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            const Text(
              'Ready to start swapping?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: LandingPage.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Join our growing community of skill swappers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: LandingPage.textSecondary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 32),
            _GlowButton(
              label: 'Create Free Account',
              icon: Icons.arrow_forward_rounded,
              large: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileSetupFlow()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= FOOTER ================= */

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: LandingPage.surface,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: _MaxWidth(
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 768;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 48,
                              child: Image.asset(
                                'assets/Swap-removebg-preview.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'AI-powered skill exchange where\nabilities meet opportunities.',
                              style: TextStyle(
                                color: LandingPage.textMuted,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const _FooterCol('Platform', ['About', 'How it Works', 'Success Stories', 'FAQ']),
                      const _FooterCol('Legal', ['Terms', 'Privacy', 'Cookies']),
                      const _FooterCol('Connect', ['Twitter', 'LinkedIn', 'Discord']),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 48,
                      child: Image.asset(
                        'assets/Swap-removebg-preview.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _FooterCol('Platform', ['About', 'How it Works', 'Success Stories', 'FAQ']),
                    const SizedBox(height: 24),
                    const _FooterCol('Legal', ['Terms', 'Privacy', 'Cookies']),
                    const SizedBox(height: 24),
                    const _FooterCol('Connect', ['Twitter', 'LinkedIn', 'Discord']),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            const Divider(color: LandingPage.border, height: 1),
            const SizedBox(height: 24),
            const Text(
              r'© 2025 $wap. All rights reserved.',
              style: TextStyle(
                color: LandingPage.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterCol extends StatelessWidget {
  final String title;
  final List<String> items;

  const _FooterCol(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: LandingPage.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              item,
              style: const TextStyle(
                color: LandingPage.textMuted,
                fontSize: 14,
              ),
            ),
          )),
        ],
      ),
    );
  }
}

/* ================= MAX WIDTH WRAPPER ================= */

class _MaxWidth extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const _MaxWidth({this.maxWidth = 1200, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ),
    );
  }
}
