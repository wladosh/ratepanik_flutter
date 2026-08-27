import 'dart:math';

const questionTimerMs = 30000;
const orderItTimerMs = 30000;
const findLieCorrectPoints = 400;
const orderItPointsPerSlot = 100;
const numberGuessFirstPoints = 400;

int questionTimerMsForMode(String? mode) =>
    mode == 'order_it' ? orderItTimerMs : questionTimerMs;

String modeLabelDe(String? mode) {
  switch (mode) {
    case 'number_guess':
      return 'Schätzen';
    case 'pick_correct':
      return 'Passend';
    case 'find_lie':
      return 'Lüge';
    case 'order_it':
      return 'Reihenfolge';
    default:
      return mode ?? '';
  }
}

String modeEmoji(String? mode) {
  switch (mode) {
    case 'number_guess':
      return '🔢';
    case 'pick_correct':
      return '🃏';
    case 'find_lie':
      return '🤥';
    case 'order_it':
      return '↕️';
    default:
      return '';
  }
}

int numberGuessPointsForGroup(int groupIndex, int groupCount) {
  if (groupCount <= 0 || groupIndex < 0 || groupIndex >= groupCount) return 0;
  if (groupCount == 1) return numberGuessFirstPoints;
  if (groupIndex >= groupCount - 1) return 0;
  return (numberGuessFirstPoints / pow(2, groupIndex)).round();
}

int calculatePickCorrectPoints(int correctFound, [int totalCorrect = 4]) {
  if (totalCorrect <= 0) return 0;
  return (correctFound / totalCorrect * 1000).round();
}

int calculateFindLiePoints(int choice, int lieIndex) {
  return choice == lieIndex ? findLieCorrectPoints : 0;
}

int calculateOrderItPoints(List<int> playerOrder, List<int> correctOrder) {
  final n = min(playerOrder.length, correctOrder.length);
  var pts = 0;
  for (var i = 0; i < n; i++) {
    if (playerOrder[i] == correctOrder[i]) pts += orderItPointsPerSlot;
  }
  return pts;
}
