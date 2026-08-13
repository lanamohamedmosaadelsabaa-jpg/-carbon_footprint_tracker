import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _transport;
  String? _diet;
  String? _energy;
  String? _waste;
  String? _flights;
  String? _water;
  String? _shopping;
  String? _outingFrequency;
  bool _isSaving = false;

  final Set<String> _outingActivities = {};
  bool _otherOutingSelected = false;
  final _otherOutingController = TextEditingController();

  final List<String> _transportOptions = [
    'Car (petrol/diesel)',
    'Electric vehicle',
    'Public transport',
    'Walking / cycling',
  ];

  final List<String> _dietOptions = [
    'Meat in most meals',
    'Meat a few times a week',
    'Vegetarian',
    'Vegan',
  ];

  final List<String> _energyOptions = [
    'Grid electricity (standard)',
    'Some solar/renewable',
    'Mostly solar/renewable',
    'Not sure',
  ];

  final List<String> _wasteOptions = [
    'I recycle regularly',
    'I recycle sometimes',
    "I don't really recycle",
    "Not sure what's recyclable",
  ];

  final List<String> _flightsOptions = [
    'None this year',
    '1–2 flights',
    '3–5 flights',
    '6+ flights',
  ];

  final List<String> _waterOptions = [
    'Short showers, mindful usage',
    'Average household usage',
    'Long showers / frequent baths',
    'Not sure',
  ];

  final List<String> _shoppingOptions = [
    'I buy only what I need',
    'Occasional non-essential purchases',
    'I shop often for clothes/gadgets',
    'I shop very frequently',
  ];

  final List<String> _outingFrequencyOptions = [
    'Rarely (0–1 times a month)',
    'A few times a month (2–4x)',
    'Weekly (1–2 times a week)',
    'Very often (3+ times a week)',
  ];

  final List<String> _outingActivityOptions = [
    'Restaurants & cafes',
    'Malls & shopping',
    'Outdoors / nature',
    'Cinema & entertainment',
    'Sports / gym',
    'Social events with friends',
  ];

  @override
  void dispose() {
    _otherOutingController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_transport == null ||
        _diet == null ||
        _energy == null ||
        _waste == null ||
        _flights == null ||
        _water == null ||
        _shopping == null ||
        _outingFrequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all the questions above')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final outingActivities = List<String>.from(_outingActivities);
    if (_otherOutingSelected && _otherOutingController.text.trim().isNotEmpty) {
      outingActivities.add(_otherOutingController.text.trim());
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'transport': _transport,
      'diet': _diet,
      'energy': _energy,
      'waste': _waste,
      'flightsPerYear': _flights,
      'waterUsage': _water,
      'shopping': _shopping,
      'outingFrequency': _outingFrequency,
      'outingActivities': outingActivities,
      'points': 0,
      'streak': 0,
      'lastLogDate': null,
      'badges': <String>[],
      'onboardingComplete': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
       builder: (_) => const DashboardScreen(),
      ),
    );
  }

  Widget _buildQuestion(String question, List<String> options, String? selected,
      void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...options.map((option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selected,
              onChanged: onChanged,
              activeColor: Colors.green,
              contentPadding: EdgeInsets.zero,
            )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOutingActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Where do you usually go when you go out? (pick any)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ..._outingActivityOptions.map((option) => CheckboxListTile(
              title: Text(option),
              value: _outingActivities.contains(option),
              activeColor: Colors.green,
              contentPadding: EdgeInsets.zero,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _outingActivities.add(option);
                  } else {
                    _outingActivities.remove(option);
                  }
                });
              },
            )),
        CheckboxListTile(
          title: const Text('Other'),
          value: _otherOutingSelected,
          activeColor: Colors.green,
          contentPadding: EdgeInsets.zero,
          onChanged: (checked) {
            setState(() => _otherOutingSelected = checked ?? false);
          },
        ),
        if (_otherOutingSelected)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: TextField(
              controller: _otherOutingController,
              decoration: const InputDecoration(
                hintText: 'Tell us where...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell us about your lifestyle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A few quick questions so we can calculate your starting footprint.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildQuestion('How do you usually get around?', _transportOptions,
                _transport, (v) => setState(() => _transport = v)),
            _buildQuestion('How would you describe your diet?', _dietOptions,
                _diet, (v) => setState(() => _diet = v)),
            _buildQuestion('What powers your home?', _energyOptions,
                _energy, (v) => setState(() => _energy = v)),
            _buildQuestion('How do you handle waste & recycling?', _wasteOptions,
                _waste, (v) => setState(() => _waste = v)),
            _buildQuestion('How often do you fly per year?', _flightsOptions,
                _flights, (v) => setState(() => _flights = v)),
            _buildQuestion('How would you describe your water usage?', _waterOptions,
                _water, (v) => setState(() => _water = v)),
            _buildQuestion('How would you describe your shopping habits?', _shoppingOptions,
                _shopping, (v) => setState(() => _shopping = v)),
            _buildQuestion('How often do you go out?', _outingFrequencyOptions,
                _outingFrequency, (v) => setState(() => _outingFrequency = v)),
            _buildOutingActivities(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _finishOnboarding,
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
                    : const Text('Finish Setup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}