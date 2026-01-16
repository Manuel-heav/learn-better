import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/ai_provider.dart';
import 'dart:math' as math;

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  // Flow states
  int _currentStep = 0; // 0: input content, 1: configure, 2: study
  bool _isGenerating = false;

  // Content input
  final _contentController = TextEditingController();

  // Config
  int _cardCount = 10;

  // Study state
  int _currentIndex = 0;
  bool _showAnswer = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Progress tracking
  int _knewIt = 0;
  int _learning = 0;
  int _needsWork = 0;

  List<Flashcard> _flashcards = [];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  void _onContentChanged(String value) {
    setState(() {});
  }

  @override
  void dispose() {
    _flipController.dispose();
    _contentController.dispose();
    super.dispose();
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

  Future<void> _generateFlashcards() async {
    setState(() => _isGenerating = true);

    try {
      final aiService = ref.read(aiServiceProvider);
      final content = _contentController.text.trim();

      final results = await aiService.generateFlashcardsFromContent(
        content: content,
        cardCount: _cardCount,
      );

      if (results.isEmpty) {
        throw 'Could not generate flashcards. Try adding more detailed content.';
      }

      setState(() {
        _flashcards = results.map((card) => Flashcard(
          question: card['front'] ?? '',
          answer: card['back'] ?? '',
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

  void _flipCard() {
    if (_showAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _nextCard(String difficulty) {
    switch (difficulty) {
      case 'knew':
        _knewIt++;
        break;
      case 'learning':
        _learning++;
        break;
      case 'hard':
        _needsWork++;
        break;
    }

    if (_currentIndex < _flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
        _flipController.reset();
      });
    } else {
      _showCompleteDialog();
    }
  }

  void _showCompleteDialog() {
    final total = _flashcards.length;
    final masteryPercent = total > 0 ? ((_knewIt / total) * 100).round() : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: masteryPercent >= 70
                      ? [AppColors.success, Colors.green.shade600]
                      : [AppColors.accentOrange, Colors.orange.shade600],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                masteryPercent >= 70 ? Icons.emoji_events_rounded : Icons.school_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              masteryPercent >= 70 ? 'Excellent!' : 'Good Progress!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${_flashcards.length} cards reviewed', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Knew it', _knewIt, AppColors.success),
                _buildStatColumn('Learning', _learning, AppColors.warning),
                _buildStatColumn('Review', _needsWork, AppColors.error),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mastery', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('$masteryPercent%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: masteryPercent / 100,
                    minHeight: 10,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      masteryPercent >= 70 ? AppColors.success : AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartReview();
            },
            child: const Text('Review Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAll();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
            child: const Text('New Deck', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(
            child: Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _restartReview() {
    setState(() {
      _currentIndex = 0;
      _showAnswer = false;
      _flipController.reset();
      _knewIt = 0;
      _learning = 0;
      _needsWork = 0;
    });
  }

  void _resetAll() {
    setState(() {
      _currentStep = 0;
      _currentIndex = 0;
      _showAnswer = false;
      _flipController.reset();
      _knewIt = 0;
      _learning = 0;
      _needsWork = 0;
      _flashcards = [];
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
        return _buildStudyStep();
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
        title: const Text('AI Flashcards'),
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
                      gradient: LinearGradient(
                        colors: [AppColors.accentOrange, AppColors.accentOrange.withOpacity(0.8)],
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
                          child: const Icon(Icons.style_rounded, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Create Flashcards',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Paste your notes and AI will create\nstudy cards for spaced repetition',
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
                            'AI will extract key terms, definitions, and concepts to create effective study cards.',
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
                          foregroundColor: AppColors.accentOrange,
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
                      hintText: 'Paste your lecture notes, textbook content, or study material here...\n\nFor example:\n"The cell membrane is composed of a phospholipid bilayer. Proteins embedded in this membrane serve various functions including transport and signaling..."',
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
                        borderSide: const BorderSide(color: AppColors.accentOrange, width: 2),
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
                    backgroundColor: AppColors.accentOrange,
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
        title: const Text('Configure Cards'),
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

            // Number of cards
            _buildSectionLabel('NUMBER OF FLASHCARDS'),
            const SizedBox(height: 12),
            Row(
              children: [5, 10, 15, 20].map((count) {
                final isSelected = _cardCount == count;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _cardCount = count),
                    child: Container(
                      margin: EdgeInsets.only(right: count != 20 ? 10 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accentOrange : AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.accentOrange : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'cards',
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

            const SizedBox(height: 40),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateFlashcards,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  disabledBackgroundColor: AppColors.accentOrange.withOpacity(0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                          SizedBox(width: 14),
                          Text('Creating your cards...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 22, color: Colors.white),
                          SizedBox(width: 10),
                          Text('Generate Flashcards', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 3: Study
  Widget _buildStudyStep() {
    if (_flashcards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: const Text('Flashcards')),
        body: const Center(child: Text('No flashcards available')),
      );
    }

    final flashcard = _flashcards[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Card ${_currentIndex + 1} of ${_flashcards.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: () {
              setState(() {
                _flashcards.shuffle();
                _currentIndex = 0;
                _showAnswer = false;
                _flipController.reset();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cards shuffled!'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMiniStat(Icons.check_circle, _knewIt, AppColors.success),
                    const SizedBox(width: 20),
                    _buildMiniStat(Icons.pending, _learning, AppColors.warning),
                    const SizedBox(width: 20),
                    _buildMiniStat(Icons.replay, _needsWork, AppColors.error),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _flashcards.length,
                    minHeight: 8,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
                  ),
                ),
              ],
            ),
          ),

          // Flashcard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * math.pi;
                    final transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle);

                    return Transform(
                      transform: transform,
                      alignment: Alignment.center,
                      child: angle >= math.pi / 2
                          ? Transform(
                              transform: Matrix4.identity()..rotateY(math.pi),
                              alignment: Alignment.center,
                              child: _buildCardBack(flashcard.answer),
                            )
                          : _buildCardFront(flashcard.question),
                    );
                  },
                ),
              ),
            ),
          ),

          // Actions
          if (_showAnswer)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const Text('How well did you know this?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDifficultyButton('Again', Icons.replay_rounded, AppColors.error, () => _nextCard('hard'))),
                        const SizedBox(width: 10),
                        Expanded(child: _buildDifficultyButton('Good', Icons.thumb_up_rounded, AppColors.warning, () => _nextCard('learning'))),
                        const SizedBox(width: 10),
                        Expanded(child: _buildDifficultyButton('Easy', Icons.check_circle_rounded, AppColors.success, () => _nextCard('knew'))),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _flipCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Show Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
      ],
    );
  }

  Widget _buildCardFront(String question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline_rounded, size: 16, color: AppColors.accentOrange),
                SizedBox(width: 6),
                Text('QUESTION', style: TextStyle(color: AppColors.accentOrange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  question,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.4, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.touch_app_rounded, color: AppColors.textTertiary, size: 28),
        ],
      ),
    );
  }

  Widget _buildCardBack(String answer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentOrange, AppColors.accentOrange.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.accentOrange.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb_rounded, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text('ANSWER', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  answer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.6, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
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

class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});
}
