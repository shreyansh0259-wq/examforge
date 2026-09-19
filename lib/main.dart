import 'package:flutter/material.dart';
import 'importer/question_importer.dart';
import 'services/syllabus_service.dart';

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

  void changeExam(String exam) {
    setState(() {
      selectedExam = exam;
      selectedSubjects = subjects[exam]!.toSet();
    });
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
                    } else {
                      selectedSubjects.remove(subject);
                    }
                  });
                },
              );
            }),

            const SizedBox(height: 20),

            const Text(
              const Text(
                'Select Chapter',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              if (loadingChapters)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                DropdownButtonFormField<String>(
                  value: selectedChapter,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Chapter',
                  ),
                  items: chapters.map((chapter) {
                    final name = chapter['name'] as String;
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedChapter = value;
                      selectedTopics = {};
                    });
                  },
                ),

              if (selectedChapter != null) ...[
                const SizedBox(height: 20),

                const Text(
                  'Select Topics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                ...chapters
                    .where((chapter) => chapter['name'] == selectedChapter)
                    .expand(
                      (chapter) =>
                          List<String>.from(chapter['topics'] ?? []),
                    )
                    .map(
                      (topic) => CheckboxListTile(
                        title: Text(topic),
                        value: selectedTopics.contains(topic),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedTopics.add(topic);
                            } else {
                              selectedTopics.remove(topic);
                            }
                          });
                        },
                      ),
                    ),
              ],

              const SizedBox(height: 20),
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
                onPressed: selectedSubjects.isEmpty
                    ? null
                    : () {},
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
