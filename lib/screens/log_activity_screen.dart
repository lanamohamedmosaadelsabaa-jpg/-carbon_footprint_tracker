import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/carbon_calculator.dart';
import '../services/gamification_service.dart';

class LogActivityScreen extends StatefulWidget {
  const LogActivityScreen({super.key});

  @override
  State<LogActivityScreen> createState() => _LogActivityScreenState();
}

class _LogActivityScreenState extends State<LogActivityScreen> {
  String? _transport;
  String? _diet;
  bool _isSaving = false;

  Widget _buildQuestion(String question, Map<String, double> options, String? selected,
      void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...options.keys.map((option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selected,
              onChanged: onChanged,
              activeColor: Colors.green,
              contentPadding: EdgeInsets.zero,
            )),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _submitLog() async {
    if (_transport == null || _diet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer both questions')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userSnap = await userRef.get();
    final userData = userSnap.data() ?? {};

    final currentPoints = (userData['points'] ?? 0) as int;
    final currentStreak = (userData['streak'] ?? 0) as int;
    final lastLogDate = userData['lastLogDate'] as String?;
    final earnedBadges = List<String>.from(userData['badges'] ?? []);
    final isFirstLog = lastLogDate == null;

    final streakResult = GamificationService.updateStreak(lastLogDate, currentStreak);
    final alreadyLoggedToday = streakResult['alreadyLoggedToday'] as bool;

    if (alreadyLoggedToday) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You've already logged today — come back tomorrow!")),
      );
      return;
    }

    final pointsEarned = GamificationService.calculatePoints(
      transportChoice: _transport!,
      dietChoice: _diet!,
    );

    final newStreak = streakResult['streak'] as int;
    final newPoints = currentPoints + pointsEarned;

    final newBadges = GamificationService.checkNewBadges(
      totalPoints: newPoints,
      streak: newStreak,
      isFirstLog: isFirstLog,
      earnedBadges: earnedBadges,
    );

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await userRef.update({
      'points': newPoints,
      'streak': newStreak,
      'lastLogDate': todayStr,
      'badges': FieldValue.arrayUnion(newBadges),
    });

    await userRef.collection('logs').doc(todayStr).set({
      'transport': _transport,
      'diet': _diet,
      'pointsEarned': pointsEarned,
      'date': todayStr,
    });

    setState(() => _isSaving = false);
    if (!mounted) return;

    final badgeText =
        newBadges.isNotEmpty ? '\nNew badge${newBadges.length > 1 ? 's' : ''} unlocked!' : '';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logged!'),
        content: Text('+$pointsEarned points • Streak: $newStreak days$badgeText'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Nice!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Today'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Quick check-in — how did today go?", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            _buildQuestion('How did you get around today?', CarbonCalculator.transport,
                _transport, (v) => setState(() => _transport = v)),
            _buildQuestion('What did you mostly eat today?', CarbonCalculator.dailyDiet,
                _diet, (v) => setState(() => _diet = v)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}