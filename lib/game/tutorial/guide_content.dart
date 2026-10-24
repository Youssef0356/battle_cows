/// A numbered step inside a guide section.
class GuideStep {
  final int number;
  final String title;
  final String body;

  const GuideStep(this.number, this.title, this.body);
}

/// One tab of the How to Play guide.
class GuideSection {
  final String id;
  final String tabLabel;
  final String emoji;
  final String headline;
  final List<GuideStep> steps;
  final List<String> tips;

  const GuideSection({
    required this.id,
    required this.tabLabel,
    required this.emoji,
    required this.headline,
    required this.steps,
    required this.tips,
  });
}

/// One game mode, described by how it is started, what changes and how to win.
class GuideMode {
  final String startPath;
  final List<String> rules;
  final List<String> tips;

  const GuideMode({
    required this.startPath,
    required this.rules,
    required this.tips,
  });
}

/// All static text of the How to Play guide, kept free of widgets so it can
/// be unit tested. Every rule here was verified against the game code:
/// `GameEngine`, `GameBoard.getReachablePositions`, `BattleCowsGame`
/// (`_startTimer`, `_handleTimeUp`, `placeFence`, `moveFence`) and
/// `ChallengeModeDetails`.
class GuideContent {
  static const String modesTabId = 'modes';
  static const String modesTabLabel = 'MODES';
  static const String modesTabEmoji = '🎯';
  static const String modesHeadline =
      'Three ways to play, all from the home screen.';

  static const List<GuideSection> sections = [
    GuideSection(
      id: 'setup',
      tabLabel: 'SETUP',
      emoji: '🧱',
      headline: 'Build the pasture, then drop your herd onto it.',
      steps: [
        GuideStep(
          1,
          'PICK YOUR MATCH',
          'PLAY VS AI lets you choose EASY, MEDIUM or HARD. LOCAL MULTIPLAYER puts two humans on the same device. Both then ask for the pasture size: SMALL (3 tiles), MEDIUM (4) or LARGE (5).',
        ),
        GuideStep(
          2,
          'BUILD THE PASTURE',
          'Players take turns adding 4-hex diamond tiles. Tap ROTATE to spin the tile, drag it onto a free spot that touches the pasture, then tap PLACE. Every hex you add is ground worth fighting for.',
        ),
        GuideStep(
          3,
          'PLACE YOUR HERD',
          'When the last tile is down, each player taps a highlighted edge hex to drop a herd of 16 cows. Choose a spot with room to spread out.',
        ),
      ],
      tips: [
        'More tiles means a bigger battlefield: 3 tiles is about 7 hexes wide, 5 tiles about 11.',
        'HARD AI plays by exactly the same rules as you - it just picks better moves.',
        'Herds start on the rim of the pasture, so your first moves push towards the middle.',
      ],
    ),
    GuideSection(
      id: 'moves',
      tabLabel: 'MOVES',
      emoji: '➡️',
      headline: 'Tap a herd, split the herd, march in a straight line.',
      steps: [
        GuideStep(
          4,
          'SELECT A HERD',
          'Tap a hex holding 2 or more of your cows. A glowing ring marks it and every reachable hex lights up with a dashed outline. A herd of 1 cow can never move again - it only holds ground.',
        ),
        GuideStep(
          5,
          'SPLIT THE HERD',
          'The MOVE COWS panel on the right shows the herd size and "move / stay". Drag the slider to choose how many cows march out; at least 1 cow always stays behind to hold the hex.',
        ),
        GuideStep(
          6,
          'MARCH',
          'Tap a glowing hex to send them. Cows walk in straight hex lines only, and the herd reaches as many hexes as the number of cows you sent. Enemy herds and fences block the lane.',
        ),
      ],
      tips: [
        'Range equals cows sent: send 6 cows to cross up to 6 hexes.',
        'Split 1-2 cow parties early to grab cheap hexes, then keep a big herd to punch a lane.',
        'Changed your mind? Tap CANCEL (or tap the herd again) before you commit the move.',
        'Watch out for dead ends - a 1-cow herd is stuck there forever.',
      ],
    ),
    GuideSection(
      id: 'battle',
      tabLabel: 'BATTLE',
      emoji: '🏴',
      headline: 'Claim hexes, overrun herds, hold the most ground.',
      steps: [
        GuideStep(
          7,
          'CLAIM',
          'Any hex you move onto becomes yours and fills with your colour. Every hex you hold is worth one point when the match ends.',
        ),
        GuideStep(
          8,
          'OVERRUN',
          'Land on a hex where an enemy herd is standing and you overrun it: their herd disappears and those cows count as captures for your stats and daily quests.',
        ),
        GuideStep(
          9,
          'WIN',
          'The match ends when nobody has a legal move left. The player holding the most hexes wins; a tie goes to the biggest connected group of hexes.',
        ),
      ],
      tips: [
        'Capturing an enemy hex also deletes their cows, and fewer cows means less reach.',
        'Chain your hexes together - a connected block wins ties and is harder to surround.',
        'Blocking is a weapon: park a herd in the lane your opponent needs.',
      ],
    ),
  ];

  static const List<GuideMode> modes = [
    GuideMode(
      startPath: 'HOME  >  PLAY VS AI   or   LOCAL MULTIPLAYER',
      rules: [
        'Turn-based with no clock - take as long as you like.',
        'One 16-cow herd each, no fences and no special tiles.',
        'Most hexes when the board locks up wins the match.',
        'Ties are broken by the biggest connected group of hexes.',
      ],
      tips: [
        'Spread small parties early: free hexes now beat a perfect formation later.',
        'Keep one large herd as a battering ram through the middle lane.',
        'Attack the opponent\'s biggest herd to cut their movement range.',
      ],
    ),
    GuideMode(
      startPath: 'HOME  >  CHALLENGES  >  TIMED STRATEGY   (or LOCAL MULTIPLAYER > GAME MODE)',
      rules: [
        '60 seconds per turn and the clock never stops.',
        'Run out of time: you lose a heart and one of your herds scrambles at random.',
        'Every player starts with 3 hearts. Lose all 3 and the match is over.',
        'Territory still decides the winner when the match ends.',
      ],
      tips: [
        'Plan your move while your opponent is thinking - your clock starts with your turn.',
        'When the timer turns red, take the short safe move instead of the clever one.',
        'A random scramble can wreck a stacked formation, so never sit idle.',
      ],
    ),
    GuideMode(
      startPath: 'HOME  >  CHALLENGES  >  FENCE BATTLE   (or LOCAL MULTIPLAYER > GAME MODE)',
      rules: [
        'Each player owns 3 fences.',
        'Use FENCES, then tap an empty hex to place one, or tap your own fence to move it.',
        'Placing or moving a fence uses your whole turn.',
        'Fences lock a hex: no herd can step into or through it, and it is not territory.',
      ],
      tips: [
        'Fence the lane the enemy\'s biggest herd is walking down.',
        'Wall a herd into a corner - trapped 1-cow herds can never move again.',
        'Hold one fence back for defence instead of dumping all 3 at the start.',
      ],
    ),
    GuideMode(
      startPath: 'HOME  >  CHALLENGES  >  GOLDEN PASTURE   (or LOCAL MULTIPLAYER > GAME MODE)',
      rules: [
        'A glowing Golden Clover sits right in the center of the pasture.',
        'Landing on the Golden Clover nourishes your herd with +1 bonus cow.',
        'Holding the Golden Clover hex counts as 3 territory points at game end.',
        'Dominating the center clover is the fastest path to victory.',
      ],
      tips: [
        'Rush toward the center on your opening moves.',
        'Leave a stout herd on the golden tile so you cannot be easily displaced.',
        'Defend your approach corridors against enemy cut-offs.',
      ],
    ),
    GuideMode(
      startPath: 'HOME  >  CHALLENGES  >  STAMPEDE RUSH   (or LOCAL MULTIPLAYER > GAME MODE)',
      rules: [
        'Hay bales and mud patches scatter across the meadow.',
        'Claiming hay bales awards +1 cow directly into your advancing herd.',
        'Herds of 4+ cows unleash high-velocity stampede slides.',
        'Mud terrain costs 2 movement to cross - navigate around it or muscle through!',
      ],
      tips: [
        'Route your splits directly through hay bales to grow your cow count.',
        'Herd size is king: big herds cross vast distances in a single charge.',
        'Use mud bogs to slow down enemy pursuing herds.',
      ],
    ),
  ];

  /// The tab labels in display order (sections first, then MODES).
  static List<String> get tabLabels =>
      [...sections.map((s) => s.tabLabel), modesTabLabel];
}