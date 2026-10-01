import 'package:flutter/material.dart';
import 'models/question.dart';
import 'test_screen.dart';

class TestInstructionsScreen extends StatelessWidget {
  final List<Question> questions;
  final int testTimeMinutes;
  final String exam;

  const TestInstructionsScreen({
    super.key,
    required this.questions,
    required this.testTimeMinutes,
    this.exam = 'NEET',
  });

  String get effectiveDifficulty {
    if (questions.isEmpty) return 'Mixed';

    final counts = <String, int>{};

    for (final question in questions) {
      counts[question.difficulty] =
          (counts[question.difficulty] ?? 0) + 1;
    }

    if (counts.length == 1) {
      return counts.keys.first;
    }

    return 'Mixed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Instructions'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'General Instructions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _infoCard(
                  'Test Overview',
                  'Total Questions: ${questions.length}\n'
                  'Test Duration: $testTimeMinutes minutes',
                ),

                const SizedBox(height: 16),

                const Text(
                  'Before you begin',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                _instruction(
                  '1',
                  'Read each question carefully before selecting an answer.',
                ),
                _instruction(
                  '2',
                  'Select one option for each question.',
                ),
                _instruction(
                  '3',
                  'Use Save & Next to save your response and move forward.',
                ),
                _instruction(
                  '4',
                  'Use Mark for Review when you want to revisit a question.',
                ),
                _instruction(
                  '5',
                  'Use the Question Palette to jump directly to any question.',
                ),
                _instruction(
                  '6',
                  'You can change your answer before submitting the test.',
                ),
                _instruction(
                  '7',
                  'Submit the test when you have finished reviewing your answers.',
                ),

                const SizedBox(height: 18),

                const Text(
                  'Question Status',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                _statusRow(
                  Icons.circle,
                  'Answered',
                ),
                _statusRow(
                  Icons.circle_outlined,
                  'Not Answered',
                ),
                _statusRow(
                  Icons.bookmark,
                  'Marked for Review',
                ),

                const SizedBox(height: 18),

                const Text(
                  'Important',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Once the test is submitted, you will be taken to the result screen.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: questions.isEmpty
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestScreen(
                                questions: questions,
                                testTimeMinutes: testTimeMinutes,
                                difficulty: effectiveDifficulty,
                                exam: exam,
                              ),
                            ),
                          );
                        },
                  child: const Text(
                    'I am ready to begin',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _instruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            child: Text(number),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoCard(String title, String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _statusRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
