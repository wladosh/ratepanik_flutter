import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ratepanik/l10n/rp_strings.dart';
import 'package:ratepanik/models/room_settings.dart';
import 'package:ratepanik/models/game_scoring.dart';
import 'package:ratepanik/services/game_service.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('RoomSettings', () {
    test('parses default settings from null', () {
      final s = RoomSettings.fromJson(null);
      expect(s.blocks, 5);
      expect(s.questionsPerBlock, 3);
      expect(s.timerSeconds, 30);
      expect(s.maxPlayers, 4);
      expect(s.allowGuests, true);
      expect(s.modeFilter, 'all');
    });

    test('parses settings from map', () {
      final s = RoomSettings.fromJson({
        'v': 1,
        'blocks': 3,
        'questionsPerBlock': 2,
        'timerSeconds': 45,
        'maxPlayers': 2,
        'gameLength': 'short',
        'modeFilter': 'number_guess',
      });
      expect(s.blocks, 3);
      expect(s.questionsPerBlock, 2);
      expect(s.timerSeconds, 45);
      expect(s.maxPlayers, 2);
      expect(s.modeFilter, 'number_guess');
    });
  });

  group('Game scoring', () {
    test('pick_correct scoring', () {
      expect(calculatePickCorrectPoints(4), 1000);
      expect(calculatePickCorrectPoints(2), 500);
      expect(calculatePickCorrectPoints(0), 0);
    });

    test('find_lie scoring', () {
      expect(calculateFindLiePoints(2, 2), 400);
      expect(calculateFindLiePoints(0, 2), 0);
    });

    test('order_it scoring', () {
      expect(calculateOrderItPoints([0, 1, 2, 3], [0, 1, 2, 3]), 400);
      expect(calculateOrderItPoints([3, 2, 1, 0], [0, 1, 2, 3]), 0);
      expect(calculateOrderItPoints([0, 1, 3, 2], [0, 1, 2, 3]), 200);
    });

    test('number guess points for group', () {
      expect(numberGuessPointsForGroup(0, 3), 400);
      expect(numberGuessPointsForGroup(1, 3), 200);
      expect(numberGuessPointsForGroup(2, 3), 0);
    });
  });

  group('GameState', () {
    test('initial state is home phase', () {
      const state = GameState();
      expect(state.phase, GamePhase.home);
      expect(state.isHost, false);
      expect(state.room, null);
    });
  });

  group('Utility', () {
    test('generateGuestName produces Gast- prefix', () {
      final name = generateGuestName();
      expect(name.startsWith('Gast-'), true);
      expect(name.length, 9);
    });

    test('generateBlockModes produces correct count', () {
      final modes = generateBlockModes(4, 'all');
      expect(modes.length, 4);
      for (final m in modes) {
        expect(allPlayableModes.contains(m), true);
      }
    });

    test('generateBlockModes single filter', () {
      final modes = generateBlockModes(3, 'number_guess');
      expect(modes.length, 3);
      expect(modes.every((m) => m == 'number_guess'), true);
    });
  });

  group('RpStrings', () {
    test('key strings are non-empty', () {
      expect(RpStrings.appName.isNotEmpty, true);
      expect(RpStrings.homeCreateTitle.isNotEmpty, true);
      expect(RpStrings.lobbyStart.isNotEmpty, true);
    });
  });
}
