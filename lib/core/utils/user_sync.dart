import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

/// Utility to ensure user document exists in Firestore
class UserSync {
  static Future<void> ensureUserDocumentExists() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final firestoreService = FirestoreService();
    
    try {
      // Check if user document exists
      final existingUser = await firestoreService.getUser(currentUser.uid);
      
      if (existingUser == null) {
        // Create user document if it doesn't exist
        print('📝 Creating missing user document for: ${currentUser.email}');
        final userModel = UserModel(
          uid: currentUser.uid,
          email: currentUser.email!,
          displayName: currentUser.displayName ?? 'User',
          photoUrl: currentUser.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await firestoreService.createUser(userModel);
        print('✅ User document created successfully!');
      } else {
        // Update last login
        await firestoreService.updateLastLogin(currentUser.uid);
        print('✅ User document exists, updated last login');
      }
    } catch (e) {
      print('⚠️ Error syncing user document: $e');
      // Non-critical error
    }
  }
}

