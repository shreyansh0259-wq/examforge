import 'package:flutter/material.dart';
import 'models/question.dart';
import 'models/topic_performance.dart';
import 'models/subject_performance.dart';
import 'models/difficulty_analysis.dart';

class ResultScreen extends StatelessWidget {
  final List<Question> questions;
  final Map<int, int> selectedAnswers;
  final String difficulty;

  const ResultScreen({
    super.key,
    required this.questions,
    required this.selectedAnswers,
    this.difficulty = 'Mixed',
  });

  int get attempted => selectedAnswers.length;

  int get correct {
    var count = 0;

    for (final entry in selectedAnswers.entries) {
      final index = entry.key;
      final selected = entry.value;

      if (index >= 0 &&
          index < questions.length &&
          questions[index].correctAnswer == selected) {
        count++;
      }
    }

    return count;
  }

  int get incorrect => attempted - correct;

  int get unanswered => questions.length - attempted;

  // NEET-style scoring for the current test result.
  // This will later be replaced by exam-specific scoring rules.
  int get score => (correct * 4) - incorrect;

  DifficultyAnalysis get difficultyAnalysis {
    return DifficultyAnalysis.fromDifficulty(difficulty);
  }

  int get equivalentScore {
    return difficultyAnalysis
        .getEquivalentScore(score)
        .round();
  }

  double get accuracy {
    if (attempted == 0) return 0;
    return (correct / attempted) * 100;
  }

  List<SubjectPerformance> get subjectPerformances {
    final map = <String, SubjectPerformance>{};

    for (final entry in selectedAnswers.entries) {
      final index = entry.key;
      final selected = entry.value;

      if (index < 0 || index >= questions.length) continue;

      final question = questions[index];

      final performance = map.putIfAbsent(
        question.subject,
        () => SubjectPerformance(subject: question.subject),
      );

      performance.attempted++;

      if (selected == question.correctAnswer) {
        performance.correct++;
      } else {
        performance.incorrect++;
      }
    }

    final result = map.values.toList();

    result.sort(
      (a, b) => a.accuracy.compareTo(b.accuracy),
    );

    return result;
  }

  List<TopicPerformance> get topicPerformances {
    final map = <String, TopicPerformance>{};

    for (final entry in selectedAnswers.entries) {
      final index = entry.key;
      final selected = entry.value;

      if (index < 0 || index >= questions.length) continue;

      final question = questions[index];

      final key =
          '${question.subject}|${question.chapter}|${question.topic}';

      final performance = map.putIfAbsent(
        key,
        () => TopicPerformance(
          subject: question.subject,
          chapter: question.chapter,
          topic: question.topic,
        ),
      );

      performance.attempted++;

      if (selected == question.correctAnswer) {
        performance.correct++;
      } else {
        performance.incorrect++;
      }
    }

    final result = map.values.toList();

    result.sort(
      (a, b) => a.accuracy.compareTo(b.accuracy),
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(
            Icons.assessment_outlined,
            size: 64,
          ),

          const SizedBox(height: 12),

          const Center(
            child: Text(
              'Test Completed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),

          _scoreCard(),

          const SizedBox(height: 20),

          _resultCard(),

          const SizedBox(height: 24),

          _collegeAnalysisCard(),

          const SizedBox(height: 24),

          _scoreSimulator(),

          const SizedBox(height: 24),

          _weakTopicsCard(),

          const SizedBox(height: 24),

          _subjectPerformanceCard(),

          const SizedBox(height: 24),

          const Text(
            'Question Review',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ...List.generate(
            questions.length,
            (index) {
              final question = questions[index];
              final selected = selectedAnswers[index];

              final isCorrect =
                  selected != null &&
                  selected == question.correctAnswer;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    selected == null
                        ? 'Not Answered'
                        : isCorrect
                            ? 'Correct'
                            : 'Incorrect',
                  ),
                  subtitle: Text(
                    selected == null
                        ? 'No option selected'
                        : 'Your answer: '
                            '${String.fromCharCode(65 + selected)}\n'
                            'Correct answer: '
                            '${String.fromCharCode(
                              65 + question.correctAnswer,
                            )}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                );
              },
              child: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Score',
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 6),
            Text(
              '$score',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Test Difficulty: $difficulty',
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 4),

            Text(
              'Estimated Equivalent Score: $equivalentScore',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _resultRow(
              'Total Questions',
              questions.length.toString(),
            ),
            _resultRow(
              'Attempted',
              attempted.toString(),
            ),
            _resultRow(
              'Correct',
              correct.toString(),
            ),
            _resultRow(
              'Incorrect',
              incorrect.toString(),
            ),
            _resultRow(
              'Unanswered',
              unanswered.toString(),
            ),
            _resultRow(
              'Accuracy',
              '${accuracy.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _collegeAnalysisCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'College & Score Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'Expected college analysis will be calculated from '
              'verified, year-wise cutoff data.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 14),

            _analysisRow(
              'Current score',
              '$score marks',
            ),

            _analysisRow(
              'Cutoff data',
              'Not connected yet',
            ),

            const SizedBox(height: 10),

            const Text(
              'No college prediction is shown until verified '
              'cutoff data is available for the selected exam, '
              'year, category and counselling context.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreSimulator() {
    final improvements = [5, 10, 20, 30];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Score Improvement Simulator',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...improvements.map(
              (marks) => _analysisRow(
                '+$marks marks',
                '${score + marks} marks',
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'This simulator shows score changes only. '
              'College changes will be calculated after verified '
              'cutoff data is connected.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectPerformanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subject Performance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...subjectPerformances.map(
              (subject) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(subject.subject),
                subtitle: Text(
                  'Attempted: ${subject.attempted} • '
                  'Correct: ${subject.correct} • '
                  'Incorrect: ${subject.incorrect}',
                ),
                trailing: Text(
                  '${subject.accuracy.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weakTopicsCard() {
    final weakTopics =
        topicPerformances.where((topic) => topic.isWeak).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weak Topic Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (weakTopics.isEmpty)
              const Text(
                'No weak topics identified from attempted questions.',
                style: TextStyle(fontSize: 15),
              )
            else
              ...weakTopics.map(
                (topic) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.warning_amber_rounded),
                  title: Text(topic.topic),
                  subtitle: Text(
                    '${topic.subject} • ${topic.chapter}\n'
                    'Accuracy: ${topic.accuracy.toStringAsFixed(1)}% '
                    '• Correct: ${topic.correct}/${topic.attempted}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _analysisRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _resultRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
