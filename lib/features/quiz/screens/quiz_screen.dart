import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/ai_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  // Flow states
  int _currentStep = 0; // 0: input content, 1: configure, 2: quiz
  bool _isGenerating = false;
  
  // Content input
  final _contentController = TextEditingController();
  
  // Quiz config
  String _selectedDifficulty = 'Medium';
  int _questionCount = 5;
  
  // Quiz state
  int _currentQuestion = 0;
  String? _selectedAnswer;
  bool _showExplanation = false;
  int _correctCount = 0;
  List<QuizQuestion> _questions = [];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged(String value) {
    setState(() {});
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _contentController.text = data.text!;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Content pasted!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nothing to paste'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  void _proceedToConfig() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please paste your study material'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (_contentController.text.trim().length < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add more content (at least a paragraph)'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    setState(() => _currentStep = 1);
  }

  Future<void> _generateQuiz() async {
    setState(() => _isGenerating = true);

    try {
      final aiService = ref.read(aiServiceProvider);
      final content = _contentController.text.trim();
      
      final results = await aiService.generateQuizFromContent(
        content: content,
        difficulty: _selectedDifficulty.toLowerCase(),
        questionCount: _questionCount,
      );

      if (results.isEmpty) {
        throw 'Could not generate questions. Try adding more detailed content.';
      }

      setState(() {
        _questions = results.map((q) => QuizQuestion(
          question: q['question'] as String,
          options: List<String>.from(q['options']),
          correctAnswer: _getCorrectAnswer(q),
          explanation: q['explanation'] as String,
        )).toList();
        _currentStep = 2;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _getCorrectAnswer(Map<String, dynamic> q) {
    final correct = q['correctAnswer'] as String;
    final options = List<String>.from(q['options']);
    
    switch (correct.toUpperCase()) {
      case 'A': return options.isNotEmpty ? options[0] : '';
      case 'B': return options.length > 1 ? options[1] : '';
      case 'C': return options.length > 2 ? options[2] : '';
      case 'D': return options.length > 3 ? options[3] : '';
      default: return correct;
    }
  }

  void _checkAnswer(String answer) {
    final isCorrect = answer == _questions[_currentQuestion].correctAnswer;
    if (isCorrect) _correctCount++;
    
    setState(() {
      _selectedAnswer = answer;
      _showExplanation = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _showExplanation = false;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final percentage = (_correctCount / _questions.length * 100).round();
    String message;
    String emoji;
    
    if (percentage >= 80) {
      message = 'Excellent!';
      emoji = '🏆';
    } else if (percentage >= 60) {
      message = 'Good job!';
      emoji = '👍';
    } else if (percentage >= 40) {
      message = 'Keep studying!';
      emoji = '📚';
    } else {
      message = 'Review the material';
      emoji = '💪';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('$emoji Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: percentage >= 60 
                    ? [AppColors.success, Colors.green.shade700]
                    : [AppColors.warning, Colors.orange.shade700],
                ),
              ),
              child: Center(
                child: Text(
                  '$percentage%',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$_correctCount / ${_questions.length} correct', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetQuiz();
            },
            child: const Text('New Quiz'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      _currentStep = 0;
      _currentQuestion = 0;
      _correctCount = 0;
      _selectedAnswer = null;
      _showExplanation = false;
      _questions = [];
      _contentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildContentInputStep();
      case 1:
        return _buildConfigStep();
      case 2:
        return _buildQuizStep();
      default:
        return _buildContentInputStep();
    }
  }

  // STEP 1: Content Input
  Widget _buildContentInputStep() {
    final charCount = _contentController.text.length;
    final wordCount = _contentController.text.trim().isEmpty 
        ? 0 
        : _contentController.text.trim().split(RegExp(r'\s+')).length;
    final isReady = charCount >= 100;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('AI Quiz Generator'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Create a Quiz',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Paste your notes and AI will generate\nquiz questions to test your knowledge',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.info.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.tips_and_updates_rounded, color: AppColors.info, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Copy text from your lecture notes, textbook, or any study material and paste it below.',
                            style: TextStyle(fontSize: 13, color: AppColors.info, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Label with paste button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionLabel('YOUR STUDY MATERIAL'),
                      TextButton.icon(
                        onPressed: _pasteFromClipboard,
                        icon: const Icon(Icons.content_paste_rounded, size: 18),
                        label: const Text('Paste'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Text input
                  TextField(
                    controller: _contentController,
                    maxLines: 12,
                    onChanged: _onContentChanged,
                    decoration: InputDecoration(
                      hintText: 'Paste your lecture notes, textbook content, or study material here...\n\nFor example:\n"The mitochondria is the powerhouse of the cell. It produces ATP through cellular respiration, which involves glycolysis, the Krebs cycle, and the electron transport chain..."',
                      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14, height: 1.5),
                      filled: true,
                      fillColor: AppColors.backgroundWhite,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isReady ? AppColors.success : AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                  ),

                  // Stats
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$charCount characters • $wordCount words',
                          style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isReady ? AppColors.success.withOpacity(0.1) : AppColors.divider,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isReady ? Icons.check_circle : Icons.info_outline,
                                size: 14,
                                color: isReady ? AppColors.success : AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isReady ? 'Ready!' : 'Add more content',
                                style: TextStyle(
                                  color: isReady ? AppColors.success : AppColors.textTertiary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isReady ? _proceedToConfig : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    disabledBackgroundColor: AppColors.divider,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Configuration
  Widget _buildConfigStep() {
    final wordCount = _contentController.text.trim().split(RegExp(r'\s+')).length;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        title: const Text('Configure Quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Content Ready', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.success)),
                        Text('$wordCount words added', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentStep = 0),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Number of questions
            _buildSectionLabel('NUMBER OF QUESTIONS'),
            const SizedBox(height: 12),
            Row(
              children: [3, 5, 10].map((count) {
                final isSelected = _questionCount == count;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _questionCount = count),
                    child: Container(
                      margin: EdgeInsets.only(right: count != 10 ? 12 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue : AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBlue : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'questions',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Difficulty
            _buildSectionLabel('DIFFICULTY LEVEL'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDifficultyOption('Easy', Icons.sentiment_satisfied_rounded, AppColors.success),
                const SizedBox(width: 12),
                _buildDifficultyOption('Medium', Icons.trending_up_rounded, AppColors.warning),
                const SizedBox(width: 12),
                _buildDifficultyOption('Hard', Icons.local_fire_department_rounded, AppColors.error),
              ],
            ),

            const SizedBox(height: 40),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                          SizedBox(width: 14),
                          Text('Creating your quiz...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 22, color: Colors.white),
                          SizedBox(width: 10),
                          Text('Generate Quiz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(String label, IconData icon, Color color) {
    final isSelected = _selectedDifficulty == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDifficulty = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : AppColors.textSecondary, size: 28),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? color : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 3: Quiz
  Widget _buildQuizStep() {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions available')),
      );
    }

    final question = _questions[_currentQuestion];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _showExitDialog(),
        ),
        title: Text('Question ${_currentQuestion + 1}/${_questions.length}'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                const SizedBox(width: 4),
                Text('$_correctCount', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _questions.length,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            minHeight: 6,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      question.question,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Options
                  ...question.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = _selectedAnswer == option;
                    final isCorrect = option == question.correctAnswer;
                    final showResult = _showExplanation;

                    Color? backgroundColor;
                    Color? borderColor;
                    IconData? icon;

                    if (showResult) {
                      if (isCorrect) {
                        backgroundColor = AppColors.success.withOpacity(0.1);
                        borderColor = AppColors.success;
                        icon = Icons.check_circle_rounded;
                      } else if (isSelected && !isCorrect) {
                        backgroundColor = AppColors.error.withOpacity(0.1);
                        borderColor = AppColors.error;
                        icon = Icons.cancel_rounded;
                      }
                    } else if (isSelected) {
                      borderColor = AppColors.primaryBlue;
                      backgroundColor = AppColors.primaryBlue.withOpacity(0.05);
                    }

                    return GestureDetector(
                      onTap: _showExplanation ? null : () => _checkAnswer(option),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: backgroundColor ?? AppColors.backgroundWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor ?? AppColors.border, width: 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: (borderColor ?? AppColors.textSecondary).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: borderColor ?? AppColors.textSecondary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Text(option, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                            if (icon != null) Icon(icon, color: isCorrect ? AppColors.success : AppColors.error),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Explanation
                  if (_showExplanation) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.info.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_rounded, color: AppColors.info, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _selectedAnswer == question.correctAnswer ? 'Correct!' : 'Incorrect',
                                style: TextStyle(
                                  color: _selectedAnswer == question.correctAnswer ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(question.explanation, style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary.withOpacity(0.9))),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_showExplanation)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _currentQuestion < _questions.length - 1 ? 'Next Question' : 'See Results',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continue')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.textSecondary),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}
