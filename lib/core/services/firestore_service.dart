import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =============== USER OPERATIONS ===============

  // Create user document
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    } catch (e) {
      throw 'Failed to create user profile';
    }
  }

  // Get user document
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user data';
    }
  }

  // Update user document
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw 'Failed to update user data';
    }
  }

  // Update last login
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': Timestamp.now(),
      });
    } catch (e) {
      // Silently fail - not critical
    }
  }

  // Delete user document
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw 'Failed to delete user data';
    }
  }

  // Stream user data
  Stream<UserModel?> streamUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // =============== PROGRESS TRACKING ===============

  // Increment quiz count
  Future<void> incrementQuizCount(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'quizzesCompleted': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Failed to update quiz count';
    }
  }

  // Add study time
  Future<void> addStudyTime(String uid, int minutes) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'studyTimeMinutes': FieldValue.increment(minutes),
      });
    } catch (e) {
      throw 'Failed to update study time';
    }
  }

  // Update day streak
  Future<void> updateDayStreak(String uid, int streak) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'dayStreak': streak,
      });
    } catch (e) {
      throw 'Failed to update day streak';
    }
  }

  // =============== SETTINGS ===============

  // Update complexity level
  Future<void> updateComplexityLevel(String uid, String level) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'complexityLevel': level,
      });
    } catch (e) {
      throw 'Failed to update complexity level';
    }
  }

  // Update AI persona
  Future<void> updateAIPersona(String uid, String persona) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'aiPersona': persona,
      });
    } catch (e) {
      throw 'Failed to update AI persona';
    }
  }

  // Update theme
  Future<void> updateTheme(String uid, String theme) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'theme': theme,
      });
    } catch (e) {
      throw 'Failed to update theme';
    }
  }

  // Update notifications
  Future<void> updateNotifications(String uid, bool enabled) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'notificationsEnabled': enabled,
      });
    } catch (e) {
      throw 'Failed to update notifications';
    }
  }

  // Update read aloud
  Future<void> updateReadAloud(String uid, bool enabled) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'readAloudEnabled': enabled,
      });
    } catch (e) {
      throw 'Failed to update read aloud setting';
    }
  }

  // =============== FLASHCARDS ===============

  // Save flashcard deck
  Future<void> saveFlashcardDeck({
    required String uid,
    required String deckName,
    required List<Map<String, String>> cards,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('flashcards')
          .add({
        'deckName': deckName,
        'cards': cards,
        'createdAt': Timestamp.now(),
        'lastReviewed': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to save flashcard deck';
    }
  }

  // Get flashcard decks
  Future<List<QueryDocumentSnapshot>> getFlashcardDecks(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('flashcards')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs;
    } catch (e) {
      throw 'Failed to get flashcard decks';
    }
  }

  // =============== NOTES ===============

  // Save note
  Future<void> saveNote({
    required String uid,
    required String title,
    required String content,
    required String summary,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .add({
        'title': title,
        'content': content,
        'summary': summary,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to save note';
    }
  }

  // Get notes
  Future<List<QueryDocumentSnapshot>> getNotes(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs;
    } catch (e) {
      throw 'Failed to get notes';
    }
  }

  // =============== STUDY SESSIONS ===============

  // Log study session
  Future<void> logStudySession({
    required String uid,
    required String subject,
    required int durationMinutes,
    required String activityType, // chat, quiz, flashcards, voice, focus
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('study_sessions')
          .add({
        'subject': subject,
        'durationMinutes': durationMinutes,
        'activityType': activityType,
        'timestamp': Timestamp.now(),
      });

      // Also update total study time
      await addStudyTime(uid, durationMinutes);
    } catch (e) {
      throw 'Failed to log study session';
    }
  }

  // Get study sessions
  Future<List<QueryDocumentSnapshot>> getStudySessions(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('study_sessions')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      return snapshot.docs;
    } catch (e) {
      throw 'Failed to get study sessions';
    }
  }

  // =============== ACHIEVEMENTS ===============

  // Unlock achievement
  Future<void> unlockAchievement({
    required String uid,
    required String achievementId,
    required String achievementName,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('achievements')
          .doc(achievementId)
          .set({
        'name': achievementName,
        'unlockedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to unlock achievement';
    }
  }

  // Get achievements
  Future<List<QueryDocumentSnapshot>> getAchievements(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('achievements')
          .get();
      return snapshot.docs;
    } catch (e) {
      throw 'Failed to get achievements';
    }
  }
}

