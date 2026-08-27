import 'dart:math';

typedef PlayableMode = String;
typedef ModeFilter = String;
typedef DifficultyFilter = String;
typedef ThemeMix = String;

class RoomSettings {
  final int v;
  final ThemeMix themeMix;
  final List<String> themeIds;
  final ModeFilter modeFilter;
  final DifficultyFilter difficulty;
  final String gameLength;
  final int blocks;
  final int questionsPerBlock;
  final bool timerEnabled;
  final int timerSeconds;
  final int revealHoldMs;
  final int maxPlayers;
  final bool allowGuests;
  final bool autoStart;

  const RoomSettings({
    this.v = 1,
    this.themeMix = 'random',
    this.themeIds = const [],
    this.modeFilter = 'all',
    this.difficulty = 'mix',
    this.gameLength = 'medium',
    this.blocks = 5,
    this.questionsPerBlock = 3,
    this.timerEnabled = true,
    this.timerSeconds = 30,
    this.revealHoldMs = 2000,
    this.maxPlayers = 4,
    this.allowGuests = true,
    this.autoStart = false,
  });

  static const defaultSettings = RoomSettings();

  Map<String, dynamic> toJson() => {
        'v': v,
        'themeMix': themeMix,
        'themeIds': themeIds,
        'modeFilter': modeFilter,
        'difficulty': difficulty,
        'gameLength': gameLength,
        'blocks': blocks,
        'questionsPerBlock': questionsPerBlock,
        'timerEnabled': timerEnabled,
        'timerSeconds': timerSeconds,
        'revealHoldMs': revealHoldMs,
        'maxPlayers': maxPlayers,
        'allowGuests': allowGuests,
        'autoStart': autoStart,
      };

  factory RoomSettings.fromJson(dynamic raw) {
    if (raw == null || raw is! Map<String, dynamic>) return defaultSettings;
    final src = raw;

    final themeIds = (src['themeIds'] as List<dynamic>?)
            ?.whereType<String>()
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];

    int parsedBlocks = _asInt(src['blocks'], 5);
    parsedBlocks = [1, 2, 3, 4, 5, 6].contains(parsedBlocks) ? parsedBlocks : 5;

    int parsedQuestions = _asInt(src['questionsPerBlock'], 3);
    parsedQuestions = [1, 2, 3, 4].contains(parsedQuestions) ? parsedQuestions : 3;

    final gl = _gameLengthPreset(
      src['gameLength'] as String? ?? _inferGameLength(parsedBlocks, parsedQuestions),
    );

    return RoomSettings(
      v: 1,
      themeMix: _asStringIn(src['themeMix'], ['random', 'manual'], 'random'),
      themeIds: themeIds,
      modeFilter: _asStringIn(src['modeFilter'],
          ['all', 'number_guess', 'pick_correct', 'find_lie', 'order_it'], 'all'),
      difficulty: _asStringIn(
          src['difficulty'], ['mix', 'leicht', 'mittel', 'schwer'], 'mix'),
      gameLength: gl['gameLength'] as String,
      blocks: gl['blocks'] as int,
      questionsPerBlock: gl['questionsPerBlock'] as int,
      timerEnabled: true,
      timerSeconds: _parseTimerSeconds(src['timerSeconds']),
      revealHoldMs: _asIntIn(src['revealHoldMs'], [500, 1000, 1500, 2000], 2000),
      maxPlayers: _asIntIn(src['maxPlayers'], [2, 3, 4], 4),
      allowGuests: src['allowGuests'] != false,
      autoStart: src['autoStart'] == true,
    );
  }

  List<String>? get allowedThemeIds =>
      themeMix == 'manual' && themeIds.isNotEmpty ? themeIds : null;
}

int _asInt(dynamic v, int fallback) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return fallback;
}

int _asIntIn(dynamic v, List<int> allowed, int fallback) {
  final n = _asInt(v, fallback);
  return allowed.contains(n) ? n : fallback;
}

String _asStringIn(dynamic v, List<String> allowed, String fallback) {
  if (v is String && allowed.contains(v)) return v;
  return fallback;
}

int _parseTimerSeconds(dynamic v) {
  const allowed = [20, 30, 45, 60];
  if (v is int && allowed.contains(v)) return v;
  if (v is num) {
    if (v <= 12) return 20;
    if (v <= 22) return 30;
    if (v <= 40) return 45;
    return 60;
  }
  return 30;
}

String _inferGameLength(int blocks, int qpb) {
  if (blocks >= 6 || blocks * qpb >= 16) return 'long';
  if (blocks <= 3 && qpb <= 2) return 'short';
  return 'medium';
}

Map<String, dynamic> _gameLengthPreset(String gl) {
  switch (gl) {
    case 'short':
      return {'gameLength': 'short', 'blocks': 3, 'questionsPerBlock': 2};
    case 'long':
      return {'gameLength': 'long', 'blocks': 6, 'questionsPerBlock': 4};
    default:
      return {'gameLength': 'medium', 'blocks': 5, 'questionsPerBlock': 3};
  }
}

int roundsForMode(String mode, int questionsPerBlock) => questionsPerBlock;

int timerSecondsForBlock(RoomSettings s) => s.timerSeconds;

int questionTimerMsFromBlock(int? timerSeconds) {
  if (timerSeconds != null && timerSeconds > 0) return timerSeconds * 1000;
  return 30000;
}

const allPlayableModes = ['number_guess', 'pick_correct', 'find_lie', 'order_it'];

List<String> generateBlockModes(int count, String filter) {
  final n = min(6, max(1, count));
  if (filter != 'all') return List.filled(n, filter);

  final rng = Random();
  final result = <String>[];
  while (result.length < n) {
    final pool = List<String>.from(allPlayableModes);
    for (var i = pool.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = pool[i];
      pool[i] = pool[j];
      pool[j] = tmp;
    }
    result.addAll(pool);
  }
  return result.sublist(0, n);
}
