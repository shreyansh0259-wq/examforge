
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';


import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ExamForgeApp());
}

class ExamInfo {
  final String name;
  final String subtitle;
  final IconData icon;
  final List<SubjectInfo> subjects;

  const ExamInfo({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.subjects,
  });
}

class SubjectInfo {
  final String name;
  final List<String> chapters;

  const SubjectInfo({
    required this.name,
    required this.chapters,
  });
}

class Exams {
  static const List<ExamInfo> all = [
    ExamInfo(
      name: 'NEET',
      subtitle: 'Medical Entrance',
      icon: Icons.biotech,
      subjects: [
        SubjectInfo(
          name: 'Physics',
          chapters: [
            'Units & Measurements',
            'Kinematics',
            'Laws of Motion',
            'Work, Energy & Power',
            'Rotational Motion',
            'Gravitation',
            'Thermodynamics',
            'Electrostatics',
            'Current Electricity',
            'Magnetism',
            'Optics',
            'Modern Physics',
          ],
        ),
        SubjectInfo(
          name: 'Chemistry',
          chapters: [
            'Some Basic Concepts',
            'Atomic Structure',
            'Chemical Bonding',
            'Thermodynamics',
            'Equilibrium',
            'Electrochemistry',
            'Chemical Kinetics',
            'Organic Chemistry',
            'Biomolecules',
            'Coordination Compounds',
          ],
        ),
        SubjectInfo(
          name: 'Biology',
          chapters: [
            'The Living World',
            'Biological Classification',
            'Plant Kingdom',
            'Animal Kingdom',
            'Cell Structure',
            'Biomolecules',
            'Plant Physiology',
            'Human Physiology',
            'Genetics',
            'Evolution',
            'Ecology',
            'Human Health & Disease',
          ],
        ),
      ],
    ),
    ExamInfo(
      name: 'JEE Main',
      subtitle: 'Engineering Entrance',
      icon: Icons.engineering,
      subjects: [
        SubjectInfo(
          name: 'Physics',
          chapters: [
            'Units & Dimensions',
            'Kinematics',
            'Newton Laws',
            'Work Power Energy',
            'Rotational Motion',
            'Properties of Matter',
            'Thermodynamics',
            'Electrostatics',
            'Current Electricity',
            'Magnetism',
            'Ray Optics',
            'Modern Physics',
          ],
        ),
        SubjectInfo(
          name: 'Chemistry',
          chapters: [
            'Mole Concept',
            'Atomic Structure',
            'Chemical Bonding',
            'Thermodynamics',
            'Equilibrium',
            'Redox Reactions',
            'Electrochemistry',
            'Chemical Kinetics',
            'Organic Chemistry',
            'Coordination Chemistry',
          ],
        ),
        SubjectInfo(
          name: 'Mathematics',
          chapters: [
            'Sets & Relations',
            'Quadratic Equations',
            'Sequence & Series',
            'Binomial Theorem',
            'Permutation & Combination',
            'Straight Lines',
            'Circles',
            'Limits',
            'Differentiation',
            'Integration',
            'Probability',
            'Vectors & 3D',
          ],
        ),
      ],
    ),
    ExamInfo(
      name: 'JEE Advanced',
      subtitle: 'Advanced Engineering',
      icon: Icons.science,
      subjects: [
        SubjectInfo(
          name: 'Physics',
          chapters: [
            'Mechanics',
            'Rotational Motion',
            'Fluid Mechanics',
            'Thermodynamics',
            'Electrostatics',
            'Current Electricity',
            'Magnetism',
            'Optics',
            'Modern Physics',
          ],
        ),
        SubjectInfo(
          name: 'Chemistry',
          chapters: [
            'Physical Chemistry',
            'Inorganic Chemistry',
            'Organic Chemistry',
            'Chemical Bonding',
            'Coordination Compounds',
            'Thermodynamics',
            'Equilibrium',
            'Electrochemistry',
          ],
        ),
        SubjectInfo(
          name: 'Mathematics',
          chapters: [
            'Algebra',
            'Coordinate Geometry',
            'Calculus',
            'Vectors',
            '3D Geometry',
            'Probability',
            'Complex Numbers',
            'Matrices & Determinants',
          ],
        ),
      ],
    ),
    ExamInfo(
      name: 'UPSC',
      subtitle: 'Civil Services',
      icon: Icons.account_balance,
      subjects: [
        SubjectInfo(
          name: 'History',
          chapters: [
            'Ancient India',
            'Medieval India',
            'Modern India',
            'Art & Culture',
          ],
        ),
        SubjectInfo(
          name: 'Geography',
          chapters: [
            'Physical Geography',
            'Indian Geography',
            'World Geography',
            'Economic Geography',
          ],
        ),
        SubjectInfo(
          name: 'Polity',
          chapters: [
            'Constitution',
            'Fundamental Rights',
            'Parliament',
            'Judiciary',
            'Federalism',
          ],
        ),
        SubjectInfo(
          name: 'Economy',
          chapters: [
            'Basic Economics',
            'Banking',
            'Fiscal Policy',
            'Monetary Policy',
            'Budget',
          ],
        ),
      ],
    ),
  ];
}

class Question {
  final String id;
  final String text;
  final String chapter;
  final String difficulty;
  final List<String> options;
  final int correct;

  const Question(
    this.id,
    this.text,
    this.chapter,
    this.difficulty,
    this.options,
    this.correct,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'chapter': chapter,
        'difficulty': difficulty,
        'options': options,
        'correct': correct,
      };

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        j['id'] as String,
        j['text'] as String,
        j['chapter'] as String,
        j['difficulty'] as String,
        List<String>.from(j['options'] as List),
        j['correct'] as int,
      );
}
class TestConfig {
  final String exam;
  final Map<String, List<String>> chapters;
  final int count;
  final int minutes;
  final String difficulty;

  const TestConfig({
    required this.exam,
    required this.chapters,
    required this.count,
    required this.minutes,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
        'exam': exam,
        'chapters': chapters,
        'count': count,
        'minutes': minutes,
        'difficulty': difficulty,
      };

  factory TestConfig.fromJson(Map<String, dynamic> j) => TestConfig(
        exam: j['exam'] as String,
        chapters: (j['chapters'] as Map).map<String, List<String>>(
          (k, v) => MapEntry(
            k.toString(),
            List<String>.from(v as List),
          ),
        ),
        count: j['count'] as int,
        minutes: j['minutes'] as int,
        difficulty: j['difficulty'] as String,
      );
}

class Attempt {
  final String id;
  final DateTime date;
  final TestConfig config;
  final List<Question> questions;
  final List<int?> answers;
  final int score;
  final int correct;
  final int wrong;
  final int skipped;

  const Attempt({
    required this.id,
    required this.date,
    required this.config,
    required this.questions,
    required this.answers,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.skipped,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'config': config.toJson(),
        'questions': questions.map((q) => q.toJson()).toList(),
        'answers': answers,
        'score': score,
        'correct': correct,
        'wrong': wrong,
        'skipped': skipped,
      };

  factory Attempt.fromJson(Map<String, dynamic> j) => Attempt(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        config: TestConfig.fromJson(
          Map<String, dynamic>.from(j['config'] as Map),
        ),
        questions: (j['questions'] as List)
            .map(
              (q) => Question.fromJson(
                Map<String, dynamic>.from(q as Map),
              ),
            )
            .toList(),
        answers: (j['answers'] as List)
            .map<int?>((x) => x == null ? null : x as int)
            .toList(),
        score: j['score'] as int,
        correct: j['correct'] as int,
        wrong: j['wrong'] as int,
        skipped: j['skipped'] as int,
      );
}

class HistoryStore {
  static List<Attempt> attempts = [];

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('attempts');

    if (raw == null || raw.isEmpty) {
      attempts = [];
      return;
    }

    try {
      final data = jsonDecode(raw) as List;

      attempts = data
          .map(
            (x) => Attempt.fromJson(
              Map<String, dynamic>.from(x as Map),
            ),
          )
          .toList();
    } catch (_) {
      attempts = [];
    }
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    final data = attempts.map((a) => a.toJson()).toList();

    await prefs.setString(
      'attempts',
      jsonEncode(data),
    );
  }

  static Future<void> add(Attempt attempt) async {
    attempts.insert(0, attempt);

    if (attempts.length > 50) {
      attempts = attempts.take(50).toList();
    }

    await save();
  }
}
List<Question> generate(TestConfig c) {
  final rng = Random();

  final Set<String> selected =
      c.chapters.values.expand((x) => x).toSet();

  final Set<String> difficulties =
      c.difficulty == 'Mixed'
          ? {'Easy', 'Medium', 'Hard'}
          : {c.difficulty};

  final pool = <Question>[];

  for (final ch in selected) {
    for (final d in difficulties) {
      for (int n = 0; n < 4; n++) {
        pool.add(
          Question(
            '${ch}_${d}_$n',
            'Practice question from $ch at $d difficulty. Which option is correct?',
            ch,
            d,
            const [
              'Option A',
              'Option B',
              'Option C',
              'Option D',
            ],
            (n + d.length + ch.length) % 4,
          ),
        );
      }
    }
  }

  pool.shuffle(rng);

  final result = <Question>[];

  final used = HistoryStore.attempts
      .expand((a) => a.questions.map((q) => q.id))
      .toSet();

  result.addAll(
    pool.where((q) => !used.contains(q.id)),
  );

  if (result.length < c.count) {
    result.addAll(
      pool.where((q) => used.contains(q.id)),
    );
  }

  return result.take(c.count).toList();
}

class ExamForgeApp extends StatelessWidget {
  const ExamForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExamForge',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    HistoryStore.load().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exams = Exams.all;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ExamForge',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Custom Test Generator',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your own practice test by subject, chapter and difficulty.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Choose Exam',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...exams.map(
            (e) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(e.icon),
                ),
                title: Text(
                  e.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(e.subtitle),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BuilderScreen(
                        exam: e,
                      ),
                    ),
                  );
                },
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }
}
class BuilderScreen extends StatefulWidget {
  final ExamInfo exam;

  const BuilderScreen({
    super.key,
    required this.exam,
  });

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends State<BuilderScreen> {
  final Map<String, List<String>> selected = {};

  int questionCount = 20;
  int minutes = 30;
  String difficulty = 'Mixed';

  @override
  void initState() {
    super.initState();

    for (final subject in widget.exam.subjects) {
      selected[subject.name] = [];
    }
  }

  void toggleAll(SubjectInfo subject) {
    setState(() {
      final current = selected[subject.name] ?? [];

      if (current.length == subject.chapters.length) {
        selected[subject.name] = [];
      } else {
        selected[subject.name] = List<String>.from(
          subject.chapters,
        );
      }
    });
  }

  void startTest() {
    final hasChapter = selected.values.any(
      (list) => list.isNotEmpty,
    );

    if (!hasChapter) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one chapter.',
          ),
        ),
      );
      return;
    }

    final config = TestConfig(
      exam: widget.exam.name,
      chapters: Map<String, List<String>>.from(
        selected.map(
          (key, value) => MapEntry(
            key,
            List<String>.from(value),
          ),
        ),
      ),
      count: questionCount,
      minutes: minutes,
      difficulty: difficulty,
    );

    final questions = generate(config);

    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No questions available for this selection.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestScreen(
          config: config,
          questions: questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.exam.name} Test Builder',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Questions: $questionCount',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Slider(
                    value: questionCount.toDouble(),
                    min: 5,
                    max: 100,
                    divisions: 19,
                    label: '$questionCount',
                    onChanged: (v) {
                      setState(() {
                        questionCount = v.round();
                      });
                    },
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Time: $minutes minutes',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Slider(
                    value: minutes.toDouble(),
                    min: 5,
                    max: 180,
                    divisions: 35,
                    label: '$minutes min',
                    onChanged: (v) {
                      setState(() {
                        minutes = v.round();
                      });
                    },
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Difficulty',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),

                  DropdownButtonFormField<String>(
                    initialValue: difficulty,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Easy',
                        child: Text('Easy'),
                      ),
                      DropdownMenuItem(
                        value: 'Medium',
                        child: Text('Medium'),
                      ),
                      DropdownMenuItem(
                        value: 'Hard',
                        child: Text('Hard'),
                      ),
                      DropdownMenuItem(
                        value: 'Mixed',
                        child: Text('Mixed'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;

                      setState(() {
                        difficulty = v;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Select Chapters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          ...widget.exam.subjects.map(
            (subject) {
              final current =
                  selected[subject.name] ?? [];

              return Card(
                child: ExpansionTile(
                  title: Text(
                    subject.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    '${current.length}/${subject.chapters.length} selected',
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => toggleAll(subject),
                        child: Text(
                          current.length ==
                                  subject.chapters.length
                              ? 'Clear All'
                              : 'Select All',
                        ),
                      ),
                    ),
                    ...subject.chapters.map(
                      (ch) {
                        final isSelected =
                            current.contains(ch);

                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(ch),
                          controlAffinity:
                              ListTileControlAffinity.leading,
                          onChanged: (v) {
                            final List<String> l = [
                              ...(selected[subject.name] ??
                                  const <String>[])
                            ];

                            if (v == true) {
                              if (!l.contains(ch)) {
                                l.add(ch);
                              }
                            } else {
                              l.remove(ch);
                            }

                            setState(() {
                              selected[subject.name] = l;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ).toList(),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: startTest,
            icon: const Icon(Icons.play_arrow),
            label: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 14,
              ),
              child: Text(
                'Generate Test',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
class TestScreen extends StatefulWidget {
  final TestConfig config;
  final List<Question> questions;

  const TestScreen({
    super.key,
    required this.config,
    required this.questions,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  Timer? timer;

  late int remaining;
  late List<int?> selected;
  late List<bool> marked;

  int current = 0;

  List<Question> get questions => widget.questions;

  @override
  void initState() {
    super.initState();

    remaining = widget.config.minutes * 60;

    selected = List<int?>.filled(
      questions.length,
      null,
    );

    marked = List<bool>.filled(
      questions.length,
      false,
    );

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        if (!mounted) {
          t.cancel();
          return;
        }

        if (remaining <= 0) {
          t.cancel();
          submit();
          return;
        }

        setState(() {
          remaining--;
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String get timeText {
    final h = remaining ~/ 3600;
    final m = (remaining % 3600) ~/ 60;
    final s = remaining % 60;

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }

    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  void selectAnswer(int index) {
    setState(() {
      selected[current] = index;
    });
  }

  void nextQuestion() {
    if (current < questions.length - 1) {
      setState(() {
        current++;
      });
    }
  }

  void previousQuestion() {
    if (current > 0) {
      setState(() {
        current--;
      });
    }
  }

  void toggleMark() {
    setState(() {
      marked[current] = !marked[current];
    });
  }

  void openPalette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Question Palette',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Palette(
                  current: current,
                  questions: questions,
                  selected: selected,
                  marked: marked,
                  onTap: (index) {
                    Navigator.pop(context);

                    setState(() {
                      current = index;
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void submit() {
    timer?.cancel();

    final answers = List<int?>.from(selected);

    final answered =
        answers.where((x) => x != null).length;

    final correct =
        answers.asMap().entries.where(
          (e) =>
              e.value != null &&
              e.value == questions[e.key].correct,
        ).length;

    final wrong = answered - correct;

    final skipped =
        questions.length - answered;

    final score = correct * 4 - wrong;

    final attempt = Attempt(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      date: DateTime.now(),
      config: widget.config,
      questions: questions,
      answers: answers,
      score: score,
      correct: correct,
      wrong: wrong,
      skipped: skipped,
    );

    HistoryStore.add(attempt);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          attempt: attempt,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[current];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${current + 1}/${questions.length}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Question Palette',
            onPressed: openPalette,
            icon: const Icon(
              Icons.grid_view_rounded,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined),
                const SizedBox(width: 8),
                Text(
                  timeText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  q.difficulty,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                q.chapter,
                                style: TextStyle(
                                  color: Colors
                                      .indigo
                                      .shade700,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: toggleMark,
                              icon: Icon(
                                marked[current]
                                    ? Icons.bookmark
                                    : Icons
                                        .bookmark_border,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Text(
                          q.text,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ...List.generate(
                  q.options.length,
                  (i) {
                    final isSelected =
                        selected[current] == i;

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: RadioListTile<int>(
                        value: i,
                        groupValue: selected[current],
                        onChanged: (_) {
                          selectAnswer(i);
                        },
                        title: Text(
                          '${String.fromCharCode(65 + i)}. '
                          '${q.options[i]}',
                        ),
                        selected: isSelected,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: current == 0
                          ? null
                          : previousQuestion,
                      child: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          current == questions.length - 1
                              ? submit
                              : nextQuestion,
                      child: Text(
                        current == questions.length - 1
                            ? 'Submit'
                            : 'Save & Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class Palette extends StatelessWidget {
  final int current;
  final List<Question> questions;
  final List<int?> selected;
  final List<bool> marked;
  final ValueChanged<int> onTap;

  const Palette({
    super.key,
    required this.current,
    required this.questions,
    required this.selected,
    required this.marked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        questions.length,
        (i) {
          final answered = selected[i] != null;
          final isCurrent = i == current;
          final isMarked = marked[i];

          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(8),
                border: Border.all(
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isMarked)
                    const Positioned(
                      right: 2,
                      top: 2,
                      child: Icon(
                        Icons.bookmark,
                        size: 12,
                      ),
                    ),
                  if (answered)
                    const Positioned(
                      left: 2,
                      bottom: 2,
                      child: Icon(
                        Icons.check_circle,
                        size: 12,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class ResultScreen extends StatelessWidget {
  final Attempt attempt;

  const ResultScreen({
    super.key,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '${attempt.score}',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text('Score'),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      Stat(
                        label: 'Correct',
                        value: '${attempt.correct}',
                      ),
                      Stat(
                        label: 'Wrong',
                        value: '${attempt.wrong}',
                      ),
                      Stat(
                        label: 'Skipped',
                        value: '${attempt.skipped}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BuilderScreen(
                    exam: Exams.all.firstWhere(
                      (e) => e.name == attempt.config.exam,
                      orElse: () => Exams.all.first,
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retake Test'),
          ),

          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryScreen(),
                ),
              );
            },
            child: const Text('View History'),
          ),

          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: () {
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              );
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

class Stat extends StatelessWidget {
  final String label;
  final String value;

  const Stat({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 95,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final attempts = HistoryStore.attempts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test History'),
      ),
      body: attempts.isEmpty
          ? const Center(
              child: Text('No attempts yet.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                final a = attempts[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${a.score}'),
                    ),
                    title: Text(
                      a.config.exam,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      '${a.correct} correct • '
                      '${a.wrong} wrong • '
                      '${a.skipped} skipped',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(
                            attempt: a,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
