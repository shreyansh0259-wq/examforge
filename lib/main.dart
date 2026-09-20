import 'package:flutter/material.dart';
import 'importer/question_importer.dart';
import 'services/syllabus_service.dart';
import 'models/test_selection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  QuestionImporter().importFromAsset("assets/data/questions/neet/physics.json");
  runApp(const ExamForgeApp());
}

class ExamForgeApp extends StatelessWidget {
  const ExamForgeApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExamForge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ExamForge')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TestSetupScreen(),
              ),
            );
          },
          child: const Text('Create Your Custom Test'),
        ),
      ),
    );
  }
}

class TestSetupScreen extends StatefulWidget {
  const TestSetupScreen({super.key});

  @override
  State<TestSetupScreen> createState() => _TestSetupScreenState();
}

class _TestSetupScreenState extends State<TestSetupScreen> {
  bool canContinue() {
    if (selectedSubjects.isEmpty) {
      return false;
    }

    for (final subject in selectedSubjects) {
      final selection = testSelection.getOrCreate(subject);

      if (selection.chapter == null) {
        return false;
      }

      if (subjectLoading[subject] == true) {
        return false;
      }

      if (subjectErrors[subject] != null) {
        return false;
      }
    }

    return true;
  }
  String selectedExam = 'NEET';

  int questionCount = 50;
  int testTime = 60;

  final List<String> exams = [
    'NEET',
    'JEE Main',
    'JEE Advanced',
    'UPSC',
  ];

  final Map<String, List<String>> subjects = {
    'NEET': ['Physics', 'Chemistry', 'Biology'],
    'JEE Main': ['Physics', 'Chemistry', 'Mathematics'],
    'JEE Advanced': ['Physics', 'Chemistry', 'Mathematics'],
    'UPSC': [
      'History',
      'Geography',
      'Polity',
      'Economy',
      'Science',
    ],
  };

  Set<String> selectedSubjects = {'Physics', 'Chemistry', 'Biology'};

  final SyllabusService _syllabusService = SyllabusService();

  final TestSelection testSelection = TestSelection();


  final Map<String, List<Map<String, dynamic>>> subjectChapters = {};
  final Map<String, bool> subjectLoading = {};
  final Map<String, String?> subjectErrors = {};

  Future<void> loadChapters(String subject) async {
    setState(() {
      subjectLoading[subject] = true;
      subjectErrors[subject] = null;
    });

    try {
      final result = await _syllabusService.getUnits(
        selectedExam,
        subject,
      );

      if (!mounted) return;

      setState(() {
        subjectChapters[subject] = result;
        subjectLoading[subject] = false;
      });
    } catch (e) {
      debugPrint('loadChapters error for $subject: $e');

      if (!mounted) return;

      setState(() {
        subjectChapters[subject] = [];
        subjectLoading[subject] = false;
        subjectErrors[subject] = e.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    for (final subject in selectedSubjects) {
      testSelection.selectSubject(subject);
    }

    for (final subject in selectedSubjects) {
      loadChapters(subject);
    }
  }


  void changeExam(String exam) {
    setState(() {
      selectedExam = exam;
      testSelection.clear();
      selectedSubjects = subjects[exam]!.toSet();

      for (final subject in selectedSubjects) {
        testSelection.selectSubject(subject);
      }

    });

    loadChapters(subjects[exam]!.first);
  }

  @override
  Widget build(BuildContext context) {
    final currentSubjects = subjects[selectedExam]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Select Exam',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedExam,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Exam',
              ),
              items: exams.map((exam) {
                return DropdownMenuItem(
                  value: exam,
                  child: Text(exam),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  changeExam(value);
                }
              },
            ),

            const SizedBox(height: 30),

            const Text(
              'Select Subjects',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...currentSubjects.map((subject) {
              return CheckboxListTile(
                title: Text(subject),
                value: selectedSubjects.contains(subject),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedSubjects.add(subject);
                      testSelection.selectSubject(subject);
                    } else {
                      selectedSubjects.remove(subject);
                      testSelection.removeSubject(subject);
                    }
                  });
                },
              );
            }),

            const SizedBox(height: 20),

              const Text(
                'Select Chapters & Topics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...selectedSubjects.map((subject) {
                final selection = testSelection.getOrCreate(subject);
                final subjectChapterList = subjectChapters[subject] ?? [];
                final isLoading = subjectLoading[subject] ?? false;
                final error = subjectErrors[subject];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (isLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else if (error != null)
                          Text(
                            'Chapter loading error: $error',
                            style: const TextStyle(color: Colors.red),
                          )
                        else
                          DropdownButtonFormField<String>(
                            value: selection.chapter,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Chapter',
                            ),
                            items: subjectChapterList.map((chapter) {
                              final name = chapter['name'] as String;
                              return DropdownMenuItem<String>(
                                value: name,
                                child: Text(name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selection.chapter = value;
                                selection.topics.clear();
                              });
                            },
                          ),

                        if (selection.chapter != null) ...[
                          const SizedBox(height: 15),

                          const Text(
                            'Topics',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          ...subjectChapterList
                              .where(
                                (chapter) =>
                                    chapter['name'] == selection.chapter,
                              )
                              .expand(
                                (chapter) =>
                                    List<String>.from(
                                  chapter['topics'] ?? [],
                                ),
                              )
                              .map(
                                (topic) => CheckboxListTile(
                                  title: Text(topic),
                                  value: selection.topics.contains(topic),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        selection.topics.add(topic);
                                      } else {
                                        selection.topics.remove(topic);
                                      }
                                    });
                                  },
                                ),
                              ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
                const Text(
              'Number of Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text('$questionCount Questions'),

            Slider(
              min: 1,
              max: 500,
              divisions: 499,
              value: questionCount.toDouble(),
              label: '$questionCount',
              onChanged: (value) {
                setState(() {
                  questionCount = value.round();
                });
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Test Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text('$testTime Minutes'),

            Slider(
              min: 5,
              max: 300,
              divisions: 59,
              value: testTime.toDouble(),
              label: '$testTime min',
              onChanged: (value) {
                setState(() {
                  testTime = value.round();
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canContinue()
                    ? () {}
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
