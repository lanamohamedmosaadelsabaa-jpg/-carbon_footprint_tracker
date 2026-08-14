import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeItem {
  final String id;
  final String name;
  final String icon;
  final String description;

  const BadgeItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
}

class GamificationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const List<BadgeItem> allBadges = [
    BadgeItem(id: 'first_steps', name: 'First Steps', icon: '🌱', description: 'Complete onboarding'),
    BadgeItem(id: 'streak_3', name: '3-Day Streak', icon: '🔥', description: 'Log actions 3 days in a row'),
    BadgeItem(id: 'streak_7', name: '7-Day Streak', icon: '⚡', description: 'Log actions 7 days in a row'),
    BadgeItem(id: 'curious_mind', name: 'Curious Mind', icon: '💬', description: 'Ask the AI chatbot 5 questions'),
    BadgeItem(id: 'sdg_champion', name: 'SDG Champion', icon: '🏆', description: 'Reach 500 total points'),
  ];

  static Future<void> addPoints(String uid, int pointsEarned, String actionType) async {
    final userRef = _db.collection('users').doc(uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) return;

    final data = userDoc.data()!;
    int currentPoints = data['totalPoints'] ?? 0;
    int currentStreak = data['currentStreak'] ?? 0;
    int longestStreak = data['longestStreak'] ?? 0;
    List<String> userBadges = List<String>.from(data['badges'] ?? []);

    DateTime now = DateTime.now();
    DateTime? lastLog = (data['lastLogDate'] as Timestamp?)?.toDate();

    if (lastLog == null) {
      currentStreak = 1;
    } else {
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastLog.year, lastLog.month, lastLog.day))
          .inDays;

      if (difference == 1) {
        currentStreak += 1;
      } else if (difference > 1) {
        currentStreak = 1;
      }
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    int newPoints = currentPoints + pointsEarned;

    if (!userBadges.contains('first_steps') && actionType == 'onboarding') {
      userBadges.add('first_steps');
    }
    if (!userBadges.contains('streak_3') && currentStreak >= 3) {
      userBadges.add('streak_3');
    }
    if (!userBadges.contains('streak_7') && currentStreak >= 7) {
      userBadges.add('streak_7');
    }
    if (!userBadges.contains('sdg_champion') && newPoints >= 500) {
      userBadges.add('sdg_champion');
    }

    await userRef.update({
      'totalPoints': newPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastLogDate': FieldValue.serverTimestamp(),
      'badges': userBadges,
    });

    await userRef.collection('activityLog').add({
      'type': actionType,
      'pointsEarned': pointsEarned,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
