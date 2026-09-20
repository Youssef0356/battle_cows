import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/models/challenge_mode.dart';
import '../../game/tutorial/guide_content.dart';
import '../widgets/wood_button.dart';
import '../widgets/guide_diagrams.dart';

/// The "How to Play" guide: a tabbed, structured tutorial. Each tab mirrors a
/// [GuideSection] (SETUP / MOVES / BATTLE) plus a final MODES tab, with real
/// board diagrams rendered by [GuideDiagrams].
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const Color _accent = Color(0xFFFFD54F);
  static const Color _dark = Color(0xFF1B0000);
  static const Color _brown = Color(0xFF3E2723);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      appBar: AppBar(
        backgroundColor: _brown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'HOW TO PLAY',
          style: GoogleFonts.bangers(
            fontSize: 22,
            color: _accent,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_brown, _dark],
          ),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: TabBar(
                controller: _tabController,
                tabs: [
                  for (final label in GuideContent.tabLabels) Tab(text: label),
                ],
                labelStyle: GoogleFonts.bangers(
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
                unselectedLabelStyle: GoogleFonts.bangers(
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
                labelColor: _accent,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
                indicatorColor: _accent,
                indicatorWeight: 3,
                dividerColor: Colors.transparent,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (final section in GuideContent.sections)
                    _GuideTabPage(section: section),
                  const _ModesTabPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: WoodButton.gold(
                label: 'GOT IT!',
                width: 220,
                height: 52,
                fontSize: 22,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One tab: the emoji headline, every numbered step with its diagram and a
/// list of pro tips.
class _GuideTabPage extends StatelessWidget {
  final GuideSection section;

  const _GuideTabPage({required this.section});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        Row(
          children: [
            Text(section.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                section.headline.toUpperCase(),
                style: GoogleFonts.bangers(
                  fontSize: 16,
                  color: const Color(0xFFFFD54F),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final step in section.steps) ...[
          _StepCard(step: step),
          const SizedBox(height: 16),
        ],
        _TipsCard(tips: section.tips),
      ],
    );
  }
}

/// One numbered step: title, body text and the matching board diagram.
class _StepCard extends StatelessWidget {
  final GuideStep step;

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD54F),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${step.number}',
                  style: GoogleFonts.bangers(
                    fontSize: 16,
                    color: const Color(0xFF1B0000),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: GoogleFonts.bangers(
                    fontSize: 16,
                    color: const Color(0xFFFFD54F),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            step.body,
            style: GoogleFonts.bangers(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Center(child: GuideDiagrams.forStep(step.number)),
        ],
      ),
    );
  }
}

/// The bulleted "PRO TIPS" card closing every section tab.
class _TipsCard extends StatelessWidget {
  final List<String> tips;

  const _TipsCard({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRO TIPS',
            style: GoogleFonts.bangers(
              fontSize: 15,
              color: const Color(0xFF81C784),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: GoogleFonts.bangers(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.4,
                        height: 1.35,
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

/// The final tab: how to start each [ChallengeMode], what changes and how to
/// win it.
class _ModesTabPage extends StatelessWidget {
  const _ModesTabPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                GuideContent.modesHeadline.toUpperCase(),
                style: GoogleFonts.bangers(
                  fontSize: 16,
                  color: const Color(0xFFFFD54F),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final mode in GuideContent.modes) ...[
          _ModeCard(mode: mode),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

/// One game mode: start path banner, rule bullets and tip bullets.
class _ModeCard extends StatelessWidget {
  final GuideMode mode;

  const _ModeCard({required this.mode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B0000),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              mode.startPath,
              style: GoogleFonts.bangers(
                fontSize: 12,
                color: const Color(0xFFFFD54F),
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final rule in mode.rules)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🐮', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rule,
                      style: GoogleFonts.bangers(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.4,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          for (final tip in mode.tips)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: GoogleFonts.bangers(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.65),
                        letterSpacing: 0.4,
                        height: 1.3,
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

/// Shared translucent card look used by every guide card.
BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
  );
}