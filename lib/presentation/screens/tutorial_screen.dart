import 'package:flutter/material.dart';
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
      title: 'Cows Move in 6 Directions',
      description: 'Unlike square grids, hex grids have 6 straight-line directions. Your cows always move in one of these 6 directions.',
      icon: Icons.hexagon,
      color: AppColors.blue,
      visual: _buildHexDirectionVisual(),
    ),
    TutorialPage(
      title: 'Split Your Stack',
      description: 'On your turn, choose a stack and split it. Some cows stay, others move in a straight line until blocked.',
      icon: Icons.call_split,
      color: AppColors.red,
      visual: _buildSplitVisual(),
    ),
    TutorialPage(
      title: 'Block Opponents',
      description: 'Place your cows to block opponent paths. Control key tiles to limit their expansion options.',
      icon: Icons.block,
      color: AppColors.yellow,
      visual: _buildBlockingVisual(),
    ),
    TutorialPage(
      title: 'Trap Enemy Stacks',
      description: 'Surround enemy stacks completely to trap them forever. Trapped stacks can never move again!',
      icon: Icons.lock,
      color: AppColors.purple,
      visual: _buildTrapVisual(),
    ),
    TutorialPage(
      title: 'Most Territory Wins!',
      description: 'Game ends when no player has legal moves. Count tiles occupied - most tiles wins! Tiebreaker: most cows remaining.',
      icon: Icons.emoji_events,
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grassDark,
      body: SafeArea(
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
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 60),
                  Text(
                    '${_currentPage + 1} / ${_pages.length}',
                    style: const TextStyle(
                      color: AppColors.lightText,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Skip'),
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
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Got it!' : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: page.color, width: 3),
            ),
            child: Center(
              child: page.visual ?? Icon(
                page.icon,
                size: 60,
                color: page.color,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.lightText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.lightText.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget _buildHexDirectionVisual() {
    return const Text(
      '↖ ↗\n ⬡ \n↙ ↘',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
    );
  }

  static Widget _buildSplitVisual() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '5 → 2 + 3',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        Text(
          'Stay + Move',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.lightText,
          ),
        ),
      ],
    );
  }

  static Widget _buildBlockingVisual() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: AppColors.blue, size: 20),
        Icon(Icons.block, color: AppColors.red, size: 30),
        Icon(Icons.circle, color: AppColors.blue, size: 20),
      ],
    );
  }

  static Widget _buildTrapVisual() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: AppColors.red, size: 16),
            Icon(Icons.circle, color: AppColors.red, size: 16),
            Icon(Icons.circle, color: AppColors.red, size: 16),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: AppColors.red, size: 16),
            Icon(Icons.lock, color: AppColors.blue, size: 20),
            Icon(Icons.circle, color: AppColors.red, size: 16),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: AppColors.red, size: 16),
            Icon(Icons.circle, color: AppColors.red, size: 16),
            Icon(Icons.circle, color: AppColors.red, size: 16),
          ],
        ),
      ],
    );
  }

  static Widget _buildWinVisual() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.emoji_events, color: AppColors.yellow, size: 40),
        Text(
          '12 > 8',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
      ],
    );
  }
}

class TutorialPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget? visual;

  const TutorialPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.visual,
  });
}
