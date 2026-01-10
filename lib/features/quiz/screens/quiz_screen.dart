import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _showQuizSetup = true;
  int _currentQuestion = 0;
  String? _selectedAnswer;
  bool _showExplanation = false;

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: 'Which cellular organelle is responsible for generating ATP?',
      options: ['Nucleus', 'Ribosome', 'Mitochondria', 'Golgi Apparatus'],
      correctAnswer: 'Mitochondria',
      explanation:
          'Mitochondria are often referred to as the powerhouse of the cell because they generate most of the cell\'s supply of adenosine triphosphate (ATP), used as a source of chemical energy.',
    ),
    QuizQuestion(
      question: 'What are the four phases of Mitosis in correct order?',
      options: [
        'Prophase, Metaphase, Anaphase, Telophase',
        'Prophase, Anaphase, Metaphase, Telophase',
        'Metaphase, Prophase, Anaphase, Telophase',
        'Anaphase, Prophase, Metaphase, Telophase',
      ],
      correctAnswer: 'Prophase, Metaphase, Anaphase, Telophase',
      explanation:
          'The four phases of Mitosis typically occur in this order: Prophase (chromosomes condense), Metaphase (chromosomes align), Anaphase (sister chromatids separate), and Telophase (two nuclei form). Cytokinesis typically overlaps with the last stages.',
    ),
  ];

  void _startQuiz() {
    setState(() {
      _showQuizSetup = false;
    });
  }

  void _checkAnswer(String answer) {
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
      // Quiz complete
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete! 🎉'),
        content: const Text(
          'Great job! You\'ve completed the quiz.\n\nScore: 1/2 correct',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showQuizSetup) {
      return _buildQuizSetup();
    }

    final question = _questions[_currentQuestion];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Question ${_currentQuestion + 1}/${_questions.length}'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentQuestion + 1}/${_questions.length}',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _questions.length,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      question.question,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            height: 1.4,
                          ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Options
                  ...question.options.asMap().entries.map((entry) {
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
                    }

                    return GestureDetector(
                      onTap: _showExplanation
                          ? null
                          : () => _checkAnswer(option),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: backgroundColor ?? AppColors.backgroundWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor ?? AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (icon != null)
                              Icon(
                                icon,
                                color: isCorrect
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Explanation
                  if (_showExplanation) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_rounded,
                                color: AppColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI EXPLANATION',
                                style: TextStyle(
                                  color: AppColors.info,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedAnswer == question.correctAnswer
                                ? 'Correct! ${question.explanation}'
                                : 'Incorrect. ${question.explanation}',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Next button
          if (_showExplanation)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Next Question',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizSetup() {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Quiz Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Ready to test your\nknowledge?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
              ),
            ),

            const SizedBox(height: 32),

            // Source Material
            _buildSection(
              'SOURCE MATERIAL',
              [
                _buildOptionCard(
                  'From Notes',
                  Icons.note_alt_rounded,
                  isSelected: true,
                ),
                _buildOptionCard(
                  'Upload PDF',
                  Icons.upload_file_rounded,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Question Types
            _buildSection(
              'QUESTION TYPES',
              [
                Row(
                  children: [
                    Expanded(
                      child: _buildChip('Multiple Choice', isSelected: true),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildChip('True / False'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildChip('Short Answer'),
              ],
            ),

            const SizedBox(height: 24),

            // Difficulty
            _buildSection(
              'DIFFICULTY',
              [
                Row(
                  children: [
                    Expanded(
                      child: _buildChip('Easy'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildChip('Medium', isSelected: true),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildChip('Hard'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Generate Quiz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Daily Challenge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.success, Colors.green.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daily Challenge',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Question 2 of 10',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildOptionCard(String label, IconData icon, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryBlue.withOpacity(0.1)
            : AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.border,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryBlue
            : AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.border,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
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


