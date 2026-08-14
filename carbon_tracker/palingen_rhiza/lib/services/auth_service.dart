import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _db.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email.trim(),
        'displayName': name.trim().isEmpty ? 'Eco Warrior' : name.trim(),
        'totalPoints': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'lastLogDate': null,
        'badges': [],
        'onboardingCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during sign up.';
    } catch (e) {
      return 'Unexpected error: ${e.toString()}';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during login.';
    } catch (e) {
      return 'Unexpected error: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> completeOnboarding({
    required String uid,
    required Map<String, dynamic> onboardingData,
  }) async {
    await _db.collection('users').doc(uid).set({
      'onboardingCompleted': true,
      'onboarding': onboardingData,
      'totalPoints': FieldValue.increment(20),
      'lastLogDate': FieldValue.serverTimestamp(),
      'currentStreak': 1,
      'longestStreak': 1,
    }, SetOptions(merge: true));
  }
}
