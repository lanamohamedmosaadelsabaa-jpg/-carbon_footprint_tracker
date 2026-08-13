import 'carbon_calculator.dart';

class GamificationService {
  static const List<Map<String, dynamic>> badgeDefinitions = [
    {'id': 'first_log', 'name': 'First Step', 'description': 'Logged your first day'},
    {'id': 'streak_7', 'name': 'Week Warrior', 'description': '7-day logging streak'},
    {'id': 'streak_30', 'name': 'Habit Builder', 'description': '30-day logging streak'},
    {'id': 'points_100', 'name': 'Eco Rookie', 'description': 'Earned 100+ points'},
    {'id': 'points_500', 'name': 'Eco Champion', 'description': 'Earned 500+ points'},
  ];

  /// Points for one day's logged choices — lower-carbon choices earn more.
  static int calculatePoints({
    required String transportChoice,
    required String dietChoice,
  }) {
    int base = 10;
    base += _rankPoints(CarbonCalculator.transport, transportChoice);
    base += _rankPoints(CarbonCalculator.dailyDiet, dietChoice);
    return base;
  }

  static int _rankPoints(Map<String, double> options, String choice) {
    final sorted = options.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    final index = sorted.indexWhere((e) => e.key == choice);
    if (index == -1) return 0;
    return (sorted.length - index) * 5;
  }

  /// Returns the updated streak and whether today was already logged.
  static Map<String, dynamic> updateStreak(String? lastLogDate, int currentStreak) {
    final today = DateTime.now();
    final todayStr = _formatDate(today);
    final yesterdayStr = _formatDate(today.subtract(const Duration(days: 1)));

    if (lastLogDate == todayStr) {
      return {'streak': currentStreak, 'alreadyLoggedToday': true};
    }
    if (lastLogDate == yesterdayStr) {
      return {'streak': currentStreak + 1, 'alreadyLoggedToday': false};
    }
    return {'streak': 1, 'alreadyLoggedToday': false};
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static List<String> checkNewBadges({
    required int totalPoints,
    required int streak,
    required bool isFirstLog,
    required List<String> earnedBadges,
  }) {
    final newBadges = <String>[];
    if (isFirstLog && !earnedBadges.contains('first_log')) newBadges.add('first_log');
    if (streak >= 7 && !earnedBadges.contains('streak_7')) newBadges.add('streak_7');
    if (streak >= 30 && !earnedBadges.contains('streak_30')) newBadges.add('streak_30');
    if (totalPoints >= 100 && !earnedBadges.contains('points_100')) newBadges.add('points_100');
    if (totalPoints >= 500 && !earnedBadges.contains('points_500')) newBadges.add('points_500');
    return newBadges;
  }
}