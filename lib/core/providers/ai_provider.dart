import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';

// AI Service Provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// Loading State Providers for different AI features
final aiChatLoadingProvider = StateProvider<bool>((ref) => false);
final aiNotesLoadingProvider = StateProvider<bool>((ref) => false);
final aiQuizLoadingProvider = StateProvider<bool>((ref) => false);
final aiFlashcardsLoadingProvider = StateProvider<bool>((ref) => false);
final aiExplainLoadingProvider = StateProvider<bool>((ref) => false);

// Error State Providers
final aiChatErrorProvider = StateProvider<String?>((ref) => null);
final aiNotesErrorProvider = StateProvider<String?>((ref) => null);
final aiQuizErrorProvider = StateProvider<String?>((ref) => null);
final aiFlashcardsErrorProvider = StateProvider<String?>((ref) => null);
final aiExplainErrorProvider = StateProvider<String?>((ref) => null);



