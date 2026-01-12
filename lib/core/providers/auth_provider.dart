import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Firebase Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current User Provider
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  return authState.when(
    data: (user) {
      if (user != null) {
        return firestoreService.streamUser(user.uid);
      }
      return Stream.value(null);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Loading State Provider
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Error Message Provider
final authErrorProvider = StateProvider<String?>((ref) => null);

// Auth Controller
class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;
  final Ref _ref;

  AuthController(this._authService, this._ref) : super(const AsyncValue.loading());

  // Sign up with email
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      if (user != null) {
        state = AsyncValue.data(user);
        _ref.read(authErrorProvider.notifier).state = null;
      } else {
        throw 'Failed to create user account';
      }
    } catch (e) {
      final error = e.toString();
      // Only set error state if user is NOT authenticated
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        state = AsyncValue.error(error, StackTrace.current);
        _ref.read(authErrorProvider.notifier).state = error;
      } else {
        // User is authenticated despite error - consider it success
        print('⚠️ Minor error but user is authenticated: $error');
        state = AsyncValue.data(UserModel(
          uid: currentUser.uid,
          email: currentUser.email!,
          displayName: currentUser.displayName ?? displayName,
          photoUrl: currentUser.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        ));
      }
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Sign in with email
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (user != null) {
        state = AsyncValue.data(user);
        _ref.read(authErrorProvider.notifier).state = null;
      } else {
        throw 'Failed to sign in';
      }
    } catch (e) {
      final error = e.toString();
      // Only set error state if user is NOT authenticated
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        state = AsyncValue.error(error, StackTrace.current);
        _ref.read(authErrorProvider.notifier).state = error;
      } else {
        // User is authenticated despite error - consider it success
        print('⚠️ Minor error but user is authenticated: $error');
        state = AsyncValue.data(UserModel(
          uid: currentUser.uid,
          email: currentUser.email!,
          displayName: currentUser.displayName ?? 'User',
          photoUrl: currentUser.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        ));
      }
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      final user = await _authService.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e) {
      final error = e.toString();
      state = AsyncValue.error(error, StackTrace.current);
      _ref.read(authErrorProvider.notifier).state = error;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      final user = await _authService.signInWithApple();
      state = AsyncValue.data(user);
    } catch (e) {
      final error = e.toString();
      state = AsyncValue.error(error, StackTrace.current);
      _ref.read(authErrorProvider.notifier).state = error;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Send password reset
  Future<void> sendPasswordResetEmail(String email) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _ref.read(authLoadingProvider.notifier).state = true;
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
}

// Auth Controller Provider
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService, ref);
});

