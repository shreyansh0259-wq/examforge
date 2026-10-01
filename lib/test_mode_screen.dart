import 'package:flutter/material.dart';
import 'models/question.dart';
import 'test_instructions_screen.dart';
import 'services/pdf_service.dart';

class TestModeScreen extends StatelessWidget {
  final List<Question> questions;
  final int testTimeMinutes;

  const TestModeScreen({
    super.key,
    required this.questions,
    required this.testTimeMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Test Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'How do you want to take this test?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.computer),
                label: const Text(
                  'CBT Mode',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: questions.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestInstructionsScreen(
                              questions: questions,
                              testTimeMinutes: testTimeMinutes,
                            ),
                          ),
                        );
                      },
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 70,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text(
                  'PDF / OMR Mode',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: questions.isEmpty
                    ? null
                    : () async {
                        try {
                          final file = await PdfService().generateQuestionPaper(
                            questions: questions,
                            exam: 'ExamForge',
                          );

                          final omrFile =
                              await PdfService().generateOmrSheet(
                            questionCount: questions.length,
                          );

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Test PDF: ${file.path}\nOMR PDF: ${omrFile.path}',
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('PDF error: $e'),
                            ),
                          );
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
