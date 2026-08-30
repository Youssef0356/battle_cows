import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialPage> _pages = [
    TutorialPage(
      title: 'COWS MOVE IN 6 DIRECTIONS',
      description: 'Unlike square grids, hex grids have 6 straight-line directions. Your cows always move in one of these 6 directions.',
      color: AppColors.blue,
      visual: _buildHexDirectionVisual(),
    ),
    TutorialPage(
      title: 'SPLIT YOUR STACK',
      description: 'On your turn, choose a stack and split it. Some cows stay, others move in a straight line until blocked.',
      color: AppColors.red,
      visual: _buildSplitVisual(),
    ),
    TutorialPage(
      title: 'BLOCK OPPONENTS',
      description: 'Place your cows to block opponent paths. Control key tiles to limit their expansion options.',
      color: AppColors.yellow,
      visual: _buildBlockingVisual(),
    ),
    TutorialPage(
      title: 'TRAP ENEMY STACKS',
      description: 'Surround enemy stacks completely to trap them forever. Trapped stacks can never move again!',
      color: AppColors.purple,
      visual: _buildTrapVisual(),
    ),
    TutorialPage(
      title: 'MOST TERRITORY WINS!',
      description: 'Game ends when no player has legal moves. Count tiles occupied - most tiles wins! Tiebreaker: most cows remaining.',
      color: AppColors.primaryAction,
      visual: _buildWinVisual(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background/Background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: _previousPage,
                          child: Text(
                            '< BACK',
                            style: GoogleFonts.bangers(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 80),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${_currentPage + 1} / ${_pages.length}',
                          style: GoogleFonts.bangers(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'SKIP',
                          style: GoogleFonts.bangers(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 32 : 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? _pages[_currentPage].color
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isActive ? Colors.white : Colors.transparent,
                                width: 1,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _pages[_currentPage].color,
                                _pages[_currentPage].color.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: _pages[_currentPage].color.withValues(alpha: 0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            child: Text(
                              _currentPage == _pages.length - 1 ? 'GOT IT!' : 'NEXT',
                              style: GoogleFonts.bangers(
                                fontSize: 22,
                                color: Colors.white,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    offset: const Offset(2, 2),
                                    blurRadius: 3,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(TutorialPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  page.color.withValues(alpha: 0.4),
                  page.color.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: page.color, width: 4),
              boxShadow: [
                BoxShadow(
                  color: page.color.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(child: page.visual),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: GoogleFonts.bangers(
              fontSize: 32,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  offset: const Offset(2, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: GoogleFonts.bangers(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 1,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget _buildHexDirectionVisual() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\u2196 \u2197',
          style: GoogleFonts.bangers(
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        Text(
          '\u2B21',
          style: GoogleFonts.bangers(
            fontSize: 40,
            color: Colors.white,
          ),
        ),
        Text(
          '\u2199 \u2198',
          style: GoogleFonts.bangers(
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  static Widget _buildSplitVisual() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '5 \u2192 2 + 3',
          style: GoogleFonts.bangers(
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'STAY + MOVE',
          style: GoogleFonts.bangers(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  static Widget _buildBlockingVisual() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: AppColors.blue, size: 24),
        SizedBox(width: 4),
        Icon(Icons.block, color: AppColors.red, size: 36),
        SizedBox(width: 4),
        Icon(Icons.circle, color: AppColors.blue, size: 24),
      ],
    );
  }

  static Widget _buildTrapVisual() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: AppColors.red, size: 18),
            SizedBox(width: 2),
            Icon(Icons.circle, color: AppColors.red, size: 18),
            SizedBox(width: 2),
            Icon(Icons.circle, color: AppColors.red, size: 18),
          ],
        ),
        const SizedBox(height: 2),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: AppColors.red, size: 18),
            SizedBox(width: 2),
            Icon(Icons.lock, color: AppColors.blue, size: 24),
            SizedBox(width: 2),
            Icon(Icons.circle, color: AppColors.red, size: 18),
          ],
        ),
        const SizedBox(height: 2),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: AppColors.red, size: 18),
            SizedBox(width: 2),
            Icon(Icons.circle, color: AppColors.red, size: 18),
            SizedBox(width: 2),
            Icon(Icons.circle, color: AppColors.red, size: 18),
          ],
        ),
      ],
    );
  }

  static Widget _buildWinVisual() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '\ud83c\udfc6',
          style: TextStyle(fontSize: 48),
        ),
        Text(
          '12 > 8',
          style: GoogleFonts.bangers(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class TutorialPage {
  final String title;
  final String description;
  final Color color;
  final Widget? visual;

  const TutorialPage({
    required this.title,
    required this.description,
    required this.color,
    this.visual,
  });
}
