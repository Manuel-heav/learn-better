import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/upload_card.dart';
import '../widgets/generated_insight.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _hasGenerated = false;
  bool _isGenerating = false;

  void _generateNotes() {
    setState(() {
      _isGenerating = true;
    });

    // Simulate generation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isGenerating = false;
        _hasGenerated = true;
      });
    });
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
              ),
              child: TextField(
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Paste lecture notes or start typing...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
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
              const GeneratedInsight(
                icon: Icons.notes_rounded,
                title: 'Summary',
                content:
                    'The lecture covers the fundamental principles of **Photosynthesis**, specifically explaining how chloroplasts absorb light energy. Key processes include the **Light-Dependent Reactions** which convert light into chemical energy, and the **Calvin Cycle** which uses CO₂ to produce **Oxygen** as a byproduct and generating **ATP** and **NADPH** for the Calvin Cycle.',
              ),

              const SizedBox(height: 16),

              // Key Concepts
              GeneratedInsight(
                icon: Icons.lightbulb_rounded,
                title: 'Key Concepts',
                content: null,
                children: [
                  _buildBullet('**Chloroplast**: The organelle where photosynthesis occurs, containing chlorophyll.'),
                  _buildBullet('**Light-Dependent Reactions**: Convert light energy into ATP and NADPH.'),
                  _buildBullet('**Calvin Cycle**: Uses CO₂ and energy to create glucose.'),
                ],
              ),
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

