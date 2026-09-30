class DifficultyLevels {
  static const List<String> all = [
    'Very Easy',
    'Easy',
    'Easy-Moderate',
    'Moderate',
    'Moderate+',
    'Hard',
    'Very Hard',
    'Advanced',
    'Expert',
    'Extreme Challenge',
    'Mixed',
  ];
}

class ChapterSelection {
  final String chapter;
  final Set<String> topics;
  String? difficulty;

  ChapterSelection({
    required this.chapter,
    Set<String>? topics,
    this.difficulty,
  }) : topics = topics ?? <String>{};

  ChapterSelection copy() {
    return ChapterSelection(
      chapter: chapter,
      topics: Set<String>.from(topics),
      difficulty: difficulty,
    );
  }
}

class SubjectSelection {
  final String subject;
  int questionCount;
  String? difficulty;
  final Map<String, ChapterSelection> chapters;

  SubjectSelection({
    required this.subject,
    this.questionCount = 1,
    this.difficulty,
    Map<String, ChapterSelection>? chapters,
  }) : chapters = chapters ?? <String, ChapterSelection>{};

  ChapterSelection getOrCreateChapter(String chapter) {
    return chapters.putIfAbsent(
      chapter,
      () => ChapterSelection(chapter: chapter),
    );
  }

  void removeChapter(String chapter) {
    chapters.remove(chapter);
  }

  SubjectSelection copy() {
    return SubjectSelection(
      subject: subject,
      questionCount: questionCount,
      difficulty: difficulty,
      chapters: {
        for (final entry in chapters.entries)
          entry.key: entry.value.copy(),
      },
    );
  }
}

class TestSelection {
  final Map<String, SubjectSelection> subjects = {};

  String? difficulty;

  void selectSubject(String subject) {
    subjects.putIfAbsent(
      subject,
      () => SubjectSelection(subject: subject),
    );
  }

  void removeSubject(String subject) {
    subjects.remove(subject);
  }

  SubjectSelection getOrCreate(String subject) {
    selectSubject(subject);
    return subjects[subject]!;
  }

  int get totalQuestions {
    return subjects.values.fold(
      0,
      (total, subject) => total + subject.questionCount,
    );
  }

  void clear() {
    subjects.clear();
    difficulty = null;
  }
}
