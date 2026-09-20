class SubjectSelection {
  final String subject;
  String? chapter;
  final Set<String> topics;

  SubjectSelection({
    required this.subject,
    this.chapter,
    Set<String>? topics,
  }) : topics = topics ?? <String>{};

  SubjectSelection copy() {
    return SubjectSelection(
      subject: subject,
      chapter: chapter,
      topics: Set<String>.from(topics),
    );
  }
}

class TestSelection {
  final Map<String, SubjectSelection> subjects = {};

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

  void clear() {
    subjects.clear();
  }
}
