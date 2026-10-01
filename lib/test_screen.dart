import 'dart:async';
import 'package:flutter/material.dart';
import 'models/question.dart';
import 'result_screen.dart';

class TestScreen extends StatefulWidget {
  final List<Question> questions;
  final int testTimeMinutes;
  final String difficulty;

  const TestScreen({
    super.key,
    required this.questions,
    required this.testTimeMinutes,
    this.difficulty = 'Mixed',
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int currentIndex = 0;

  final Map<int, int> selectedAnswers = {};
  final Set<int> markedForReview = {};

  Timer? _timer;
  late int remainingSeconds;

  int get answeredCount => selectedAnswers.length;

  @override
  void initState() {
    super.initState();

    remainingSeconds = widget.testTimeMinutes * 60;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        if (remainingSeconds <= 1) {
          _timer?.cancel();
          setState(() {
            remainingSeconds = 0;
          });
          submitTest(autoSubmitted: true);
          return;
        }

        setState(() {
          remainingSeconds--;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= widget.questions.length) return;

    setState(() {
      currentIndex = index;
    });
  }

  void selectAnswer(int optionIndex) {
    setState(() {
      selectedAnswers[currentIndex] = optionIndex;
    });
  }

  void saveAndNext() {
    if (currentIndex < widget.questions.length - 1) {
      goToQuestion(currentIndex + 1);
    }
  }

  void toggleReview() {
    setState(() {
      if (markedForReview.contains(currentIndex)) {
        markedForReview.remove(currentIndex);
      } else {
        markedForReview.add(currentIndex);
      }
    });
  }

  void submitTest({bool autoSubmitted = false}) {
    _timer?.cancel();

    if (!autoSubmitted) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Submit Test'),
            content: Text(
              'Answered: $answeredCount/${widget.questions.length}\n'
              'Marked for review: ${markedForReview.length}\n\n'
              'Are you sure you want to submit?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _showSubmittedMessage();
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
      return;
    }

    _showSubmittedMessage(
      message: 'Time is over. Test submitted automatically.',
    );
  }

  void _showSubmittedMessage({
    String message = 'Test submitted.',
  }) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          questions: widget.questions,
          selectedAnswers: selectedAnswers,
          difficulty: widget.difficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ExamForge Test'),
        ),
        body: const Center(
          child: Text('No questions available for this test.'),
        ),
      );
    }

    final question = widget.questions[currentIndex];
    final selectedAnswer = selectedAnswers[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${currentIndex + 1}/${widget.questions.length}',
        ),
        actions: [
          IconButton(
            tooltip: 'Submit Test',
            onPressed: () => submitTest(),
            icon: const Icon(Icons.check_circle_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Material(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined),
                  const SizedBox(width: 6),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: remainingSeconds <= 300
                          ? Colors.red
                          : null,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Answered $answeredCount/${widget.questions.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Question ${currentIndex + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                ...List.generate(
                  question.options.length,
                  (index) {
                    final isSelected = selectedAnswer == index;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: RadioListTile<int>(
                        value: index,
                        groupValue: selectedAnswer,
                        onChanged: (_) => selectAnswer(index),
                        title: Text(
                          '${String.fromCharCode(65 + index)}. '
                          '${question.options[index]}',
                        ),
                        selected: isSelected,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                OutlinedButton.icon(
                  onPressed: toggleReview,
                  icon: Icon(
                    markedForReview.contains(currentIndex)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                  label: Text(
                    markedForReview.contains(currentIndex)
                        ? 'Marked for Review'
                        : 'Mark for Review',
                  ),
                ),
              ],
            ),
          ),

          Material(
            elevation: 4,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: currentIndex > 0
                            ? () => goToQuestion(currentIndex - 1)
                            : null,
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: currentIndex <
                                widget.questions.length - 1
                            ? saveAndNext
                            : () => submitTest(),
                        child: Text(
                          currentIndex <
                                  widget.questions.length - 1
                              ? 'Save & Next'
                              : 'Submit',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const ListTile(
                title: Text(
                  'Question Palette',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: widget.questions.length,
                  itemBuilder: (context, index) {
                    final isCurrent = index == currentIndex;
                    final isAnswered =
                        selectedAnswers.containsKey(index);
                    final isReview =
                        markedForReview.contains(index);

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        goToQuestion(index);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: isCurrent ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: isReview
                                ? TextDecoration.underline
                                : null,
                            color: isAnswered ? Colors.green : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
