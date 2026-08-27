import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_config.dart';
import '../models/db_models.dart';
import '../models/room_settings.dart';
import '../models/game_scoring.dart';

String _generateRoomCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = Random();
  return String.fromCharCodes(
    List.generate(6, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
  );
}

String generateGuestName() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = Random();
  final suffix = String.fromCharCodes(
    List.generate(4, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
  );
  return 'Gast-$suffix';
}

enum GamePhase {
  home,
  lobby,
  vsIntro,
  themePick,
  playingLoading,
  numberGuess,
  numberGuessWaiting,
  numberGuessReveal,
  findLie,
  findLieWaiting,
  findLieReveal,
  orderIt,
  orderItWaiting,
  orderItReveal,
  pickCorrect,
  blockScoreboard,
  final_,
}

class GameState {
  final GamePhase phase;
  final DbRoom? room;
  final List<DbPlayer> players;
  final List<DbMatchBlock> blocks;
  final List<DbAnswer> allAnswers;
  final List<DbPickCorrectTurn> turns;
  final String? myPlayerId;
  final List<Prompt> prompts;
  final List<Theme> themeOptions;
  final String? error;
  final String? notice;
  final bool wasKicked;
  final bool loading;
  final bool disconnected;

  const GameState({
    this.phase = GamePhase.home,
    this.room,
    this.players = const [],
    this.blocks = const [],
    this.allAnswers = const [],
    this.turns = const [],
    this.myPlayerId,
    this.prompts = const [],
    this.themeOptions = const [],
    this.error,
    this.notice,
    this.wasKicked = false,
    this.loading = false,
    this.disconnected = false,
  });

  bool get isHost {
    if (myPlayerId == null) return false;
    return players.any((p) => p.id == myPlayerId && p.isHost);
  }

  DbMatchBlock? get currentBlock {
    if (room == null) return null;
    try {
      return blocks.firstWhere(
        (b) => b.blockIndex == room!.currentBlockIndex,
      );
    } catch (_) {
      return null;
    }
  }

  Prompt? get currentPrompt {
    final block = currentBlock;
    if (block == null || prompts.isEmpty) return null;
    if (block.currentRound >= prompts.length) return null;
    final raw = prompts[block.currentRound];
    if (raw.mode != block.mode) return null;
    return raw;
  }

  List<DbAnswer> get roundAnswers {
    final block = currentBlock;
    if (block == null) return [];
    return allAnswers
        .where((a) =>
            a.blockIndex == block.blockIndex &&
            a.roundIndex == block.currentRound)
        .toList();
  }

  List<DbAnswer> get allBlockAnswers {
    final block = currentBlock;
    if (block == null) return [];
    return allAnswers.where((a) => a.blockIndex == block.blockIndex).toList();
  }

  List<DbPlayer> get sortedPlayers => List<DbPlayer>.from(players)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  String? get themePickerPlayerId {
    if (room == null || sortedPlayers.isEmpty) return null;
    return sortedPlayers[room!.currentBlockIndex % sortedPlayers.length].id;
  }

  bool get isThemePicker => themePickerPlayerId == myPlayerId;

  List<DbPickCorrectTurn> get blockTurns {
    final block = currentBlock;
    if (block == null) return [];
    final round = block.currentRound;
    return turns
        .where((t) =>
            t.blockIndex == block.blockIndex && (t.roundIndex ?? 0) == round)
        .toList()
      ..sort((a, b) => a.turnOrder.compareTo(b.turnOrder));
  }

  int get correctTurnsCount => blockTurns.where((t) => t.isCorrect).length;

  int? get questionTimerMs {
    final block = currentBlock;
    if (block == null) return null;
    return questionTimerMsFromBlock(block.timerSeconds);
  }

  RoomSettings get roomSettings => RoomSettings.fromJson(room?.settings);

  GameState copyWith({
    GamePhase? phase,
    DbRoom? room,
    bool clearRoom = false,
    List<DbPlayer>? players,
    List<DbMatchBlock>? blocks,
    List<DbAnswer>? allAnswers,
    List<DbPickCorrectTurn>? turns,
    String? myPlayerId,
    bool clearMyPlayerId = false,
    List<Prompt>? prompts,
    List<Theme>? themeOptions,
    String? error,
    bool clearError = false,
    String? notice,
    bool clearNotice = false,
    bool? wasKicked,
    bool? loading,
    bool? disconnected,
  }) =>
      GameState(
        phase: phase ?? this.phase,
        room: clearRoom ? null : (room ?? this.room),
        players: players ?? this.players,
        blocks: blocks ?? this.blocks,
        allAnswers: allAnswers ?? this.allAnswers,
        turns: turns ?? this.turns,
        myPlayerId:
            clearMyPlayerId ? null : (myPlayerId ?? this.myPlayerId),
        prompts: prompts ?? this.prompts,
        themeOptions: themeOptions ?? this.themeOptions,
        error: clearError ? null : (error ?? this.error),
        notice: clearNotice ? null : (notice ?? this.notice),
        wasKicked: wasKicked ?? this.wasKicked,
        loading: loading ?? this.loading,
        disconnected: disconnected ?? this.disconnected,
      );
}

class GameService extends ChangeNotifier {
  GameState _state = const GameState();
  GameState get state => _state;

  RealtimeChannel? _channel;
  Timer? _errorTimer;
  Timer? _noticeTimer;
  Timer? _roundTimerTimeout;
  bool _roundTimedOut = false;

  void _emit(GameState s) {
    _state = _computePhase(s);
    notifyListeners();
  }

  GameState _computePhase(GameState s) {
    final room = s.room;
    if (room == null) return s.copyWith(phase: GamePhase.home);
    if (room.status == 'lobby') return s.copyWith(phase: GamePhase.lobby);
    if (room.status == 'finished') return s.copyWith(phase: GamePhase.final_);

    if (room.themeVoteActive) return s.copyWith(phase: GamePhase.themePick);

    final block = s.currentBlock;
    if (block == null) return s.copyWith(phase: GamePhase.playingLoading);

    if (block.isComplete) return s.copyWith(phase: GamePhase.blockScoreboard);

    if (block.mode == 'number_guess') {
      final roundOver = _roundTimedOut ||
          (s.players.isNotEmpty &&
              s.roundAnswers.length >= s.players.length);
      if (roundOver) return s.copyWith(phase: GamePhase.numberGuessReveal);
      final myAnswer =
          s.roundAnswers.any((a) => a.playerId == s.myPlayerId);
      return s.copyWith(
          phase: myAnswer
              ? GamePhase.numberGuessWaiting
              : GamePhase.numberGuess);
    }

    if (block.mode == 'find_lie') {
      final roundOver = _roundTimedOut ||
          (s.players.isNotEmpty &&
              s.roundAnswers.length >= s.players.length);
      if (roundOver) return s.copyWith(phase: GamePhase.findLieReveal);
      final myAnswer =
          s.roundAnswers.any((a) => a.playerId == s.myPlayerId);
      return s.copyWith(
          phase:
              myAnswer ? GamePhase.findLieWaiting : GamePhase.findLie);
    }

    if (block.mode == 'order_it') {
      final roundOver = _roundTimedOut ||
          (s.players.isNotEmpty &&
              s.roundAnswers.length >= s.players.length);
      if (roundOver) return s.copyWith(phase: GamePhase.orderItReveal);
      final myAnswer =
          s.roundAnswers.any((a) => a.playerId == s.myPlayerId);
      return s.copyWith(
          phase:
              myAnswer ? GamePhase.orderItWaiting : GamePhase.orderIt);
    }

    if (block.mode == 'pick_correct') {
      return s.copyWith(phase: GamePhase.pickCorrect);
    }

    return s.copyWith(phase: GamePhase.playingLoading);
  }

  void _setError(String? err) {
    _errorTimer?.cancel();
    _emit(_state.copyWith(error: err, clearError: err == null));
    if (err != null && _state.room != null) {
      _errorTimer = Timer(const Duration(seconds: 5), () {
        _emit(_state.copyWith(clearError: true));
      });
    }
  }

  void _setNotice(String? n) {
    _noticeTimer?.cancel();
    _emit(_state.copyWith(notice: n, clearNotice: n == null));
    if (n != null) {
      _noticeTimer = Timer(const Duration(seconds: 5), () {
        _emit(_state.copyWith(clearNotice: true));
      });
    }
  }

  // ── Realtime ──

  void _subscribeToRoom(String roomId) {
    _channel?.unsubscribe();

    final channel = supabase
        .channel('room-$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'rooms',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: roomId,
          ),
          callback: (payload) {
            if (payload.eventType == PostgresChangeEvent.update ||
                payload.eventType == PostgresChangeEvent.insert) {
              final room = DbRoom.fromJson(payload.newRecord);
              _emit(_state.copyWith(room: room));
              _onRoomChanged(room);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'players',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            if (payload.eventType == PostgresChangeEvent.insert) {
              final p = DbPlayer.fromJson(payload.newRecord);
              if (!_state.players.any((e) => e.id == p.id)) {
                _emit(_state.copyWith(players: [..._state.players, p]));
              }
            } else if (payload.eventType == PostgresChangeEvent.update) {
              final p = DbPlayer.fromJson(payload.newRecord);
              _emit(_state.copyWith(
                players: _state.players
                    .map((e) => e.id == p.id ? p : e)
                    .toList(),
              ));
            } else if (payload.eventType == PostgresChangeEvent.delete) {
              final leftId = payload.oldRecord['id'] as String?;
              if (leftId == _state.myPlayerId) {
                _emit(const GameState(wasKicked: true));
                _setNotice('Du wurdest aus dem Raum entfernt.');
                _channel?.unsubscribe();
                _channel = null;
              } else if (leftId != null) {
                final leftPlayer = _state.players
                    .where((p) => p.id == leftId)
                    .firstOrNull;
                _emit(_state.copyWith(
                  players:
                      _state.players.where((p) => p.id != leftId).toList(),
                ));
                if (leftPlayer != null) {
                  _setNotice('${leftPlayer.displayName} hat den Raum verlassen.');
                }
              }
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'match_blocks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            if (payload.eventType == PostgresChangeEvent.insert) {
              final b = DbMatchBlock.fromJson(payload.newRecord);
              if (!_state.blocks.any((e) => e.id == b.id)) {
                _emit(_state.copyWith(blocks: [..._state.blocks, b]));
              }
            } else if (payload.eventType == PostgresChangeEvent.update) {
              final b = DbMatchBlock.fromJson(payload.newRecord);
              _emit(_state.copyWith(
                blocks:
                    _state.blocks.map((e) => e.id == b.id ? b : e).toList(),
              ));
              _onBlockChanged(b);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'answers',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            final a = DbAnswer.fromJson(payload.newRecord);
            if (!_state.allAnswers.any((e) => e.id == a.id)) {
              _emit(
                  _state.copyWith(allAnswers: [..._state.allAnswers, a]));
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'answers',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            final a = DbAnswer.fromJson(payload.newRecord);
            _emit(_state.copyWith(
              allAnswers:
                  _state.allAnswers.map((e) => e.id == a.id ? a : e).toList(),
            ));
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'pick_correct_turns',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            final t = DbPickCorrectTurn.fromJson(payload.newRecord);
            if (!_state.turns.any((e) => e.id == t.id)) {
              _emit(_state.copyWith(turns: [..._state.turns, t]));
            }
          },
        )
        .subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        _emit(_state.copyWith(disconnected: false));
      } else if (status == RealtimeSubscribeStatus.channelError ||
          status == RealtimeSubscribeStatus.timedOut) {
        _emit(_state.copyWith(disconnected: true));
        Future.delayed(const Duration(seconds: 2), () {
          _channel?.unsubscribe();
          _subscribeToRoom(roomId);
          _refetchAll(roomId);
        });
      }
    });

    _channel = channel;
  }

  Future<void> _refetchAll(String roomId) async {
    final results = await Future.wait([
      supabase.from('rooms').select().eq('id', roomId).single(),
      supabase.from('players').select().eq('room_id', roomId),
      supabase.from('answers').select().eq('room_id', roomId),
      supabase.from('match_blocks').select().eq('room_id', roomId),
      supabase.from('pick_correct_turns').select().eq('room_id', roomId),
    ]);
    final roomData = results[0] as Map<String, dynamic>;
    final playersData = results[1] as List<dynamic>;
    final answersData = results[2] as List<dynamic>;
    final blocksData = results[3] as List<dynamic>;
    final turnsData = results[4] as List<dynamic>;

    _emit(_state.copyWith(
      room: DbRoom.fromJson(roomData),
      players: playersData.map((e) => DbPlayer.fromJson(e)).toList(),
      allAnswers: answersData.map((e) => DbAnswer.fromJson(e)).toList(),
      blocks: blocksData.map((e) => DbMatchBlock.fromJson(e)).toList(),
      turns: turnsData.map((e) => DbPickCorrectTurn.fromJson(e)).toList(),
    ));
  }

  void _onRoomChanged(DbRoom room) {
    if (room.status == 'playing' && room.themeVoteActive) {
      _loadThemeOptions();
    }
  }

  void _onBlockChanged(DbMatchBlock block) {
    if (block.themeId != null && block.promptIds.isNotEmpty) {
      _loadPrompts(block.promptIds);
    }
    _resetRoundTimer();
  }

  void _resetRoundTimer() {
    _roundTimerTimeout?.cancel();
    _roundTimedOut = false;
    final block = _state.currentBlock;
    if (block == null || block.startedAt == null || block.isComplete) return;

    final timerMs = questionTimerMsFromBlock(block.timerSeconds);
    final endMs =
        DateTime.parse(block.startedAt!).millisecondsSinceEpoch + timerMs;
    final remaining = endMs - DateTime.now().millisecondsSinceEpoch;

    if (remaining <= 0) {
      _roundTimedOut = true;
      _emit(_state);
      return;
    }

    _roundTimerTimeout = Timer(Duration(milliseconds: remaining), () {
      _roundTimedOut = true;
      _emit(_state);
    });
  }

  Future<void> _loadPrompts(List<String> promptIds) async {
    final resp = await supabase
        .from('prompts')
        .select('id, theme_id, mode, difficulty, prompt, payload')
        .inFilter('id', promptIds);
    final data = resp as List<dynamic>;
    final ordered = promptIds
        .map((pid) => data.firstWhere(
              (p) => p['id'] == pid,
              orElse: () => null,
            ))
        .where((p) => p != null)
        .map((p) => Prompt.fromJson(p))
        .toList();
    _emit(_state.copyWith(prompts: ordered));
  }

  Future<void> _loadThemeOptions() async {
    final block = _state.currentBlock;
    if (block == null || block.themeOptions == null) return;
    final resp = await supabase
        .from('themes')
        .select('id, slug, name_de')
        .inFilter('id', block.themeOptions!);
    final data = resp as List<dynamic>;
    _emit(_state.copyWith(
        themeOptions: data.map((e) => Theme.fromJson(e)).toList()));
  }

  // ── Actions ──

  Future<String?> createRoom(String hostName, String hostUserId) async {
    _emit(_state.copyWith(loading: true, clearError: true));
    try {
      final code = _generateRoomCode();
      final settings = RoomSettings.defaultSettings.toJson();

      var resp = await supabase
          .from('rooms')
          .insert({
            'code': code,
            'host_user_id': hostUserId,
            'settings': settings,
            'total_blocks': RoomSettings.defaultSettings.blocks,
          })
          .select()
          .single();

      final roomData = DbRoom.fromJson(resp);

      final playerResp = await supabase
          .from('players')
          .insert({
            'room_id': roomData.id,
            'user_id': hostUserId,
            'display_name': hostName,
            'is_host': true,
          })
          .select()
          .single();

      final player = DbPlayer.fromJson(playerResp);

      _emit(_state.copyWith(
        room: roomData,
        players: [player],
        myPlayerId: player.id,
        allAnswers: const [],
        blocks: const [],
        turns: const [],
        prompts: const [],
        loading: false,
      ));

      _subscribeToRoom(roomData.id);
      return roomData.code;
    } catch (e) {
      _setError('Raum konnte nicht erstellt werden.');
      _emit(_state.copyWith(loading: false));
      return null;
    }
  }

  Future<String?> joinRoom(String code, String displayName) async {
    _emit(_state.copyWith(loading: true, clearError: true));
    try {
      final uid = supabase.auth.currentUser?.id;
      final roomResp = await supabase
          .from('rooms')
          .select()
          .eq('code', code.toUpperCase().trim())
          .single();

      final roomData = DbRoom.fromJson(roomResp);

      if (roomData.status != 'lobby') {
        _setError('Dieses Spiel läuft bereits.');
        _emit(_state.copyWith(loading: false));
        return 'Dieses Spiel läuft bereits.';
      }

      final existingPlayersResp =
          await supabase.from('players').select().eq('room_id', roomData.id);
      final existingPlayers = (existingPlayersResp as List<dynamic>)
          .map((e) => DbPlayer.fromJson(e))
          .toList();

      final settings = RoomSettings.fromJson(roomData.settings);
      if (existingPlayers.length >= settings.maxPlayers) {
        _setError('Raum ist voll.');
        _emit(_state.copyWith(loading: false));
        return 'Raum ist voll.';
      }

      DbPlayer playerData;

      if (uid != null) {
        final existing = existingPlayers.where((p) => p.userId == uid).firstOrNull;
        if (existing != null) {
          final updated = await supabase
              .from('players')
              .update({
                'display_name': displayName,
                'last_seen_at': DateTime.now().toUtc().toIso8601String(),
              })
              .eq('id', existing.id)
              .select()
              .single();
          playerData = DbPlayer.fromJson(updated);
        } else {
          final inserted = await supabase
              .from('players')
              .insert({
                'room_id': roomData.id,
                'user_id': uid,
                'display_name': displayName,
                'is_host': false,
              })
              .select()
              .single();
          playerData = DbPlayer.fromJson(inserted);
        }
      } else {
        final freshUser = supabase.auth.currentUser;
        final inserted = await supabase
            .from('players')
            .insert({
              'room_id': roomData.id,
              'user_id': freshUser?.id,
              'display_name': displayName,
              'is_host': false,
            })
            .select()
            .single();
        playerData = DbPlayer.fromJson(inserted);
      }

      final allPlayersResp =
          await supabase.from('players').select().eq('room_id', roomData.id);

      _emit(_state.copyWith(
        room: roomData,
        players: (allPlayersResp as List<dynamic>)
            .map((e) => DbPlayer.fromJson(e))
            .toList(),
        myPlayerId: playerData.id,
        allAnswers: const [],
        blocks: const [],
        turns: const [],
        prompts: const [],
        loading: false,
      ));

      _subscribeToRoom(roomData.id);
      return null;
    } catch (e) {
      _setError('Raum nicht gefunden.');
      _emit(_state.copyWith(loading: false));
      return 'Raum nicht gefunden.';
    }
  }

  Future<void> startGame() async {
    final room = _state.room;
    if (room == null || !_state.isHost || room.status != 'lobby') return;

    final settings = _state.roomSettings;
    final modes =
        generateBlockModes(settings.blocks, settings.modeFilter);
    final timerSec = timerSecondsForBlock(settings);

    final blockInserts = modes.asMap().entries.map((e) {
      final i = e.key;
      final mode = e.value;
      final ts = mode == 'order_it' && timerSec > 0
          ? max(timerSec, (orderItTimerMs / 1000).round())
          : timerSec;
      return {
        'room_id': room.id,
        'block_index': i,
        'mode': mode,
        'rounds_total': roundsForMode(mode, settings.questionsPerBlock),
        'timer_seconds': ts,
      };
    }).toList();

    final blocksResp = await supabase
        .from('match_blocks')
        .insert(blockInserts)
        .select();
    final blocksData = (blocksResp as List<dynamic>)
        .map((e) => DbMatchBlock.fromJson(e))
        .toList();
    _emit(_state.copyWith(blocks: blocksData));

    if (blocksData.isNotEmpty) {
      await _prepareBlockTheme(blocksData[0].id, modes[0], settings);
    }

    await supabase.from('answers').delete().eq('room_id', room.id);
    await supabase.from('pick_correct_turns').delete().eq('room_id', room.id);
    await supabase.from('match_scores').delete().eq('room_id', room.id);
    await supabase
        .from('players')
        .update({'score': 0}).eq('room_id', room.id);

    await supabase.from('rooms').update({
      'status': 'playing',
      'current_block_index': 0,
      'total_blocks': settings.blocks,
      'theme_vote_active': true,
      'current_question_index': 0,
      'question_ids': <dynamic>[],
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', room.id);

    _emit(_state.copyWith(
        allAnswers: const [], turns: const []));
  }

  Future<void> _prepareBlockTheme(
      String blockId, String mode, RoomSettings settings) async {
    final allowed = settings.allowedThemeIds;

    var query = supabase
        .from('prompts')
        .select('theme_id')
        .eq('mode', mode)
        .eq('active', true);
    final promptRows = await query as List<dynamic>;
    final themeIds =
        promptRows.map((r) => r['theme_id'] as String).toSet().toList();

    var themesQuery = supabase
        .from('themes')
        .select('id, slug, name_de')
        .inFilter('id', themeIds);
    final themes = (await themesQuery as List<dynamic>)
        .map((e) => Theme.fromJson(e))
        .toList();

    var pool = allowed != null
        ? themes.where((t) => allowed.contains(t.id)).toList()
        : themes;

    if (pool.isEmpty) return;
    pool.shuffle();
    final options = pool.take(2).toList();

    await supabase
        .from('match_blocks')
        .update({'theme_options': options.map((t) => t.id).toList()}).eq(
            'id', blockId);
  }

  Future<void> selectTheme(String themeId) async {
    final room = _state.room;
    final block = _state.currentBlock;
    if (room == null || block == null || !_state.isThemePicker) return;

    final settings = _state.roomSettings;
    final count = roundsForMode(block.mode, settings.questionsPerBlock);

    final promptsResp = await supabase
        .from('prompts')
        .select('id, theme_id, mode, difficulty, prompt, payload')
        .eq('theme_id', themeId)
        .eq('mode', block.mode)
        .eq('active', true)
        .limit(count);
    var fetched = (promptsResp as List<dynamic>)
        .map((e) => Prompt.fromJson(e))
        .toList();
    fetched.shuffle();
    if (fetched.length > count) fetched = fetched.sublist(0, count);

    if (fetched.isEmpty) {
      _setError('Keine Fragen für dieses Thema verfügbar.');
      return;
    }

    final promptIds = fetched.map((p) => p.id).toList();

    await supabase.from('match_blocks').update({
      'theme_id': themeId,
      'prompt_ids': promptIds,
      'rounds_total': max(1, promptIds.length),
    }).eq('id', block.id);

    await supabase.from('rooms').update({
      'theme_vote_active': false,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', room.id);

    _emit(_state.copyWith(prompts: fetched));
  }

  Future<void> submitNumberGuess(double guess) async {
    final room = _state.room;
    final block = _state.currentBlock;
    final prompt = _state.currentPrompt;
    if (room == null ||
        _state.myPlayerId == null ||
        block == null ||
        prompt == null) return;

    await supabase.from('answers').insert({
      'room_id': room.id,
      'player_id': _state.myPlayerId,
      'block_index': block.blockIndex,
      'round_index': block.currentRound,
      'prompt_id': prompt.id,
      'mode': 'number_guess',
      'numeric_answer': guess,
      'question_index': room.currentBlockIndex * 10 + block.currentRound,
      'choice_index': -1,
    });
  }

  Future<void> submitFindLie(int lieIndex) async {
    final room = _state.room;
    final block = _state.currentBlock;
    final prompt = _state.currentPrompt;
    if (room == null ||
        _state.myPlayerId == null ||
        block == null ||
        prompt == null) return;

    await supabase.from('answers').insert({
      'room_id': room.id,
      'player_id': _state.myPlayerId,
      'block_index': block.blockIndex,
      'round_index': block.currentRound,
      'prompt_id': prompt.id,
      'mode': 'find_lie',
      'numeric_answer': lieIndex,
      'question_index': room.currentBlockIndex * 10 + block.currentRound,
      'choice_index': lieIndex,
    });
  }

  Future<void> submitOrderIt(List<int> order) async {
    final room = _state.room;
    final block = _state.currentBlock;
    final prompt = _state.currentPrompt;
    if (room == null ||
        _state.myPlayerId == null ||
        block == null ||
        prompt == null) return;

    await supabase.from('answers').insert({
      'room_id': room.id,
      'player_id': _state.myPlayerId,
      'block_index': block.blockIndex,
      'round_index': block.currentRound,
      'prompt_id': prompt.id,
      'mode': 'order_it',
      'payload_answer': order,
      'question_index': room.currentBlockIndex * 10 + block.currentRound,
      'choice_index': -1,
    });
  }

  Future<void> tapCard(int cardIndex) async {
    final room = _state.room;
    final block = _state.currentBlock;
    final prompt = _state.currentPrompt;
    if (room == null ||
        _state.myPlayerId == null ||
        block == null ||
        prompt == null) return;
    if (block.mode != 'pick_correct') return;
    if (_state.correctTurnsCount >= 4) return;
    if (_state.blockTurns.any((t) => t.cardIndex == cardIndex)) return;

    final payload = prompt.payload;
    final correctIndices = (payload['correct_indices'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];
    final isCorrect = correctIndices.contains(cardIndex);

    await supabase.from('pick_correct_turns').insert({
      'room_id': room.id,
      'block_index': block.blockIndex,
      'player_id': _state.myPlayerId,
      'turn_order': _state.blockTurns.length,
      'card_index': cardIndex,
      'is_correct': isCorrect,
      'round_index': block.currentRound,
    });
  }

  Future<void> advanceFromReveal() async {
    final room = _state.room;
    final block = _state.currentBlock;
    if (room == null || !_state.isHost || block == null) return;

    if (block.mode == 'number_guess') {
      await _scoreNumberGuessRound(block);
    } else if (block.mode == 'find_lie' || block.mode == 'order_it') {
      await _scoreSimultaneousRound(block);
    }

    final nextRound = block.currentRound + 1;
    if (nextRound < block.roundsTotal) {
      await supabase.from('match_blocks').update({
        'current_round': nextRound,
        'started_at': null,
      }).eq('id', block.id);
      _roundTimedOut = false;
    } else {
      await supabase.from('match_blocks').update({
        'is_complete': true,
        'finished_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', block.id);
    }
  }

  Future<void> _scoreNumberGuessRound(DbMatchBlock block) async {
    final prompt = _state.currentPrompt;
    if (prompt == null) return;
    final answer = prompt.payload['answer'];
    if (answer == null) return;
    final correct = (answer as num).toDouble();

    final answers = _state.roundAnswers;
    for (final a in answers) {
      final guess = a.numericAnswer ?? 0;
      final distance = (guess - correct).abs();
      await supabase
          .from('answers')
          .update({'distance': distance}).eq('id', a.id);
    }

    final sorted = List<DbAnswer>.from(answers)
      ..sort((a, b) {
        final da = ((a.numericAnswer ?? 0) - correct).abs();
        final db = ((b.numericAnswer ?? 0) - correct).abs();
        return da.compareTo(db);
      });

    for (var i = 0; i < sorted.length; i++) {
      final pts = numberGuessPointsForGroup(i, sorted.length);
      await supabase.from('answers').update({
        'points_awarded': pts,
        'rank': i + 1,
      }).eq('id', sorted[i].id);

      final latest = await supabase
          .from('players')
          .select('score')
          .eq('id', sorted[i].playerId)
          .single();
      await supabase.from('players').update({
        'score': (latest['score'] as int? ?? 0) + pts,
      }).eq('id', sorted[i].playerId);
    }
  }

  Future<void> _scoreSimultaneousRound(DbMatchBlock block) async {
    final prompt = _state.currentPrompt;
    if (prompt == null) return;
    final answers = _state.roundAnswers;

    for (final a in answers) {
      int pts = 0;
      if (block.mode == 'find_lie') {
        final lieIndex = prompt.payload['lie_index'] as int?;
        if (lieIndex != null && a.numericAnswer != null) {
          pts = calculateFindLiePoints(a.numericAnswer!.toInt(), lieIndex);
        }
      } else if (block.mode == 'order_it') {
        final correctOrder =
            (prompt.payload['correct_order'] as List<dynamic>?)
                    ?.map((e) => e as int)
                    .toList() ??
                [];
        final order = (a.payloadAnswer as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [];
        pts = calculateOrderItPoints(order, correctOrder);
      }

      await supabase
          .from('answers')
          .update({'points_awarded': pts}).eq('id', a.id);

      if (pts > 0) {
        final latest = await supabase
            .from('players')
            .select('score')
            .eq('id', a.playerId)
            .single();
        await supabase.from('players').update({
          'score': (latest['score'] as int? ?? 0) + pts,
        }).eq('id', a.playerId);
      }
    }
  }

  Future<void> advanceFromBlockScore() async {
    final room = _state.room;
    if (room == null || !_state.isHost) return;

    final nextBlockIndex = room.currentBlockIndex + 1;
    if (nextBlockIndex >= room.totalBlocks) {
      await supabase.from('rooms').update({
        'status': 'finished',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', room.id);
      return;
    }

    final nextBlock =
        _state.blocks.where((b) => b.blockIndex == nextBlockIndex).firstOrNull;
    if (nextBlock != null) {
      await _prepareBlockTheme(
          nextBlock.id, nextBlock.mode, _state.roomSettings);
    }

    await supabase.from('rooms').update({
      'current_block_index': nextBlockIndex,
      'theme_vote_active': true,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', room.id);

    _emit(_state.copyWith(prompts: const []));
  }

  Future<void> kickPlayer(String playerId) async {
    final room = _state.room;
    if (room == null || !_state.isHost || room.status != 'lobby') return;
    if (playerId == _state.myPlayerId) return;

    await supabase.rpc('kick_player', params: {
      'p_room_id': room.id,
      'p_player_id': playerId,
    });
  }

  Future<void> leaveRoom() async {
    final room = _state.room;
    if (room != null && _state.myPlayerId != null) {
      try {
        await supabase.rpc('leave_match', params: {'p_room_id': room.id});
      } catch (_) {
        await supabase
            .from('players')
            .delete()
            .eq('id', _state.myPlayerId!);
      }
    }
    goHome();
  }

  Future<void> resetGame() async {
    final room = _state.room;
    if (room == null) return;

    await supabase.from('answers').delete().eq('room_id', room.id);
    await supabase
        .from('pick_correct_turns')
        .delete()
        .eq('room_id', room.id);
    await supabase.from('match_scores').delete().eq('room_id', room.id);
    await supabase.from('match_blocks').delete().eq('room_id', room.id);
    await supabase
        .from('players')
        .update({'score': 0}).eq('room_id', room.id);
    await supabase.from('rooms').update({
      'status': 'lobby',
      'current_block_index': 0,
      'theme_vote_active': false,
      'current_question_index': 0,
      'question_ids': <dynamic>[],
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', room.id);

    _emit(_state.copyWith(
      allAnswers: const [],
      blocks: const [],
      turns: const [],
      prompts: const [],
      themeOptions: const [],
    ));
  }

  void goHome() {
    _channel?.unsubscribe();
    _channel = null;
    _roundTimerTimeout?.cancel();
    _roundTimedOut = false;
    _emit(const GameState());
  }

  /// Stamp started_at on the current block when the host sees the prompt.
  Future<void> stampQuestionClock() async {
    final block = _state.currentBlock;
    if (block == null || !_state.isHost || block.startedAt != null) return;
    if (_state.currentPrompt == null) return;

    final resp = await supabase
        .from('match_blocks')
        .update({'started_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', block.id)
        .isFilter('started_at', null)
        .select()
        .maybeSingle();

    if (resp != null) {
      final updated = DbMatchBlock.fromJson(resp);
      _emit(_state.copyWith(
        blocks: _state.blocks.map((b) => b.id == updated.id ? updated : b).toList(),
      ));
      _resetRoundTimer();
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _errorTimer?.cancel();
    _noticeTimer?.cancel();
    _roundTimerTimeout?.cancel();
    super.dispose();
  }
}
