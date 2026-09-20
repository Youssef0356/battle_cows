import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../data/services/progress_service.dart';
import '../../game/models/player.dart';
import '../dialogs/daily_quests_dialog.dart';
import '../dialogs/shop_dialog.dart';
import '../router/app_router.dart';
import '../widgets/wood_button.dart';
import '../widgets/rustic_decor.dart';
import '../../game/models/challenge_mode.dart';
import '../../game/ai/ai_player.dart';
import '../widgets/cartoon_dialog.dart';
import '../widgets/kenney_button.dart';
import '../widgets/bouncy_pressable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _tilesPerPlayer = 4;
  late AnimationController _animController;
  late Animation<double> _titleScale;
  ProgressService? _progressService;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _titleScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
    _initProgress();
  }

  Future<void> _initProgress() async {
    _progressService = await ProgressService.getInstance();
    _progressService!.checkDailyLogin();
    _progressService!.refreshDailyQuests();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<Player> _createPlayers({required int count, required bool isMultiplayer, Difficulty difficulty = Difficulty.medium}) {
    final players = <Player>[];
    for (var i = 0; i < count; i++) {
      players.add(Player(
        id: i,
        name: isMultiplayer ? 'Player ${i + 1}' : (i == 0 ? 'Player 1' : 'AI Cow $i'),
        color: PlayerColor.values[i % 4],
        isAi: isMultiplayer ? false : (i > 0),
        difficulty: isMultiplayer ? null : difficulty,
      ));
    }
    return players;
  }

  int _selectedDifficultyIndex = 1;

  void _launchGame({required int playerCount, required int tilesPerPlayer, required bool isMultiplayer, ChallengeMode challengeMode = ChallengeMode.standard}) {
    final difficulty = Difficulty.values[_selectedDifficultyIndex];
    final players = _createPlayers(count: playerCount, isMultiplayer: isMultiplayer, difficulty: difficulty);

    Navigator.pushNamed(
      context,
      AppRouter.game,
      arguments: {
        'players': players,
        'herdSize': 16,
        'tilesPerPlayer': tilesPerPlayer,
        // 5 tiles → small hex field (7), 4 → medium (9), 3 → large hexes (11).
        'boardSize': 7 + (5 - tilesPerPlayer) * 2,
        'challengeMode': challengeMode,
      },
    );
  }

  void _showGameSetupDialog({required String title, required bool isMultiplayer, ChallengeMode challengeMode = ChallengeMode.standard}) {
    int selectedTiles = _tilesPerPlayer;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3E2723), Color(0xFF1B0000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD54F), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                  title,
                  style: GoogleFonts.bangers(
                    fontSize: 28,
                    color: const Color(0xFFFFD54F),
                    letterSpacing: 2,
                    shadows: [
                      const Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'CPU DIFFICULTY',
                  style: GoogleFonts.bangers(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: ['EASY', 'MEDIUM', 'HARD'].asMap().entries.map((entry) {
                    final idx = entry.key;
                    final label = entry.value;
                    final isSel = _selectedDifficultyIndex == idx;
                    final colors = [const Color(0xFF689F38), const Color(0xFFFFA000), const Color(0xFFD32F2F)];
                    return GestureDetector(
                      onTap: () => setDialogState(() => _selectedDifficultyIndex = idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: isSel
                              ? LinearGradient(
                                  colors: [colors[idx], colors[idx].withValues(alpha: 0.7)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.12),
                                    Colors.white.withValues(alpha: 0.04),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? colors[idx] : Colors.white24,
                            width: isSel ? 2.5 : 1.5,
                          ),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: colors[idx].withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              label,
                              style: GoogleFonts.bangers(
                                fontSize: 12,
                                color: isSel ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'PASTURE TILES PER PLAYER',
                  style: GoogleFonts.bangers(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bigger pasture = bigger hexes, fewer tiles!',
                  style: GoogleFonts.bangers(
                    fontSize: 11,
                    color: Colors.white38,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: [
                    (5, 'SMALL'),
                    (4, 'MEDIUM'),
                    (3, 'LARGE'),
                  ].map((entry) {
                    final (tiles, label) = entry;
                    final isSel = selectedTiles == tiles;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedTiles = tiles),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: isSel
                              ? const LinearGradient(
                                  colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.12),
                                    Colors.white.withValues(alpha: 0.04),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? const Color(0xFF66BB6A) : Colors.white24,
                            width: isSel ? 2.5 : 1.5,
                          ),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF66BB6A).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 56,
                              height: 36,
                              child: CustomPaint(
                                painter: _PasturePreviewPainter(
                                  hexCount: tiles,
                                  color: isSel ? Colors.white : Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: GoogleFonts.bangers(
                                fontSize: 11,
                                color: isSel ? Colors.white : Colors.white60,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.bangers(
                                fontSize: 18,
                                color: Colors.white70,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _tilesPerPlayer = selectedTiles;
                          });
                          _launchGame(
                            playerCount: 2,
                            tilesPerPlayer: selectedTiles,
                            isMultiplayer: isMultiplayer,
                            challengeMode: challengeMode,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8F00).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                              const SizedBox(width: 4),
                              Text(
                                'START',
                                style: GoogleFonts.bangers(
                                  fontSize: 22,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                   ],
                 ),
               ],
               ),
             ),
           ),
         ),
       ),
     );
   }

   void _showChallengePicker() {
    CartoonDialog.show(
      context: context,
      title: 'CHOOSE YOUR CHALLENGE',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ChallengeMode.values
              .where((mode) => mode != ChallengeMode.standard)
              .map((mode) => GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showGameSetupDialog(title: mode.title, isMultiplayer: false, challengeMode: mode);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Text(mode.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(mode.title, style: GoogleFonts.bangers(fontSize: 16, color: Colors.white)),
                                const SizedBox(height: 2),
                                Text(mode.description, style: GoogleFonts.bangers(fontSize: 11, color: Colors.white60)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFFFFD54F)),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showShopDialog() {
    if (_progressService == null) return;
    ShopDialog.show(
      context: context,
      progress: _progressService!,
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background pasture image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          // Subtle vignette overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          // Main UI Content in SafeArea
          SafeArea(
            child: Column(
              children: [
                _buildTopHeader(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _titleScale,
                            child: _buildHeroLogo(),
                          ),
                          const SizedBox(height: 16),
                          _buildMenuButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomRusticBar(),
              ],
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  Positioned(top: 12, left: -30, child: RopeStrap(alignment: Alignment.topLeft, width: 190)),
                  Positioned(bottom: 70, right: -36, child: RopeStrap(alignment: Alignment.bottomRight, width: 210)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildProfilePlaque(),
          _buildSideToolButtons(),
        ],
      ),
    );
  }

  Widget _buildProfilePlaque() {
    final p = _progressService?.progress;
    final coins = p?.coins ?? 0;

    return RusticPlank(
      color: const Color(0xFF4E342E),
      seed: 17,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5D4037),
              border: Border.all(color: const Color(0xFFFFD54F), width: 2),
            ),
            child: const Center(
              child: Text('🐮', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Player 1',
                    style: GoogleFonts.bangers(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('💰', style: TextStyle(fontSize: 12)),
                  Text(
                    ' $coins',
                    style: GoogleFonts.bangers(
                      fontSize: 14,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideToolButtons() {
    return Column(
      children: [
        _buildWoodToolButton(icon: Icons.settings, label: 'SETTINGS', onTap: () => Navigator.pushNamed(context, AppRouter.settings)),
        const SizedBox(height: 6),
        _buildWoodToolButton(icon: Icons.shopping_cart, label: 'SHOP', onTap: _showShopDialog),
      ],
    );
  }

  Widget _buildWoodToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return BouncyPressable(
      scaleDown: 0.90,
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8D6E63), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            Text(
              label,
              style: GoogleFonts.bangers(
                fontSize: 8,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroLogo() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
      child: Image.asset(
        'assets/images/Background/Logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => Column(
          children: [
            const Text('🐮', style: TextStyle(fontSize: 50)),
            Text(
              'BATTLE COWS',
              style: GoogleFonts.bangers(
                fontSize: 42,
                color: const Color(0xFFFFD54F),
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final btnWidth = (screenWidth * 0.75).clamp(240.0, 360.0);
    return Column(
      children: [
        WoodButton.gold(
          label: 'PLAY VS AI',
          icon: Icons.play_arrow_rounded,
          width: btnWidth,
          height: 62,
          fontSize: 26,
          onPressed: () => _showGameSetupDialog(title: 'PLAY VS AI', isMultiplayer: false),
        ),
        const SizedBox(height: 12),
        WoodButton(
          label: 'LOCAL MULTIPLAYER',
          icon: Icons.people_rounded,
          width: btnWidth,
          height: 58,
          fontSize: 24,
          baseColor: const Color(0xFF1565C0),
          borderColor: const Color(0xFF42A5F5),
          onPressed: () => _showGameSetupDialog(title: 'LOCAL MULTIPLAYER', isMultiplayer: true),
        ),
        const SizedBox(height: 12),
        WoodButton.purple(
          label: 'HOW TO PLAY',
          icon: Icons.menu_book_rounded,
          width: btnWidth,
          height: 54,
          fontSize: 22,
          onPressed: () => Navigator.pushNamed(context, AppRouter.tutorial),
        ),
        const SizedBox(height: 12),
        WoodButton(
          label: 'CHALLENGES',
          icon: Icons.shield_rounded,
          width: btnWidth,
          height: 54,
          fontSize: 22,
          baseColor: const Color(0xFF5D4037),
          borderColor: const Color(0xFFD7CCC8),
          onPressed: _showChallengePicker,
        ),
        const SizedBox(height: 12),
        WoodButton.red(
          label: 'EXIT',
          icon: Icons.exit_to_app_rounded,
          width: btnWidth,
          height: 54,
          fontSize: 22,
          onPressed: () {
            CartoonDialog.show(
              context: context,
              title: 'EXIT GAME?',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to exit?',
                    style: GoogleFonts.bangers(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: KenneyButton(
                          label: 'CANCEL',
                          isWide: true,
                          style: KenneyBtnStyle.neutral,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KenneyButton(
                          label: 'EXIT',
                          isWide: true,
                          style: KenneyBtnStyle.danger,
                          onPressed: () {
                            Navigator.pop(context);
                            SystemNavigator.pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }



  Widget _buildBottomRusticBar() {
    final p = _progressService?.progress;
    final readyQuests = p?.dailyQuests.where((q) => q.isComplete && !q.claimed).length ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: RusticPlank(
        color: const Color(0xFF3E2723),
        seed: 29,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: GestureDetector(
          onTap: () {
            if (_progressService == null) return;
            DailyQuestsDialog.show(
              context: context,
              progress: _progressService!,
            ).then((_) => setState(() {}));
          },
          child: _buildBottomItem(
            iconText: '📅',
            title: 'DAILY QUESTS',
            subtitle: readyQuests > 0 ? '$readyQuests READY' : 'PLAY MORE',
            color: readyQuests > 0 ? const Color(0xFF81C784) : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomItem({
    required String iconText,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Text(iconText, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.bangers(
                fontSize: 11,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.bangers(
                fontSize: 12,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Draws a mini hex-cluster matching the pasture size, mirroring how the game
/// actually deals land: whole 4-hex diamond tiles (PastureTile.diamond) plus
/// leftover single hexes. 3 = three single hexes in a triangle (SMALL), 4 = one
/// diamond (MEDIUM), 5 = a diamond plus two extra hexes (LARGE). The cluster is
/// scaled uniformly to fit its option box, so more tiles always reads as a
/// bigger, denser pasture.
class _PasturePreviewPainter extends CustomPainter {
  final int hexCount;
  final Color color;

  _PasturePreviewPainter({required this.hexCount, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final count = hexCount.clamp(1, 6);
    final tiles = count ~/ 4;
    final leftovers = count % 4;

    // Axial (q, r) hex coordinates: tiles side by side, leftover single
    // hexes continuing the top row to the right.
    final centers = <Offset>[];
    for (var t = 0; t < tiles; t++) {
      final base = 2.0 * t;
      centers.addAll([
        Offset(base, 0),
        Offset(base + 1, 0),
        Offset(base, 1),
        Offset(base + 1, -1),
      ]);
    }
    if (tiles == 0) {
      // No full tiles yet: 1 = single hex, 2 = pair, 3 = triangle.
      const singleShapes = [
        [Offset(0, 0)],
        [Offset(0, 0), Offset(1, 0)],
        [Offset(0, 0), Offset(1, -1), Offset(0, -1)],
      ];
      centers.addAll(singleShapes[leftovers - 1]);
    } else {
      for (var l = 0; l < leftovers; l++) {
        centers.add(Offset(2.0 * tiles + l, 0));
      }
    }

    // Pointy-top axial -> pixel offsets, with a hex radius of 1.
    Offset toPixel(Offset hex) => Offset(hex.dx + hex.dy / 2, hex.dy * 0.8660254);
    final points = centers.map(toPixel).toList();

    final minX = points.map((p) => p.dx).reduce(min) - 1;
    final maxX = points.map((p) => p.dx).reduce(max) + 1;
    final minY = points.map((p) => p.dy).reduce(min) - 1;
    final maxY = points.map((p) => p.dy).reduce(max) + 1;
    // Uniform scale so the whole cluster (plus a small margin) stays inside
    // the option box - nothing gets clipped.
    final scale = min(
      (size.width - 8) / (maxX - minX),
      (size.height - 8) / (maxY - minY),
    );
    final origin = Offset(
      size.width / 2 - (minX + maxX) / 2 * scale,
      size.height / 2 - (minY + maxY) / 2 * scale,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (scale * 0.16).clamp(1.0, 1.8).toDouble();

    final path = Path();
    for (final p in points) {
      path.addPath(
        _hexPath(
          Offset(origin.dx + p.dx * scale, origin.dy + p.dy * scale),
          scale * 0.94,
        ),
        Offset.zero,
      );
    }
    canvas.drawPath(path, paint);
  }

  Path _hexPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _PasturePreviewPainter old) =>
      old.hexCount != hexCount || old.color != color;
}
