import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class AIService {
  // GROQ - FREE API with generous limits!
  // 30 requests/minute, 14,400 requests/day - FREE!
  static const String _apiKey = ApiKeys.groqApiKey;
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // Using llama-3.1-8b-instant - fast and free!
  static const String _model = 'llama-3.1-8b-instant';

  AIService();

  Future<String> _callGroq(String systemPrompt, String userMessage, {int maxTokens = 1024}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'temperature': 0.7,
          'max_tokens': maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'No response generated.';
      } else {
        final error = jsonDecode(response.body);
        throw 'API error: ${error['error']?['message'] ?? response.statusCode}';
      }
    } catch (e) {
      if (e.toString().contains('API error')) rethrow;
      throw 'Network error: $e';
    }
  }

  // ============ CHAT FEATURE ============
  
  Future<String> chat(String message, {String? context}) async {
    final systemPrompt = context != null
        ? 'You are a friendly AI study assistant. Previous context: $context. Help students learn with clear explanations and examples.'
        : 'You are a friendly AI study assistant helping students learn better. Provide clear, helpful responses with examples when useful. Keep responses concise but informative.';
    
    return await _callGroq(systemPrompt, message);
  }

  // ============ SMART NOTES FEATURE ============
  
  Future<Map<String, dynamic>> generateNoteSummary(String content) async {
    final systemPrompt = '''You are an expert note summarizer. Analyze educational content and extract key information.
Always format your response EXACTLY like this:

SUMMARY:
[2-3 paragraph summary]

KEY CONCEPTS:
- [Concept 1]
- [Concept 2]
- [Concept 3]

IMPORTANT TERMS:
- Term: Definition
- Term: Definition''';

    final response = await _callGroq(systemPrompt, 'Summarize this content:\n\n$content', maxTokens: 1500);
    return _parseNoteSummary(response);
  }

  Map<String, dynamic> _parseNoteSummary(String text) {
    String summary = '';
    List<String> keyConcepts = [];
    List<String> importantTerms = [];
    String currentSection = '';
    
    for (var line in text.split('\n')) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      if (line.toUpperCase().contains('SUMMARY:')) {
        currentSection = 'summary';
        continue;
      } else if (line.toUpperCase().contains('KEY CONCEPTS:')) {
        currentSection = 'concepts';
        continue;
      } else if (line.toUpperCase().contains('IMPORTANT TERMS:')) {
        currentSection = 'terms';
        continue;
      }
      
      switch (currentSection) {
        case 'summary':
          summary += '$line\n';
          break;
        case 'concepts':
          if (line.startsWith('-') || line.startsWith('•') || line.startsWith('*')) {
            keyConcepts.add(line.replaceFirst(RegExp(r'^[-•*]\s*'), ''));
          }
          break;
        case 'terms':
          if (line.startsWith('-') || line.startsWith('•') || line.startsWith('*')) {
            importantTerms.add(line.replaceFirst(RegExp(r'^[-•*]\s*'), ''));
          }
          break;
      }
    }
    
    return {
      'summary': summary.trim(),
      'keyConcepts': keyConcepts,
      'importantTerms': importantTerms,
    };
  }

  // ============ QUIZ GENERATOR ============
  
  Future<List<Map<String, dynamic>>> generateQuiz({
    required String topic,
    required String difficulty,
    int questionCount = 5,
  }) async {
    final systemPrompt = '''You are a quiz generator. Create multiple-choice questions.
Format each question EXACTLY like this:

Q: [Question text]
A) [Option A]
B) [Option B]
C) [Option C]
D) [Option D]
CORRECT: [A/B/C/D]
EXPLANATION: [Brief explanation]

---

Separate questions with ---''';

    final response = await _callGroq(
      systemPrompt, 
      'Generate $questionCount $difficulty level questions about: $topic',
      maxTokens: 2000,
    );
    return _parseQuizQuestions(response);
  }

  List<Map<String, dynamic>> _parseQuizQuestions(String text) {
    final questions = <Map<String, dynamic>>[];
    final blocks = text.split('---');
    
    for (var block in blocks) {
      final lines = block.split('\n').where((l) => l.trim().isNotEmpty).toList();
      if (lines.length < 5) continue;
      
      String? question;
      List<String> options = [];
      String? correct;
      String? explanation;
      
      for (var line in lines) {
        line = line.trim();
        if (line.startsWith('Q:')) {
          question = line.substring(2).trim();
        } else if (RegExp(r'^[ABCD]\)').hasMatch(line)) {
          options.add(line.substring(2).trim());
        } else if (line.toUpperCase().startsWith('CORRECT:')) {
          correct = line.substring(8).trim().toUpperCase().replaceAll(RegExp(r'[^ABCD]'), '');
        } else if (line.toUpperCase().startsWith('EXPLANATION:')) {
          explanation = line.substring(12).trim();
        }
      }
      
      if (question != null && options.length == 4 && correct != null) {
        questions.add({
          'question': question,
          'options': options,
          'correctAnswer': correct,
          'explanation': explanation ?? 'No explanation provided.',
        });
      }
    }
    
    return questions;
  }

  // ============ FLASHCARD GENERATOR ============
  
  Future<List<Map<String, String>>> generateFlashcards({
    required String topic,
    required String content,
    int cardCount = 10,
  }) async {
    final systemPrompt = '''You are a flashcard creator. Create study flashcards.
Format each card EXACTLY like this:

FRONT: [Question or term]
BACK: [Answer or definition]

---

Separate cards with ---''';

    final response = await _callGroq(
      systemPrompt,
      'Create $cardCount flashcards about "$topic" based on:\n\n$content',
      maxTokens: 2000,
    );
    return _parseFlashcards(response);
  }

  List<Map<String, String>> _parseFlashcards(String text) {
    final flashcards = <Map<String, String>>[];
    final blocks = text.split('---');
    
    for (var block in blocks) {
      String? front;
      String? back;
      
      for (var line in block.split('\n')) {
        line = line.trim();
        if (line.toUpperCase().startsWith('FRONT:')) {
          front = line.substring(6).trim();
        } else if (line.toUpperCase().startsWith('BACK:')) {
          back = line.substring(5).trim();
        }
      }
      
      if (front != null && back != null && front.isNotEmpty && back.isNotEmpty) {
        flashcards.add({'front': front, 'back': back});
      }
    }
    
    return flashcards;
  }

  // ============ EXPLAIN WITH EXAMPLES ============
  
  Future<Map<String, dynamic>> explainConcept(String concept) async {
    final systemPrompt = '''You are an expert teacher. Explain concepts clearly.
Format your response EXACTLY like this:

DEFINITION: [Clear, simple definition]

REAL-WORLD ANALOGY: [Everyday analogy]

SIMPLE EXPLANATION: [Explain like I'm 10]

EXAMPLE: [Concrete example]

RELATED CONCEPTS:
- [Related topic 1]
- [Related topic 2]
- [Related topic 3]''';

    final response = await _callGroq(systemPrompt, 'Explain: $concept', maxTokens: 1500);
    return _parseExplanation(response);
  }

  Map<String, dynamic> _parseExplanation(String text) {
    final sections = <String, dynamic>{
      'definition': '',
      'analogy': '',
      'simpleExplanation': '',
      'example': '',
      'relatedConcepts': <String>[],
    };
    
    String currentSection = '';
    
    for (var line in text.split('\n')) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      final upper = line.toUpperCase();
      if (upper.startsWith('DEFINITION:')) {
        currentSection = 'definition';
        sections['definition'] = line.substring(11).trim();
      } else if (upper.contains('ANALOGY:')) {
        currentSection = 'analogy';
        final idx = upper.indexOf('ANALOGY:');
        sections['analogy'] = line.substring(idx + 8).trim();
      } else if (upper.contains('SIMPLE EXPLANATION:')) {
        currentSection = 'simpleExplanation';
        final idx = upper.indexOf('SIMPLE EXPLANATION:');
        sections['simpleExplanation'] = line.substring(idx + 19).trim();
      } else if (upper.startsWith('EXAMPLE:')) {
        currentSection = 'example';
        sections['example'] = line.substring(8).trim();
      } else if (upper.contains('RELATED CONCEPTS:')) {
        currentSection = 'relatedConcepts';
      } else {
        switch (currentSection) {
          case 'definition':
            sections['definition'] = '${sections['definition']} $line'.trim();
            break;
          case 'analogy':
            sections['analogy'] = '${sections['analogy']} $line'.trim();
            break;
          case 'simpleExplanation':
            sections['simpleExplanation'] = '${sections['simpleExplanation']} $line'.trim();
            break;
          case 'example':
            sections['example'] = '${sections['example']} $line'.trim();
            break;
          case 'relatedConcepts':
            if (line.startsWith('-') || line.startsWith('•') || line.startsWith('*')) {
              (sections['relatedConcepts'] as List<String>).add(
                line.replaceFirst(RegExp(r'^[-•*\d.]\s*'), '').trim()
              );
            }
            break;
        }
      }
    }
    
    return sections;
  }

  // ============ VOICE RECORDING ANALYSIS ============
  
  Future<Map<String, dynamic>> analyzeVoiceRecording(String transcription) async {
    final systemPrompt = '''You are a lecture note analyzer. Analyze transcriptions and extract key information.
Format your response EXACTLY like this:

SUMMARY:
[Concise summary]

KEY TAKEAWAYS:
- [Point 1]
- [Point 2]

ACTION ITEMS:
- [Task 1]
- [Task 2]

QUESTIONS:
- [Question 1]
- [Question 2]''';

    final response = await _callGroq(
      systemPrompt,
      'Analyze this lecture transcription:\n\n$transcription',
      maxTokens: 1500,
    );
    return _parseVoiceAnalysis(response);
  }

  Map<String, dynamic> _parseVoiceAnalysis(String text) {
    String summary = '';
    List<String> keyTakeaways = [];
    List<String> actionItems = [];
    List<String> questions = [];
    String currentSection = '';
    
    for (var line in text.split('\n')) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      final upper = line.toUpperCase();
      if (upper.contains('SUMMARY:')) {
        currentSection = 'summary';
        continue;
      } else if (upper.contains('KEY TAKEAWAYS:')) {
        currentSection = 'takeaways';
        continue;
      } else if (upper.contains('ACTION ITEMS:')) {
        currentSection = 'actions';
        continue;
      } else if (upper.contains('QUESTIONS:')) {
        currentSection = 'questions';
        continue;
      }
      
      switch (currentSection) {
        case 'summary':
          summary += '$line ';
          break;
        case 'takeaways':
          if (line.startsWith('-') || line.startsWith('•') || line.startsWith('*')) {
            keyTakeaways.add(line.replaceFirst(RegExp(r'^[-•*\d.]\s*'), ''));
          }
          break;
        case 'actions':
          if (line.startsWith('-') || line.startsWith('•') || line.startsWith('*')) {
            actionItems.add(line.replaceFirst(RegExp(r'^[-•*\d.]\s*'), ''));
          }
          break;
        case 'questions':
          if (line.startsWith('-') || line.startsWith('•') || line.startsWith('*')) {
            questions.add(line.replaceFirst(RegExp(r'^[-•*\d.]\s*'), ''));
          }
          break;
      }
    }
    
    return {
      'summary': summary.trim(),
      'keyTakeaways': keyTakeaways,
      'actionItems': actionItems,
      'questions': questions,
    };
  }

  // ============ QUICK RESPONSES ============
  
  Future<String> getQuickResponse(String query) async {
    return await _callGroq(
      'You are a helpful study assistant. Give brief, accurate answers.',
      query,
      maxTokens: 256,
    );
  }
}
