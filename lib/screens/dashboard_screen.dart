import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/carbon_calculator.dart';
import '../services/gamification_service.dart';
import 'log_activity_screen.dart';
import 'chatbot_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Footprint'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
       actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChatbotScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add_task),
        label: const Text('Log Today'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LogActivityScreen()),
          );
        },
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text('No data found.'));
          }

          final result = CarbonCalculator.calculate(data);
          final breakdown = result['breakdown'] as Map<String, double>;
          final total = result['totalMonthlyKgCO2e'] as double;
          final maxValue = breakdown.values.reduce((a, b) => a > b ? a : b);

          final points = (data['points'] ?? 0) as int;
          final streak = (data['streak'] ?? 0) as int;
          final earnedBadgeIds = List<String>.from(data['badges'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star,
                        label: 'Points',
                        value: '$points',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department,
                        label: 'Streak',
                        value: '$streak day${streak == 1 ? '' : 's'}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      const Text('Estimated monthly footprint', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        '${total.toStringAsFixed(0)} kg CO2e',
                        style: const TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Breakdown by category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...breakdown.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text('${entry.value.toStringAsFixed(0)} kg'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: maxValue == 0 ? 0 : entry.value / maxValue,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(Colors.green),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                const Text('Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (earnedBadgeIds.isEmpty)
                  const Text('Log today to start earning badges!',
                      style: TextStyle(color: Colors.grey)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: GamificationService.badgeDefinitions
                      .where((b) => earnedBadgeIds.contains(b['id']))
                      .map((b) => Chip(
                            avatar: const Icon(Icons.emoji_events, size: 18, color: Colors.white),
                            label: Text(b['name']),
                            backgroundColor: Colors.green,
                            labelStyle: const TextStyle(color: Colors.white),
                          ))
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}