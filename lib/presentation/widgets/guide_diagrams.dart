import '../../core/constants/colors.dart';
import '../../game/models/hex_position.dart';
import 'hex_diagram.dart';

/// All board diagrams of the How to Play guide. Every layout matches the real
/// rules: straight-line reach (`GameBoard.getReachablePositions`), herds of
/// 16 cows, 3 fences per player and the fence gate tile.
class GuideDiagrams {
  GuideDiagrams._();

  /// Step 2 - a 4-hex diamond tile dropping into a pasture corner.
  static HexDiagram tileDrop({double radius = 26}) => HexDiagram(
        radius: radius,
        caption: 'TAP ROTATE, DRAG ONTO A FREE SPOT, THEN TAP PLACE',
        cells: [
          const HexDiagramCell(HexPosition(0, 0), owner: PlayerColor.blue,
              herdSize: 6),
          const HexDiagramCell(HexPosition(1, 0), owner: PlayerColor.red,
              herdSize: 8),
          const HexDiagramCell(HexPosition(0, 1), isValidMove: true),
          const HexDiagramCell(HexPosition(-1, 1), isValidMove: true),
          // The new 4-hex tile being placed:
          const HexDiagramCell(HexPosition(1, -1), isSelected: true),
          const HexDiagramCell(HexPosition(2, -1), isSelected: true),
          const HexDiagramCell(HexPosition(1, -2), isSelected: true),
          const HexDiagramCell(HexPosition(2, -2), isSelected: true),
        ],
      );

  /// Step 3 - both herds of 16 dropped on rim hexes.
  static HexDiagram herdPlacement({double radius = 26}) => HexDiagram(
        radius: radius,
        caption: 'EVERY PLAYER TAPS A GLOWING RIM HEX TO DROP 16 COWS',
        cells: [
          const HexDiagramCell.herd(
              HexPosition(-2, 0), PlayerColor.blue, 16,
              isSelected: true),
          const HexDiagramCell(HexPosition(-1, 0), isValidMove: true),
          const HexDiagramCell(HexPosition(-1, 1), isValidMove: true),
          const HexDiagramCell(HexPosition(0, 0)),
          const HexDiagramCell(HexPosition(0, 1)),
          const HexDiagramCell(HexPosition(1, 0)),
          const HexDiagramCell.herd(HexPosition(2, 0), PlayerColor.red, 16,
              isSelected: true),
        ],
      );

  /// Step 4 - a selected 7-cow herd with its straight-line reach.
  static HexDiagram selectHerd({double radius = 26}) => HexDiagram(
        radius: radius,
        caption: 'TAP A HERD OF 2+ - EVERY REACHABLE HEX LIGHTS UP',
        cells: [
          const HexDiagramCell.herd(
              HexPosition(0, 0), PlayerColor.blue, 7,
              isSelected: true),
          const HexDiagramCell(HexPosition(1, 0), isValidMove: true),
          const HexDiagramCell(HexPosition(2, 0), isValidMove: true),
          const HexDiagramCell(HexPosition(3, 0), isValidMove: true),
          const HexDiagramCell(HexPosition(4, 0), isValidMove: true),
          const HexDiagramCell(HexPosition(5, 0), isValidMove: true),
          const HexDiagramCell(HexPosition(6, 0), isValidMove: true),
          const HexDiagramCell(HexPosition(0, 1), isValidMove: true),
          const HexDiagramCell(HexPosition(0, 2), isValidMove: true),
          const HexDiagramCell(HexPosition(0, 3), isValidMove: true),
          const HexDiagramCell(HexPosition(0, 4), isValidMove: true),
          const HexDiagramCell(HexPosition(0, 5), isValidMove: true),
          const HexDiagramCell(HexPosition(0, 6), isValidMove: true),
        ],
        badges: [
          const HexDiagramBadge(
            HexPosition(0, 0),
            '7 COWS',
            color: AppColors.blue,
            slot: HexBadgeSlot.centerTop,
          ),
        ],
      );

  /// Step 5 - splitting a 7-cow herd into 3 movers and 4 stayers.
  static HexDiagram splitHerd({double radius = 26}) => HexDiagram(
        radius: radius,
        caption: 'DRAG THE SLIDER: 3 MOVE, 4 STAY BEHIND',
        cells: [
          const HexDiagramCell.herd(
              HexPosition(0, 0), PlayerColor.blue, 4,
              isSelected: true),
          const HexDiagramCell(HexPosition(1, 0), isValidMove: true),
          const HexDiagramCell(HexPosition(2, 0), isValidMove: true),
          const HexDiagramCell(HexPosition(3, 0), isValidMove: true),
        ],
        arrows: [
          const HexDiagramArrow(HexPosition(0, 0), HexPosition(3, 0)),
        ],
        badges: [
          const HexDiagramBadge(
            HexPosition(3, 0),
            '3 GO',
            color: AppColors.blue,
            slot: HexBadgeSlot.bottom,
          ),
          const HexDiagramBadge(
            HexPosition(0, 0),
            '4 STAY',
            color: AppColors.grassMid,
            slot: HexBadgeSlot.centerTop,
          ),
        ],
      );

  /// Step 6 - enemy herds and a fence gate blocking the straight lane.
  static HexDiagram blockedLane({double radius = 26}) => HexDiagram(
        radius: radius,
        caption: 'ENEMY HERDS AND FENCES BLOCK THE LANE - GO AROUND',
        cells: [
          const HexDiagramCell.herd(
              HexPosition(-1, 0), PlayerColor.blue, 9,
              isSelected: true),
          const HexDiagramCell(HexPosition(0, 0), isValidMove: true),
          const HexDiagramCell.herd(HexPosition(1, 0), PlayerColor.red, 12),
          const HexDiagramCell(
            HexPosition(2, 0),
            specialAsset: 'assets/images/Board Tiles/tile_fence_gate.png',
          ),
          const HexDiagramCell(HexPosition(3, 0)),
          const HexDiagramCell(HexPosition(2, 1), isValidMove: true),
          const HexDiagramCell(HexPosition(3, 1), isValidMove: true),
          const HexDiagramCell(HexPosition(4, 1), isValidMove: true),
          const HexDiagramCell(HexPosition(5, 1), isValidMove: true),
        ],
      );

  /// Step 7 - moving onto a hex turns it into your colour.
  static HexDiagram claimTerritory({double radius = 26}) => HexDiagram(
        radius: radius,
        caption: 'ANY HEX YOU MOVE ONTO BECOMES YOURS',
        cells: [
          const HexDiagramCell.herd(
              HexPosition(0, 0), PlayerColor.blue, 5,
              isSelected: true),
          const HexDiagramCell(HexPosition(1, 0), isValidMove: true),
          const HexDiagramCell(HexPosition(2, 0), isValidMove: true),
          const HexDiagramCell(HexPosition(3, 0), isValidMove: true),
        ],
        arrows: [
          const HexDiagramArrow(HexPosition(0, 0), HexPosition(2, 0)),
        ],
        badges: [
          const HexDiagramBadge(
            HexPosition(2, 0),
            'YOURS!',
            color: AppColors.blue,
            slot: HexBadgeSlot.bottom,
          ),
        ],
      );

  /// Step 8 - landing on an enemy hex overruns their herd.
  static HexDiagram overrunHerd({double radius = 26}) => HexDiagram(
        radius: radius,
        caption: 'LAND ON AN ENEMY HERD TO OVERRUN AND CAPTURE IT',
        cells: [
          const HexDiagramCell.herd(
              HexPosition(0, 0), PlayerColor.blue, 11,
              isSelected: true),
          const HexDiagramCell(HexPosition(1, 0), isValidMove: true),
          const HexDiagramCell.herd(HexPosition(2, 0), PlayerColor.red, 8,
              isValidMove: true),
          const HexDiagramCell(HexPosition(1, 1), isValidMove: true),
          const HexDiagramCell(HexPosition(2, 1), isValidMove: true),
        ],
        arrows: [
          const HexDiagramArrow(HexPosition(0, 0), HexPosition(2, 0)),
        ],
        badges: [
          const HexDiagramBadge(
            HexPosition(2, 0),
            '+8 CAPTURED',
            color: AppColors.timerRed,
            slot: HexBadgeSlot.bottom,
          ),
        ],
      );

  /// Fence Battle - placing one of the 3 fences on an empty hex.
  static HexDiagram fencePlacement({double radius = 26}) => HexDiagram(
        radius: radius,
        caption: '3 FENCES EACH - BLOCK HEXES OR TRAP A HERD IN A CORNER',
        cells: [
          const HexDiagramCell.herd(
              HexPosition(-1, 0), PlayerColor.blue, 10,
              isSelected: true),
          const HexDiagramCell(
            HexPosition(0, 0),
            specialAsset: 'assets/images/Board Tiles/tile_fence_gate.png',
          ),
          const HexDiagramCell.herd(HexPosition(1, 0), PlayerColor.red, 6),
          const HexDiagramCell(HexPosition(1, 1), isValidMove: true),
          const HexDiagramCell(
            HexPosition(0, 1),
            specialAsset: 'assets/images/Board Tiles/tile_fence_gate.png',
          ),
          const HexDiagramCell(HexPosition(0, 2), isValidMove: true),
          const HexDiagramCell.herd(HexPosition(-1, 1), PlayerColor.blue, 4),
        ],
      );

  /// The diagram for a numbered guide step; step 1 and the MODES tab have
  /// menu-driven content, so they reuse the tile-drop illustration.
  static HexDiagram forStep(int number, {double radius = 26}) {
    switch (number) {
      case 2:
        return tileDrop(radius: radius);
      case 3:
        return herdPlacement(radius: radius);
      case 4:
        return selectHerd(radius: radius);
      case 5:
        return splitHerd(radius: radius);
      case 6:
        return blockedLane(radius: radius);
      case 7:
        return claimTerritory(radius: radius);
      case 8:
        return overrunHerd(radius: radius);
      default:
        return tileDrop(radius: radius);
    }
  }
}