import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastLogDate;
  final List<String> badges;
  final bool onboardingCompleted;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastLogDate,
    this.badges = const [],
    this.onboardingCompleted = false,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'Eco Warrior',
      totalPoints: data['totalPoints'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastLogDate: (data['lastLogDate'] as Timestamp?)?.toDate(),
      badges: List<String>.from(data['badges'] ?? []),
      onboardingCompleted: data['onboardingCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastLogDate': lastLogDate != null ? Timestamp.fromDate(lastLogDate!) : null,
      'badges': badges,
      'onboardingCompleted': onboardingCompleted,
    };
  }
}

class OnboardingData {
  final String diet;
  final List<String> transportModes;
  final String flightsPerYear;
  final int householdSize;
  final String energyUsage;
  final bool recycles;
  final List<String> goals;

  OnboardingData({
    required this.diet,
    required this.transportModes,
    required this.flightsPerYear,
    required this.householdSize,
    required this.energyUsage,
    required this.recycles,
    required this.goals,
  });

  Map<String, dynamic> toMap() {
    return {
      'diet': diet,
      'transportModes': transportModes,
      'flightsPerYear': flightsPerYear,
      'householdSize': householdSize,
      'energyUsage': energyUsage,
      'recycles': recycles,
      'goals': goals,
      'completedAt': FieldValue.serverTimestamp(),
    };
  }
}
