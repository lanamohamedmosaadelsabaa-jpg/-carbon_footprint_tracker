import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> dietOptions = [
    'Vegan',
    'Vegetarian',
    'Pescatarian',
    'Omnivore (moderate)',
    'Omnivore (heavy)',
  ];

  final List<String> transportOptions = [
    'Walk/Bike',
    'Public transport',
    'Personal car (petrol)',
    'Personal car (electric/hybrid)',
    'Rideshare',
  ];

  final List<String> goalOptions = [
    'Reduce car use',
    'Eat less meat',
    'Cut plastic',
    'Save electricity',
    'Use public transport',
  ];

  String selectedDiet = 'Vegan';
  final List<String> transportModes = [];
  String flightsPerYear = '0';
  int householdSize = 2;
  String energyUsage = 'Medium';
  bool recycles = false;
  final List<String> goals = [];

  Future<void> completeOnboarding() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final onboardingData = {
      'diet': selectedDiet,
      'transportModes': transportModes,
      'flightsPerYear': flightsPerYear,
      'householdSize': householdSize,
      'energyUsage': energyUsage,
      'recycles': recycles,
      'goals': goals,
      'completedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'onboardingCompleted': true,
      'onboarding': onboardingData,
      'totalPoints': FieldValue.increment(20),
      'lastLogDate': FieldValue.serverTimestamp(),
      'currentStreak': 1,
      'longestStreak': 1,
    }, SetOptions(merge: true));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  Widget progressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final active = index == _currentPage;
        return Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF10B981) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            progressDots(),
            const SizedBox(height: 24),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _dietPage(),
                  _transportPage(),
                  _homePage(),
                  _goalPage(),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _currentPage == 0 ? null : () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < 3) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      completeOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_currentPage < 3 ? 'Next' : 'Finish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dietPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is your diet?',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ...dietOptions.map((option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selectedDiet,
              onChanged: (value) {
                setState(() => selectedDiet = value!);
              },
            )),
      ],
    );
  }

  Widget _transportPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How do you usually travel?',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...transportOptions.map((mode) {
          final selected = transportModes.contains(mode);
          return CheckboxListTile(
            title: Text(mode),
            value: selected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  transportModes.add(mode);
                } else {
                  transportModes.remove(mode);
                }
              });
            },
          );
        }),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: flightsPerYear,
          decoration: const InputDecoration(
            labelText: 'Flights per year',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: '0', child: Text('0')),
            DropdownMenuItem(value: '1-2', child: Text('1-2')),
            DropdownMenuItem(value: '3-5', child: Text('3-5')),
            DropdownMenuItem(value: '6+', child: Text('6+')),
          ],
          onChanged: (value) => setState(() => flightsPerYear = value ?? '0'),
        ),
      ],
    );
  }

  Widget _homePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Home & energy',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Household size',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            householdSize = int.tryParse(value) ?? 1;
          },
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: energyUsage,
          decoration: const InputDecoration(
            labelText: 'Energy usage',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Low', child: Text('Low')),
            DropdownMenuItem(value: 'Medium', child: Text('Medium')),
            DropdownMenuItem(value: 'High', child: Text('High')),
          ],
          onChanged: (value) => setState(() => energyUsage = value ?? 'Medium'),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Do you recycle?'),
          value: recycles,
          onChanged: (value) => setState(() => recycles = value ?? false),
        ),
      ],
    );
  }

  Widget _goalPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What do you want to improve?',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...goalOptions.map((goal) {
          final selected = goals.contains(goal);
          return CheckboxListTile(
            title: Text(goal),
            value: selected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  goals.add(goal);
                } else {
                  goals.remove(goal);
                }
              });
            },
          );
        }),
      ],
    );
  }
}
