
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../assets/asset_paths.dart';
import '../../core/constants/colors.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_controller.dart';
import '../../data/services/progress_service.dart';
import '../../flame/audio_manager.dart';
import '../../game/models/player.dart';
import '../dialogs/daily_quests_dialog.dart';
import '../dialogs/language_selection_dialog.dart';
import '../dialogs/premium_dialog.dart';
import '../dialogs/shop_dialog.dart';
import '../router/app_router.dart';
import '../../game/models/challenge_mode.dart';
import '../../game/ai/ai_player.dart';
import '../../game/tutorial/tutorial_data.dart';
import '../widgets/cartoon_dialog.dart';
import '../widgets/kenney_button.dart';
import '../widgets/bouncy_pressable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tilesPerPlayer = 5;
  int _multiplayerPlayerCount = 2;
  ProgressService? _progressService;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _initProgress();
  }

  Future<void> _initProgress() async {
    _progressService = await ProgressService.getInstance();
    _progressService!.checkDailyLogin();
    _progressService!.refreshDailyQuests();
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        // First-ever launch: prompt player to choose their language before playing.
        if (LocaleController.instance.isFirstLaunch) {
          await LanguageSelectionDialog.show(context: context, isFirstTime: true);
          if (!mounted) return;
        }
        // First-ever launch: drop the player straight into the guided tutorial
        // mini-match before they can wander into a full game.
        if (!_progressService!.tutorialCompleted) {
          _launchTutorial();
        }
      });
    }
  }

  /// Guided first-match tutorial: a tiny board vs a friendly easy AI, with
  /// coach banners walking the player through placing tiles, dropping a herd,
  /// moving, and capturing — and how to win.
  void _launchTutorial() {
    final l10n = AppLocalizations.of(context);
    final players = [
      Player(id: 0, name: l10n.defaultPlayerName(1), color: PlayerColor.blue),
      Player(
        id: 1,
        name: l10n.tutorialCowName,
        color: PlayerColor.red,
        isAi: true,
        difficulty: Difficulty.easy,
      ),
    ];
    Navigator.pushNamed(
      context,
      AppRouter.game,
      arguments: {
        'players': players,
        'herdSize': TutorialScenario.herdSize,
        'boardSize': TutorialScenario.boardSize,
        'tilesPerPlayer': TutorialScenario.tilesPerPlayer,
        'isTutorial': true,
      },
    ).then((_) {
      // Returning from the tutorial: refresh coins/level on the home screen.
      if (mounted) setState(() {});
    });
  }

  List<Player> _createPlayers({required int count, required bool isMultiplayer, Difficulty difficulty = Difficulty.medium}) {
    final l10n = AppLocalizations.of(context);
    final players = <Player>[];
    for (var i = 0; i < count; i++) {
      players.add(Player(
        id: i,
        name: isMultiplayer ? l10n.defaultPlayerName(i + 1) : (i == 0 ? l10n.defaultPlayerName(1) : l10n.aiPlayerName(i)),
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
        // Scale viewport density with pasture size: 4 tiles -> 7, 5 tiles -> 9, 6 tiles -> 11.
        'boardSize': 7 + ((tilesPerPlayer - 4).clamp(0, 2)) * 2,
        'challengeMode': challengeMode,
      },
    ).then((_) {
      // Returning from a match: refresh coins/level/theme on the home screen.
      if (mounted) setState(() {});
    });
  }

  void _showGameSetupDialog({
    required String title,
    required bool isMultiplayer,
    ChallengeMode challengeMode = ChallengeMode.standard,
  }) {
    int selectedTiles = _tilesPerPlayer;
    int selectedPlayerCount = _multiplayerPlayerCount;
    ChallengeMode selectedMode = challengeMode;
    final l10n = AppLocalizations.of(context);

    CartoonDialog.show(
      context: context,
      title: title,
      maxWidth: 390,
      child: StatefulBuilder(
        builder: (ctx, setDialogState) {
          final diffConfigs = [
            (
              label: l10n.easy,
              icon: Icons.sentiment_satisfied_alt_rounded,
              colors: [const Color(0xFF66BB6A), const Color(0xFF2E7D32)],
              accent: const Color(0xFF81C784),
            ),
            (
              label: l10n.medium,
              icon: Icons.bolt_rounded,
              colors: [const Color(0xFFFFB74D), const Color(0xFFE65100)],
              accent: const Color(0xFFFFD54F),
            ),
            (
              label: l10n.hard,
              icon: Icons.local_fire_department_rounded,
              colors: [const Color(0xFFEF5350), const Color(0xFFB71C1C)],
              accent: const Color(0xFFFF8A80),
            ),
          ];

          final tileConfigs = [
            (
              tiles: 4,
              label: l10n.fastTiles,
              icon: Icons.bolt_rounded,
              colors: [const Color(0xFFFFD54F), const Color(0xFFF57F17)],
              accent: const Color(0xFFFFE082),
            ),
            (
              tiles: 5,
              label: l10n.balancedTiles,
              icon: Icons.balance_rounded,
              colors: [const Color(0xFF80DEEA), const Color(0xFF00838F)],
              accent: const Color(0xFFB2EBF2),
            ),
            (
              tiles: 6,
              label: l10n.epicTiles,
              icon: Icons.local_fire_department_rounded,
              colors: [const Color(0xFFFF8A65), const Color(0xFFBF360C)],
              accent: const Color(0xFFFFCCBC),
            ),
          ];

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMultiplayer) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.smart_toy_rounded, color: Color(0xFFFFD54F), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        l10n.cpuDifficulty,
                        style: AppFonts.bangers(
                          fontSize: 16,
                          color: const Color(0xFFFFD54F),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: diffConfigs.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final conf = entry.value;
                      final isSel = _selectedDifficultyIndex == idx;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: BouncyPressable(
                            onTap: () => setDialogState(() => _selectedDifficultyIndex = idx),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isSel
                                    ? LinearGradient(
                                        colors: conf.colors,
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
                                  color: isSel ? conf.accent : Colors.white24,
                                  width: isSel ? 2.5 : 1.5,
                                ),
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(
                                          color: conf.colors[0].withValues(alpha: 0.45),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    conf.icon,
                                    size: 26,
                                    color: isSel ? Colors.white : conf.accent.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    conf.label,
                                    textAlign: TextAlign.center,
                                    style: AppFonts.bangers(
                                      fontSize: 13,
                                      color: isSel ? Colors.white : Colors.white70,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.groups_rounded, color: Color(0xFFFFD54F), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        l10n.numberOfPlayers,
                        style: AppFonts.bangers(
                          fontSize: 16,
                          color: const Color(0xFFFFD54F),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [2, 3, 4].map((count) {
                      final isSel = selectedPlayerCount == count;
                      final playerDotColors = [
                        AppColors.blue,
                        AppColors.red,
                        if (count >= 3) AppColors.yellow,
                        if (count >= 4) AppColors.purple,
                      ];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: BouncyPressable(
                            onTap: () => setDialogState(() => selectedPlayerCount = count),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: isSel
                                    ? const LinearGradient(
                                        colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
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
                                  color: isSel ? const Color(0xFFFFD54F) : Colors.white24,
                                  width: isSel ? 2.5 : 1.5,
                                ),
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: playerDotColors.map((c) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        color: c,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1),
                                      ),
                                    )).toList(),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.playersCount(count),
                                    textAlign: TextAlign.center,
                                    style: AppFonts.bangers(
                                      fontSize: 12.5,
                                      color: isSel ? const Color(0xFF3E2723) : Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sports_esports_rounded, color: Color(0xFFFFD54F), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        l10n.gameMode,
                        style: AppFonts.bangers(
                          fontSize: 16,
                          color: const Color(0xFFFFD54F),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: ChallengeMode.values.map((mode) {
                      final isSel = selectedMode == mode;
                      return BouncyPressable(
                        onTap: () => setDialogState(() => selectedMode = mode),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          constraints: const BoxConstraints(minWidth: 78),
                          decoration: BoxDecoration(
                            gradient: isSel
                                ? const LinearGradient(
                                    colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.12),
                                      Colors.white.withValues(alpha: 0.04),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel ? const Color(0xFFFFD54F) : Colors.white24,
                              width: isSel ? 2.5 : 1.5,
                            ),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(mode.icon, style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 2),
                              Text(
                                mode.localizedTitle(context)
                                    .replaceAll('PASTURE ', '')
                                    .replaceAll(' PASTURE', '')
                                    .replaceAll(' STRATEGY', '')
                                    .replaceAll(' BATTLE', '')
                                    .replaceAll('DU PÂTURAGE', '')
                                    .replaceAll('PÂTURAGE ', '')
                                    .replaceAll(' PÂTURAGE', '')
                                    .trim(),
                                textAlign: TextAlign.center,
                                style: AppFonts.bangers(
                                  fontSize: 11,
                                  color: isSel ? const Color(0xFF3E2723) : Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      selectedMode.localizedDescription(context),
                      textAlign: TextAlign.center,
                      style: AppFonts.bangers(
                        fontSize: 11,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.grid_view_rounded, color: Color(0xFFFFD54F), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      l10n.pastureTilesPerPlayer,
                      style: AppFonts.bangers(
                        fontSize: 16,
                        color: const Color(0xFFFFD54F),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.pastureTilesSubtitle,
                  textAlign: TextAlign.center,
                  style: AppFonts.bangers(
                    fontSize: 11,
                    color: Colors.white54,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: tileConfigs.map((entry) {
                    final isSel = selectedTiles == entry.tiles;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: BouncyPressable(
                          onTap: () => setDialogState(() => selectedTiles = entry.tiles),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSel
                                  ? LinearGradient(
                                      colors: entry.colors,
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )
                                  : LinearGradient(
                                      colors: [
                                        entry.colors[0].withValues(alpha: 0.12),
                                        entry.colors[1].withValues(alpha: 0.04),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSel ? entry.accent : entry.colors[0].withValues(alpha: 0.35),
                                width: isSel ? 2.5 : 1.5,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: entry.colors[0].withValues(alpha: 0.40),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  entry.icon,
                                  size: 24,
                                  color: isSel ? Colors.white : entry.accent,
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? Colors.white.withValues(alpha: 0.28)
                                        : entry.colors[1].withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${entry.tiles}',
                                    style: AppFonts.bangers(
                                      fontSize: 14,
                                      color: isSel ? Colors.white : entry.accent,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  entry.label,
                                  textAlign: TextAlign.center,
                                  style: AppFonts.bangers(
                                    fontSize: 10,
                                    color: isSel ? Colors.white : Colors.white70,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
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
                      flex: 1,
                      child: BouncyPressable(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4E342E),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              l10n.cancel,
                              style: AppFonts.bangers(
                                fontSize: 16,
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
                      child: BouncyPressable(
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _tilesPerPlayer = selectedTiles;
                            if (isMultiplayer) {
                              _multiplayerPlayerCount = selectedPlayerCount;
                            }
                          });
                          _launchGame(
                            playerCount: isMultiplayer ? selectedPlayerCount : 2,
                            tilesPerPlayer: selectedTiles,
                            isMultiplayer: isMultiplayer,
                            challengeMode: selectedMode,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFD54F), width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF66BB6A).withValues(alpha: 0.45),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                              const SizedBox(width: 4),
                              Text(
                                l10n.start,
                                style: AppFonts.bangers(
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
          );
        },
      ),
    );
  }

  void _showChallengePicker() {
    final l10n = AppLocalizations.of(context);
    CartoonDialog.show(
      context: context,
      title: l10n.chooseYourChallenge,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ChallengeMode.values
              .where((mode) => mode != ChallengeMode.standard)
              .map((mode) => GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showGameSetupDialog(title: mode.localizedTitle(context), isMultiplayer: false, challengeMode: mode);
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
                                Text(mode.localizedTitle(context), style: AppFonts.bangers(fontSize: 16, color: Colors.white)),
                                const SizedBox(height: 2),
                                Text(mode.localizedDescription(context), style: AppFonts.bangers(fontSize: 11, color: Colors.white60)),
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
      backgroundColor: const Color(0xFF2E1A0E),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final isLandscape = screenWidth > screenHeight;
          final aspectRatio = screenWidth / screenHeight;
          final isTabletPortrait = !isLandscape && (screenWidth >= 600 || aspectRatio >= 0.60);

          // Responsive width: mobile uses full width with padding, tablet constrains to comfortable touch width
          final contentWidth = screenWidth.clamp(320.0, 460.0);
          // Header plaque height scales proportionally with content width
          final headerHeight = contentWidth < 350
              ? 48.0
              : (contentWidth * 0.155).clamp(52.0, 66.0);
          final isShortScreen = screenHeight < 720;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Responsive Background (Adapts cleanly for phones, tablet portrait, and tablet landscape)
              _buildResponsiveBackground(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                isLandscape: isLandscape,
              ),
              // Main UI Content in SafeArea
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight),
                    child: IntrinsicHeight(
                      child: Center(
                        child: SizedBox(
                          width: contentWidth,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Column(
                              children: [
                                // Top Header: Profile plaque on left, action tool buttons on right
                                SizedBox(
                                  height: headerHeight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      _buildProfilePlaque(height: headerHeight),
                                      _buildTopToolButtons(height: headerHeight),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // 3D Hero Logo (Battle Cows) centered above the hex platform
                                _buildHeroLogo(
                                  contentWidth: contentWidth,
                                  isShortScreen: isShortScreen || isLandscape,
                                ),
                                // Flexible space exposing the background 3D cows on hex platform
                                if (isShortScreen || isLandscape)
                                  const SizedBox(height: 12)
                                else if (isTabletPortrait)
                                  const Spacer(flex: 5)
                                else
                                  const Spacer(flex: 3),
                                // Main Action Buttons Block
                                _buildMenuButtons(contentWidth: contentWidth),
                                // Bottom spacing before the bottom bar
                                if (isShortScreen || isLandscape)
                                  const SizedBox(height: 10)
                                else
                                  const Spacer(flex: 1),
                                const SizedBox(height: 8),
                                // Bottom Bar: Daily Quests banner + Exit button
                                _buildBottomBar(contentWidth: contentWidth),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Responsive background tailored for all form factors:
  /// - Phones & Foldables: Seamless full-bleed picnic scene with top-anchored alignment.
  /// - Tablets Portrait: Top-anchored alignment ensures tablecloth & cows stay in view and never shift under the logo.
  /// - Tablets Landscape: Authentic wide rustic wood table base with a sharp, full-height feathered centerpiece so cows & scene are never cropped out.
  Widget _buildResponsiveBackground({
    required double screenWidth,
    required double screenHeight,
    required bool isLandscape,
  }) {
    if (isLandscape) {
      final centerWidth = screenHeight * (1536.0 / 2752.0);

      return Stack(
        fit: StackFit.expand,
        children: [
          // Base layer: wide rustic wooden table surface
          Image.asset(
            AssetPaths.tableGameplayBackground,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              AssetPaths.backgroundWood,
              fit: BoxFit.cover,
            ),
          ),
          // Soft ambient vignette across the wide table
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.25,
                colors: [
                  Color(0x10000000),
                  Color(0x751E1008),
                  Color(0xC0120804),
                ],
              ),
            ),
          ),
          // Feathered center artwork displaying the full picnic scene, cows & tablecloth
          Center(
            child: SizedBox(
              width: centerWidth,
              height: screenHeight,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.08, 0.92, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  AssetPaths.mainMenuBackground,
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Portrait Mode (Phones, Foldables, Tablets):
    // Use topCenter alignment so the top checkered tablecloth and milk jug are always preserved,
    // and the cows on the hex platform remain positioned right beneath the hero logo.
    return Image.asset(
      AssetPaths.mainMenuBackground,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (context, error, stack) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E342E), Color(0xFF2E1A0E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  /// 3D Battle Cows carved wood logo, floating directly above the hex cows.
  Widget _buildHeroLogo({required double contentWidth, required bool isShortScreen}) {
    final logoWidth = isShortScreen
        ? (contentWidth * 0.44).clamp(150.0, 195.0)
        : (contentWidth * 0.50).clamp(175.0, 230.0);
    final logoHeight = logoWidth * (383.0 / 543.0);

    return SizedBox(
      width: logoWidth,
      height: logoHeight,
      child: Image.asset(
        AssetPaths.battleCowsLogo,
        fit: BoxFit.contain,
      ),
    );
  }

  /// Wooden rope-framed player profile plaque (top-left).
  Widget _buildProfilePlaque({required double height}) {
    final p = _progressService?.progress;
    final coins = p?.coins ?? 0;
    final stars = p?.totalCampaignStars ?? 0;
    final l10n = AppLocalizations.of(context);
    final width = height * (526.0 / 204.0);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Plaque background sprite
          Positioned.fill(
            child: Image.asset(
              AssetPaths.menuPlayerProfilePlaque,
              fit: BoxFit.fill,
            ),
          ),
          // Left avatar circle frame
          Positioned(
            left: width * (28.0 / 526.0),
            top: height * (42.0 / 204.0),
            width: height * (116.0 / 204.0),
            height: height * (116.0 / 204.0),
            child: ClipOval(
              child: Image.asset(
                AssetPaths.playerCowAvatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text('🐮', style: TextStyle(fontSize: 22)),
                ),
              ),
            ),
          ),
          // Plaque Text Info (Player Name, Coins, Stars)
          Positioned(
            left: width * (162.0 / 526.0),
            right: width * (24.0 / 526.0),
            top: height * (26.0 / 204.0),
            bottom: height * (26.0 / 204.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.defaultPlayerName(1).toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.bangers(
                      fontSize: (height * 0.25).clamp(13.0, 18.0),
                      color: const Color(0xFFFFFDE7),
                      letterSpacing: 0.8,
                      shadows: const [
                        Shadow(
                          color: Color(0xFF1E1008),
                          offset: Offset(1.5, 1.5),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 3),
                      Text(
                        '$coins',
                        style: AppFonts.bangers(
                          fontSize: (height * 0.22).clamp(12.0, 16.0),
                          color: const Color(0xFFFFD54F),
                          letterSpacing: 0.6,
                          shadows: const [
                            Shadow(
                              color: Color(0xFF1E1008),
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('⭐', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 3),
                      Text(
                        '$stars',
                        style: AppFonts.bangers(
                          fontSize: (height * 0.22).clamp(12.0, 16.0),
                          color: const Color(0xFFFFD700),
                          letterSpacing: 0.6,
                          shadows: const [
                            Shadow(
                              color: Color(0xFF1E1008),
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top-right row of 3 tool buttons: Shop, No Ads, Settings.
  Widget _buildTopToolButtons({required double height}) {
    final l10n = AppLocalizations.of(context);
    final btnSize = (height * 0.90).clamp(44.0, 58.0);
    final spacing = (height * 0.09).clamp(4.0, 7.0);

    Widget buildToolBtn({
      required String asset,
      required String label,
      required VoidCallback onTap,
    }) {
      return BouncyPressable(
        scaleDown: 0.92,
        onTap: onTap,
        child: SizedBox(
          width: btnSize,
          height: btnSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                bottom: btnSize * 0.07,
                child: Text(
                  label.toUpperCase(),
                  style: AppFonts.bangers(
                    fontSize: (btnSize * 0.17).clamp(8.0, 10.0),
                    color: const Color(0xFFFFF3C4),
                    letterSpacing: 0.5,
                    shadows: const [
                      Shadow(
                        color: Color(0xFF1E1008),
                        offset: Offset(0, 1.2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Shop Button
        buildToolBtn(
          asset: AssetPaths.menuBtnShop,
          label: l10n.shopBtn,
          onTap: () {
            AudioManager().playSelect();
            _showShopDialog();
          },
        ),
        SizedBox(width: spacing),
        // No Ads Button
        buildToolBtn(
          asset: AssetPaths.menuBtnNoAds,
          label: l10n.noAdsBtn,
          onTap: () {
            AudioManager().playSelect();
            PremiumDialog.show(context);
          },
        ),
        SizedBox(width: spacing),
        // Settings Button
        buildToolBtn(
          asset: AssetPaths.uiBtnSettingsGear,
          label: l10n.settingsBtn,
          onTap: () {
            AudioManager().playSelect();
            Navigator.pushNamed(context, AppRouter.settings);
          },
        ),
      ],
    );
  }

  /// Main action buttons block: Campaign, Modes, Challenges, How to Play.
  Widget _buildMenuButtons({required double contentWidth}) {
    final l10n = AppLocalizations.of(context);
    final rowSpacing = (contentWidth * 0.024).clamp(8.0, 11.0);
    final cardWidth = (contentWidth - rowSpacing) / 2.0;

    // Derived from natural sprite aspect ratios to prevent any stretching
    // Hero campaign: 543 / 165
    final campaignHeight = (contentWidth * (165.0 / 543.0)).clamp(85.0, 118.0);
    // Mode cards: 354 / 165
    final modeCardHeight = (cardWidth * (165.0 / 354.0)).clamp(72.0, 92.0);
    // Secondary buttons: 337 / 122
    final secondaryHeight = (cardWidth * (122.0 / 337.0)).clamp(56.0, 72.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Hero Barnyard Campaign Button
        BouncyPressable(
          scaleDown: 0.96,
          onTap: () {
            AudioManager().playSelect();
            Navigator.pushNamed(context, AppRouter.campaign).then((_) {
              if (mounted) setState(() {});
            });
          },
          child: SizedBox(
            width: contentWidth,
            height: campaignHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AssetPaths.menuBtnHeroCampaign,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  left: contentWidth * 0.28,
                  right: contentWidth * 0.08,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        l10n.barnyardCampaign.toUpperCase(),
                        maxLines: 1,
                        style: AppFonts.bangers(
                          fontSize: (campaignHeight * 0.38).clamp(20.0, 27.0),
                          color: const Color(0xFFFFF9C4),
                          letterSpacing: 0.8,
                          shadows: const [
                            Shadow(
                              color: Color(0xFF0F2604),
                              offset: Offset(2, 2),
                              blurRadius: 2,
                            ),
                            Shadow(
                              color: Color(0xFF0F2604),
                              offset: Offset(-1, -1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: rowSpacing),
        // 2. Play vs AI & Local Multiplayer Side-by-Side
        SizedBox(
          height: modeCardHeight,
          child: Row(
            children: [
              // Play vs AI
              Expanded(
                child: BouncyPressable(
                  scaleDown: 0.94,
                  onTap: () {
                    AudioManager().playSelect();
                    _showGameSetupDialog(title: l10n.playVsAi, isMultiplayer: false);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          AssetPaths.menuCardModeBlue,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        left: cardWidth * 0.08,
                        right: cardWidth * 0.08,
                        top: modeCardHeight * 0.06,
                        bottom: modeCardHeight * 0.20,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: modeCardHeight * 0.38,
                                  height: modeCardHeight * 0.38,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF0B2134),
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      AssetPaths.playerCowAvatar,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.playVsAi.toUpperCase(),
                                  maxLines: 1,
                                  style: AppFonts.bangers(
                                    fontSize: (modeCardHeight * 0.36).clamp(16.0, 22.0),
                                    color: const Color(0xFFFFF9C4),
                                    letterSpacing: 0.8,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xFF0B2134),
                                        offset: Offset(2, 2),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: rowSpacing),
              // Local Multiplayer
              Expanded(
                child: BouncyPressable(
                  scaleDown: 0.94,
                  onTap: () {
                    AudioManager().playSelect();
                    _showGameSetupDialog(title: l10n.localMultiplayer, isMultiplayer: true);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          AssetPaths.menuCardModeRed,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        left: cardWidth * 0.10,
                        right: cardWidth * 0.10,
                        top: modeCardHeight * 0.06,
                        bottom: modeCardHeight * 0.20,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'LOCAL\nMULTIPLAYER',
                              textAlign: TextAlign.center,
                              style: AppFonts.bangers(
                                fontSize: (modeCardHeight * 0.29).clamp(14.0, 19.0),
                                color: const Color(0xFFFFF9C4),
                                height: 0.95,
                                letterSpacing: 0.8,
                                shadows: const [
                                  Shadow(
                                    color: Color(0xFF350808),
                                    offset: Offset(2, 2),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rowSpacing),
        // 3. Challenges & How to Play Side-by-Side
        SizedBox(
          height: secondaryHeight,
          child: Row(
            children: [
              // Challenges
              Expanded(
                child: BouncyPressable(
                  scaleDown: 0.94,
                  onTap: () {
                    AudioManager().playSelect();
                    _showChallengePicker();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          AssetPaths.menuBtnSecondaryShield,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        left: cardWidth * 0.28,
                        right: cardWidth * 0.06,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              l10n.challenges.toUpperCase(),
                              maxLines: 1,
                              style: AppFonts.bangers(
                                fontSize: (secondaryHeight * 0.40).clamp(15.0, 21.0),
                                color: const Color(0xFFFFF9C4),
                                letterSpacing: 0.8,
                                shadows: const [
                                  Shadow(
                                    color: Color(0xFF261309),
                                    offset: Offset(1.5, 1.5),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: rowSpacing),
              // How to Play
              Expanded(
                child: BouncyPressable(
                  scaleDown: 0.94,
                  onTap: () {
                    AudioManager().playSelect();
                    Navigator.pushNamed(context, AppRouter.tutorial);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          AssetPaths.menuBtnSecondaryBlank,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        left: cardWidth * 0.08,
                        right: cardWidth * 0.06,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  color: const Color(0xFFFFF3C4),
                                  size: (secondaryHeight * 0.40).clamp(17.0, 23.0),
                                  shadows: const [
                                    Shadow(
                                      color: Color(0xFF261309),
                                      offset: Offset(1.5, 1.5),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.howToPlay.toUpperCase(),
                                  maxLines: 1,
                                  style: AppFonts.bangers(
                                    fontSize: (secondaryHeight * 0.40).clamp(15.0, 21.0),
                                    color: const Color(0xFFFFF3C4),
                                    letterSpacing: 0.8,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xFF261309),
                                        offset: Offset(1.5, 1.5),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bottom bar with Daily Quests banner and Exit door button.
  Widget _buildBottomBar({required double contentWidth}) {
    final p = _progressService?.progress;
    final readyQuests = p?.dailyQuests.where((q) => q.isComplete && !q.claimed).length ?? 0;
    final spacing = (contentWidth * 0.024).clamp(8.0, 11.0);
    // Aspect ratio 560 / 138 = 4.058
    final bottomBarHeight = (contentWidth * 0.170).clamp(58.0, 74.0);
    final exitBtnWidth = bottomBarHeight * (169.0 / 161.0);
    final questsWidth = contentWidth - spacing - exitBtnWidth;

    return SizedBox(
      height: bottomBarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Daily Quests Banner
          Expanded(
            child: BouncyPressable(
              scaleDown: 0.96,
              onTap: () {
                AudioManager().playSelect();
                if (_progressService == null) return;
                DailyQuestsDialog.show(
                  context: context,
                  progress: _progressService!,
                ).then((_) => setState(() {}));
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      AssetPaths.menuBannerDailyQuests,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    left: questsWidth * 0.28,
                    right: questsWidth * 0.06,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppLocalizations.of(context).dailyQuests.toUpperCase(),
                          maxLines: 1,
                          style: AppFonts.bangers(
                            fontSize: (bottomBarHeight * 0.40).clamp(18.0, 25.0),
                            color: const Color(0xFFFFF9C4),
                            letterSpacing: 0.8,
                            shadows: const [
                              Shadow(
                                color: Color(0xFF261309),
                                offset: Offset(2, 2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (readyQuests > 0)
                    Positioned(
                      top: -3,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 3),
                          ],
                        ),
                        child: Text(
                          '$readyQuests',
                          style: AppFonts.bangers(fontSize: 11, color: Colors.white, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: spacing),
          // Exit Button
          BouncyPressable(
            scaleDown: 0.92,
            onTap: () {
              AudioManager().playSelect();
              _showExitDialog();
            },
            child: SizedBox(
              width: exitBtnWidth,
              height: bottomBarHeight,
              child: Image.asset(
                AssetPaths.menuBtnExit,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Cartoon dialog confirmation for exiting the game.
  void _showExitDialog() {
    final l10n = AppLocalizations.of(context);
    CartoonDialog.show(
      context: context,
      title: l10n.exitGameTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.exitGameConfirm,
            style: AppFonts.bangers(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: KenneyButton(
                  label: l10n.cancel,
                  isWide: true,
                  style: KenneyBtnStyle.neutral,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KenneyButton(
                  label: l10n.exit,
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
  }
}


