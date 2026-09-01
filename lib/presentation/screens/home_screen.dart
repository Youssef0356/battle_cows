import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../game/models/player.dart';
import '../router/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _playerCount = 2;
  int _tilesPerPlayer = 4;
  late AnimationController _animController;
  late Animation<double> _titleScale;

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
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<Player> _createPlayers({required int count, required bool isMultiplayer}) {
    final colors = [PlayerColor.blue, PlayerColor.red, PlayerColor.yellow, PlayerColor.purple];

    final players = <Player>[];
    for (var i = 0; i < count; i++) {
      players.add(Player(
        id: i,
        name: isMultiplayer ? 'Player ${i + 1}' : (i == 0 ? 'Player 1' : 'AI Cow $i'),
        color: colors[i % colors.length],
        isAi: isMultiplayer ? false : (i > 0),
      ));
    }
    return players;
  }

  void _launchGame({required int playerCount, required int tilesPerPlayer, required bool isMultiplayer}) {
    final players = _createPlayers(count: playerCount, isMultiplayer: isMultiplayer);
    Navigator.pushNamed(
      context,
      AppRouter.tilePlacement,
      arguments: {
        'players': players,
        'tilesPerPlayer': tilesPerPlayer,
      },
    );
  }

  void _showGameSetupDialog({required String title, required bool isMultiplayer}) {
    int selectedPlayers = _playerCount;
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
                const SizedBox(height: 20),
                Text(
                  'NUMBER OF PLAYERS',
                  style: GoogleFonts.bangers(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [2, 3, 4].map((count) {
                    final isSel = selectedPlayers == count;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedPlayers = count),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: isSel
                              ? const LinearGradient(
                                  colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.15),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? Colors.white : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: GoogleFonts.bangers(
                              fontSize: 24,
                              color: isSel ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'PASTURE TILES PER PLAYER',
                  style: GoogleFonts.bangers(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [3, 4, 5].map((tiles) {
                    final isSel = selectedTiles == tiles;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedTiles = tiles),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: isSel
                              ? const LinearGradient(
                                  colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.15),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? Colors.white : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$tiles',
                            style: GoogleFonts.bangers(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogButton(
                        label: 'CANCEL',
                        color: Colors.grey.shade700,
                        onTap: () => Navigator.pop(ctx),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDialogButton(
                        label: 'START',
                        color: const Color(0xFFFF8F00),
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _playerCount = selectedPlayers;
                            _tilesPerPlayer = selectedTiles;
                          });
                          _launchGame(
                            playerCount: selectedPlayers,
                            tilesPerPlayer: selectedTiles,
                            isMultiplayer: isMultiplayer,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, 3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.bangers(
              fontSize: 18,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2E1C0C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFFD54F), width: 2),
        ),
        title: Text(
          'PLAYER STATS',
          style: GoogleFonts.bangers(fontSize: 24, color: const Color(0xFFFFD54F), letterSpacing: 2),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('🏆 Trophies', '1,250'),
            _buildStatRow('⚔️ Matches Played', '48'),
            _buildStatRow('🥇 Victories', '34 (71%)'),
            _buildStatRow('🌾 Pastures Captured', '482'),
            _buildStatRow('⭐ Level', '12 (Master Cow)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CLOSE', style: GoogleFonts.bangers(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.bangers(fontSize: 16, color: Colors.white70)),
          Text(value, style: GoogleFonts.bangers(fontSize: 16, color: const Color(0xFFFFD54F))),
        ],
      ),
    );
  }

  void _showShopDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2E1C0C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFFD54F), width: 2),
        ),
        title: Text(
          'COW BARN SHOP',
          style: GoogleFonts.bangers(fontSize: 24, color: const Color(0xFFFFD54F), letterSpacing: 2),
          textAlign: TextAlign.center,
        ),
        content: Text(
          '🐮 New Cow Hats, Wooden Board Skins, and Custom Horns coming in Season 2!',
          style: GoogleFonts.bangers(fontSize: 16, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('AWESOME', style: GoogleFonts.bangers(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
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
              'assets/images/Background/MainMenu_Background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Image.asset(
                'assets/images/Background/Background.jpg',
                fit: BoxFit.cover,
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF332011).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6D4C41), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
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
              Positioned(
                bottom: -4,
                left: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text(
                    '12',
                    style: GoogleFonts.bangers(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
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
                  const Text('🏆', style: TextStyle(fontSize: 12)),
                  Text(
                    ' 1250',
                    style: GoogleFonts.bangers(
                      fontSize: 14,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                width: 90,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white24, width: 0.5),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.65,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
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
        _buildWoodToolButton(icon: Icons.settings, label: 'SETTINGS', onTap: () {}),
        const SizedBox(height: 6),
        _buildWoodToolButton(icon: Icons.bar_chart, label: 'STATS', onTap: _showStatsDialog),
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
    return GestureDetector(
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
    return Column(
      children: [
        _buildPillButton(
          label: 'PLAY',
          icon: Icons.play_arrow_rounded,
          gradientColors: const [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFFF8F00)],
          borderColor: const Color(0xFFFFF8E1),
          height: 58,
          fontSize: 26,
          onTap: () => _showGameSetupDialog(title: 'QUICK MATCH', isMultiplayer: false),
        ),
        const SizedBox(height: 10),
        _buildPillButton(
          label: 'MULTIPLAYER',
          icon: Icons.people_alt_rounded,
          gradientColors: const [Color(0xFF64B5F6), Color(0xFF1E88E5), Color(0xFF1565C0)],
          borderColor: const Color(0xFFBBDEFB),
          onTap: () => _showGameSetupDialog(title: 'PASS & PLAY', isMultiplayer: true),
        ),
        const SizedBox(height: 10),
        _buildPillButton(
          label: 'VS AI',
          icon: Icons.smart_toy_rounded,
          gradientColors: const [Color(0xFF81C784), Color(0xFF43A047), Color(0xFF2E7D32)],
          borderColor: const Color(0xFFC8E6C9),
          onTap: () => _showGameSetupDialog(title: 'SOLO VS AI', isMultiplayer: false),
        ),
        const SizedBox(height: 10),
        _buildPillButton(
          label: 'HOW TO PLAY',
          icon: Icons.menu_book_rounded,
          gradientColors: const [Color(0xFFBA68C8), Color(0xFF8E24AA), Color(0xFF6A1B9A)],
          borderColor: const Color(0xFFE1BEE7),
          onTap: () => Navigator.pushNamed(context, AppRouter.tutorial),
        ),
        const SizedBox(height: 10),
        _buildPillButton(
          label: 'CHALLENGES',
          icon: Icons.shield_rounded,
          gradientColors: const [Color(0xFFA1887F), Color(0xFF6D4C41), Color(0xFF4E342E)],
          borderColor: const Color(0xFFD7CCC8),
          onTap: () => _showGameSetupDialog(title: 'DAILY CHALLENGE', isMultiplayer: false),
        ),
      ],
    );
  }

  Widget _buildPillButton({
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required Color borderColor,
    required VoidCallback onTap,
    double height = 50,
    double fontSize = 20,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 270,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: fontSize + 2),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.bangers(
                fontSize: fontSize,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    offset: const Offset(1.5, 1.5),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomRusticBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1809).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8D6E63), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomItem(
            iconText: '🎁',
            title: 'DAILY REWARD',
            subtitle: '07:45:12',
            color: const Color(0xFFFFD54F),
          ),
          Container(width: 1, height: 32, color: Colors.white24),
          _buildSeasonPassBadge(),
          Container(width: 1, height: 32, color: Colors.white24),
          _buildBottomItem(
            iconText: '📅',
            title: 'DAILY QUESTS',
            subtitle: '2 READY',
            color: const Color(0xFF81C784),
          ),
        ],
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

  Widget _buildSeasonPassBadge() {
    return Row(
      children: [
        const Text('🛡️', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Season 1',
                  style: GoogleFonts.bangers(fontSize: 10, color: Colors.white70),
                ),
                const SizedBox(width: 4),
                const Text('👑', style: TextStyle(fontSize: 9)),
              ],
            ),
            const SizedBox(height: 2),
            Container(
              width: 64,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.35,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Text(
              '350 / 1000',
              style: GoogleFonts.bangers(fontSize: 8, color: Colors.white60),
            ),
          ],
        ),
      ],
    );
  }
}
