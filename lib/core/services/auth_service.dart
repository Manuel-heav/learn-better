import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      print('📝 Attempting sign up for: $email');
      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ User created! UID: ${userCredential.user!.uid}');

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      try {
        await _firestoreService.createUser(userModel);
        print('✅ Firestore user document created!');
      } catch (firestoreError) {
        print('⚠️ Firestore error (non-critical): $firestoreError');
        // Continue even if Firestore fails - auth still works!
      }

      print('✅ Sign up complete! Returning user model.');
      return userModel;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } on TypeError catch (e) {
      print('⚠️ Type error (non-critical): $e');
      // Firebase Auth succeeded but there's a plugin issue
      // Return the user model anyway since auth worked
      final user = _auth.currentUser;
      if (user != null) {
        return UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName ?? displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
      throw 'An error occurred during sign up. Please try again.';
    } catch (e) {
      print('❌ Generic error: $e');
      // Check if Firebase Auth actually succeeded despite the error
      final user = _auth.currentUser;
      if (user != null) {
        print('✅ Auth succeeded despite error, returning user');
        return UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName ?? displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
      throw 'An error occurred during sign up. Please try again.';
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting sign in for: $email');
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Sign in successful! UID: ${userCredential.user!.uid}');

      // Try to get/update user data from Firestore
      try {
        await _firestoreService.updateLastLogin(userCredential.user!.uid);
        return await _firestoreService.getUser(userCredential.user!.uid);
      } catch (firestoreError) {
        print('⚠️ Firestore error (non-critical): $firestoreError');
        // Return basic user model from Firebase Auth
        return UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName ?? 'User',
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } on TypeError catch (e) {
      print('⚠️ Type error (non-critical): $e');
      // Firebase Auth succeeded but there's a plugin issue
      // Return the user model anyway since auth worked
      final user = _auth.currentUser;
      if (user != null) {
        print('✅ Auth succeeded despite error, returning user');
        return UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
      throw 'An error occurred during sign in. Please try again.';
    } catch (e) {
      print('❌ Generic error: $e');
      // Check if Firebase Auth actually succeeded despite the error
      final user = _auth.currentUser;
      if (user != null) {
        print('✅ Auth succeeded despite error, returning user');
        return UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
      throw 'An error occurred during sign in. Please try again.';
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Google sign in was cancelled';
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore
      final existingUser = await _firestoreService.getUser(userCredential.user!.uid);

      if (existingUser != null) {
        // Update last login
        await _firestoreService.updateLastLogin(userCredential.user!.uid);
        return existingUser;
      } else {
        // Create new user document
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName ?? 'User',
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestoreService.createUser(userModel);
        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred with Google sign in. Please try again.';
    }
  }

  // Sign in with Apple (iOS only)
  Future<UserModel?> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      final UserCredential userCredential = await _auth.signInWithProvider(appleProvider);

      // Check if user exists in Firestore
      final existingUser = await _firestoreService.getUser(userCredential.user!.uid);

      if (existingUser != null) {
        // Update last login
        await _firestoreService.updateLastLogin(userCredential.user!.uid);
        return existingUser;
      } else {
        // Create new user document
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? 'apple_user@example.com',
          displayName: userCredential.user!.displayName ?? 'Apple User',
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestoreService.createUser(userModel);
        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred with Apple sign in. Please try again.';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'An error occurred during sign out. Please try again.';
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestoreService.deleteUser(user.uid);
        
        // Delete Firebase Auth account
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred while deleting your account. Please try again.';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign in method is not enabled.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }
}

