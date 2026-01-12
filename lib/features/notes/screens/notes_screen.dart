import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/ai_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../widgets/upload_card.dart';
import '../widgets/generated_insight.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  bool _hasGenerated = false;
  bool _isGenerating = false;
  final TextEditingController _textController = TextEditingController();
  
  String _summary = '';
  List<String> _keyConcepts = [];
  List<String> _importantTerms = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _generateNotes() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });
    
    ref.read(aiNotesLoadingProvider.notifier).state = true;
    ref.read(aiNotesErrorProvider.notifier).state = null;

    try {
      // Generate notes using AI
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.generateNoteSummary(_textController.text.trim());
      
      setState(() {
        _summary = result['summary'] ?? '';
        _keyConcepts = List<String>.from(result['keyConcepts'] ?? []);
        _importantTerms = List<String>.from(result['importantTerms'] ?? []);
        _hasGenerated = true;
        _isGenerating = false;
      });
      
      // Save to Firestore
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser != null) {
        try {
          final firestoreService = FirestoreService();
          await firestoreService.saveNote(
            uid: currentUser.uid,
            title: _textController.text.trim().substring(0, 50).trim() + '...',
            content: _textController.text.trim(),
            summary: _summary,
          );
        } catch (e) {
          print('Failed to save note to Firestore: $e');
          // Non-critical error, continue anyway
        }
      }
      
    } catch (e) {
      ref.read(aiNotesErrorProvider.notifier).state = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() {
        _isGenerating = false;
      });
    } finally {
      ref.read(aiNotesLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notes & Summaries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Section
            Row(
              children: [
                Expanded(
                  child: UploadCard(
                    icon: Icons.upload_file_rounded,
                    label: 'Upload PDF',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PDF upload coming soon'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: UploadCard(
                    icon: Icons.scanner_rounded,
                    label: 'Scan Text',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Text scanning coming soon'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Text Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _textController.text.isNotEmpty
                      ? AppColors.primaryBlue.withOpacity(0.3)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 6,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Paste lecture notes or start typing...\n\nExample: Photosynthesis is the process by which plants convert light energy into chemical energy...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateNotes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Generating...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Generate',
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

            if (_hasGenerated) ...[
              const SizedBox(height: 32),

              // Generated Insights Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Generated Insights',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.primaryBlue,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Summary Section
              if (_summary.isNotEmpty)
                GeneratedInsight(
                  icon: Icons.notes_rounded,
                  title: 'Summary',
                  content: _summary,
                ),

              if (_keyConcepts.isNotEmpty) ...[
                const SizedBox(height: 16),
                // Key Concepts
                GeneratedInsight(
                  icon: Icons.lightbulb_rounded,
                  title: 'Key Concepts',
                  content: null,
                  children: _keyConcepts.map((concept) => _buildBullet(concept)).toList(),
                ),
              ],

              if (_importantTerms.isNotEmpty) ...[
                const SizedBox(height: 16),
                // Important Terms
                GeneratedInsight(
                  icon: Icons.auto_stories_rounded,
                  title: 'Important Terms',
                  content: null,
                  children: _importantTerms.map((term) => _buildBullet(term)).toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

