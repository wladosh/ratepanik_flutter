class DbRoom {
  final String id;
  final String code;
  final String status; // lobby | playing | finished
  final int currentQuestionIndex;
  final List<dynamic> questionIds;
  final int currentBlockIndex;
  final int totalBlocks;
  final String? hostUserId;
  final bool themeVoteActive;
  final Map<String, dynamic>? settings;
  final String createdAt;
  final String updatedAt;

  DbRoom({
    required this.id,
    required this.code,
    required this.status,
    required this.currentQuestionIndex,
    required this.questionIds,
    required this.currentBlockIndex,
    required this.totalBlocks,
    this.hostUserId,
    required this.themeVoteActive,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DbRoom.fromJson(Map<String, dynamic> json) => DbRoom(
        id: json['id'] as String,
        code: json['code'] as String,
        status: json['status'] as String? ?? 'lobby',
        currentQuestionIndex: json['current_question_index'] as int? ?? 0,
        questionIds: json['question_ids'] as List<dynamic>? ?? [],
        currentBlockIndex: json['current_block_index'] as int? ?? 0,
        totalBlocks: json['total_blocks'] as int? ?? 4,
        hostUserId: json['host_user_id'] as String?,
        themeVoteActive: json['theme_vote_active'] as bool? ?? false,
        settings: json['settings'] as Map<String, dynamic>?,
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
      );

  DbRoom copyWith({
    String? status,
    int? currentBlockIndex,
    int? totalBlocks,
    bool? themeVoteActive,
    Map<String, dynamic>? settings,
    String? updatedAt,
  }) =>
      DbRoom(
        id: id,
        code: code,
        status: status ?? this.status,
        currentQuestionIndex: currentQuestionIndex,
        questionIds: questionIds,
        currentBlockIndex: currentBlockIndex ?? this.currentBlockIndex,
        totalBlocks: totalBlocks ?? this.totalBlocks,
        hostUserId: hostUserId,
        themeVoteActive: themeVoteActive ?? this.themeVoteActive,
        settings: settings ?? this.settings,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class DbPlayer {
  final String id;
  final String roomId;
  final String? userId;
  final String displayName;
  final int score;
  final bool isHost;
  final String lastSeenAt;
  final String createdAt;

  DbPlayer({
    required this.id,
    required this.roomId,
    this.userId,
    required this.displayName,
    required this.score,
    required this.isHost,
    required this.lastSeenAt,
    required this.createdAt,
  });

  factory DbPlayer.fromJson(Map<String, dynamic> json) => DbPlayer(
        id: json['id'] as String,
        roomId: json['room_id'] as String,
        userId: json['user_id'] as String?,
        displayName: json['display_name'] as String? ?? '',
        score: json['score'] as int? ?? 0,
        isHost: json['is_host'] as bool? ?? false,
        lastSeenAt: json['last_seen_at'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
      );
}

class DbMatchBlock {
  final String id;
  final String roomId;
  final int blockIndex;
  final String mode; // number_guess | pick_correct | find_lie | order_it
  final String? themeId;
  final List<String>? themeOptions;
  final List<String> promptIds;
  final int currentRound;
  final int roundsTotal;
  final int? timerSeconds;
  final bool isComplete;
  final String? startedAt;
  final String? finishedAt;
  final String createdAt;

  DbMatchBlock({
    required this.id,
    required this.roomId,
    required this.blockIndex,
    required this.mode,
    this.themeId,
    this.themeOptions,
    required this.promptIds,
    required this.currentRound,
    required this.roundsTotal,
    this.timerSeconds,
    required this.isComplete,
    this.startedAt,
    this.finishedAt,
    required this.createdAt,
  });

  factory DbMatchBlock.fromJson(Map<String, dynamic> json) => DbMatchBlock(
        id: json['id'] as String,
        roomId: json['room_id'] as String,
        blockIndex: json['block_index'] as int? ?? 0,
        mode: json['mode'] as String? ?? 'number_guess',
        themeId: json['theme_id'] as String?,
        themeOptions: (json['theme_options'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        promptIds: (json['prompt_ids'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        currentRound: json['current_round'] as int? ?? 0,
        roundsTotal: json['rounds_total'] as int? ?? 2,
        timerSeconds: json['timer_seconds'] as int?,
        isComplete: json['is_complete'] as bool? ?? false,
        startedAt: json['started_at'] as String?,
        finishedAt: json['finished_at'] as String?,
        createdAt: json['created_at'] as String? ?? '',
      );
}

class DbAnswer {
  final String id;
  final String roomId;
  final String playerId;
  final int questionIndex;
  final int choiceIndex;
  final bool? isCorrect;
  final String answeredAt;
  final int? blockIndex;
  final int? roundIndex;
  final String? promptId;
  final String? mode;
  final double? numericAnswer;
  final dynamic payloadAnswer;
  final double? distance;
  final int? rank;
  final int pointsAwarded;

  DbAnswer({
    required this.id,
    required this.roomId,
    required this.playerId,
    required this.questionIndex,
    required this.choiceIndex,
    this.isCorrect,
    required this.answeredAt,
    this.blockIndex,
    this.roundIndex,
    this.promptId,
    this.mode,
    this.numericAnswer,
    this.payloadAnswer,
    this.distance,
    this.rank,
    required this.pointsAwarded,
  });

  factory DbAnswer.fromJson(Map<String, dynamic> json) => DbAnswer(
        id: json['id'] as String,
        roomId: json['room_id'] as String,
        playerId: json['player_id'] as String,
        questionIndex: json['question_index'] as int? ?? 0,
        choiceIndex: json['choice_index'] as int? ?? -1,
        isCorrect: json['is_correct'] as bool?,
        answeredAt: json['answered_at'] as String? ?? '',
        blockIndex: json['block_index'] as int?,
        roundIndex: json['round_index'] as int?,
        promptId: json['prompt_id'] as String?,
        mode: json['mode'] as String?,
        numericAnswer: (json['numeric_answer'] as num?)?.toDouble(),
        payloadAnswer: json['payload_answer'],
        distance: (json['distance'] as num?)?.toDouble(),
        rank: json['rank'] as int?,
        pointsAwarded: json['points_awarded'] as int? ?? 0,
      );
}

class DbPickCorrectTurn {
  final String id;
  final String roomId;
  final int blockIndex;
  final String playerId;
  final int turnOrder;
  final int cardIndex;
  final bool isCorrect;
  final int? roundIndex;
  final String createdAt;

  DbPickCorrectTurn({
    required this.id,
    required this.roomId,
    required this.blockIndex,
    required this.playerId,
    required this.turnOrder,
    required this.cardIndex,
    required this.isCorrect,
    this.roundIndex,
    required this.createdAt,
  });

  factory DbPickCorrectTurn.fromJson(Map<String, dynamic> json) =>
      DbPickCorrectTurn(
        id: json['id'] as String,
        roomId: json['room_id'] as String,
        blockIndex: json['block_index'] as int? ?? 0,
        playerId: json['player_id'] as String,
        turnOrder: json['turn_order'] as int? ?? 0,
        cardIndex: json['card_index'] as int? ?? 0,
        isCorrect: json['is_correct'] as bool? ?? false,
        roundIndex: json['round_index'] as int?,
        createdAt: json['created_at'] as String? ?? '',
      );
}

class Prompt {
  final String id;
  final String themeId;
  final String mode;
  final String difficulty;
  final String prompt;
  final Map<String, dynamic> payload;

  Prompt({
    required this.id,
    required this.themeId,
    required this.mode,
    required this.difficulty,
    required this.prompt,
    required this.payload,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) => Prompt(
        id: json['id'] as String,
        themeId: json['theme_id'] as String,
        mode: json['mode'] as String,
        difficulty: json['difficulty'] as String? ?? 'mittel',
        prompt: json['prompt'] as String? ?? '',
        payload: json['payload'] as Map<String, dynamic>? ?? {},
      );
}

class QuizTheme {
  final String id;
  final String slug;
  final String nameDe;

  QuizTheme({required this.id, required this.slug, required this.nameDe});

  factory QuizTheme.fromJson(Map<String, dynamic> json) => QuizTheme(
        id: json['id'] as String,
        slug: json['slug'] as String? ?? '',
        nameDe: json['name_de'] as String? ?? '',
      );
}
