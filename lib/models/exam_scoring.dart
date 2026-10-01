class ExamScoring {
  final String exam;
  final int marksPerCorrect;
  final int marksPerIncorrect;
  final bool supportsScore;

  const ExamScoring({
    required this.exam,
    required this.marksPerCorrect,
    required this.marksPerIncorrect,
    required this.supportsScore,
  });

  int calculateScore({
    required int correct,
    required int incorrect,
  }) {
    if (!supportsScore) return 0;

    return (correct * marksPerCorrect) +
        (incorrect * marksPerIncorrect);
  }

  static ExamScoring forExam(String exam) {
    switch (exam.toLowerCase()) {
      case 'neet':
        return const ExamScoring(
          exam: 'NEET',
          marksPerCorrect: 4,
          marksPerIncorrect: -1,
          supportsScore: true,
        );

      case 'jee main':
        return const ExamScoring(
          exam: 'JEE Main',
          marksPerCorrect: 4,
          marksPerIncorrect: -1,
          supportsScore: true,
        );

      case 'jee advanced':
        return const ExamScoring(
          exam: 'JEE Advanced',
          marksPerCorrect: 4,
          marksPerIncorrect: -1,
          supportsScore: true,
        );

      case 'upsc':
        return const ExamScoring(
          exam: 'UPSC',
          marksPerCorrect: 0,
          marksPerIncorrect: 0,
          supportsScore: false,
        );

      default:
        return const ExamScoring(
          exam: 'Unknown',
          marksPerCorrect: 4,
          marksPerIncorrect: -1,
          supportsScore: true,
        );
    }
  }
}
