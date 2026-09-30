import '../models/question.dart';
import '../models/test_selection.dart';
import 'question_service.dart';

class TestGenerator {
  final QuestionService _questionService = QuestionService();

  Future<List<Question>> generateFromSelection({
    required String exam,
    required TestSelection selection,
  }) async {
    final allQuestions = <Question>[];

    for (final subjectSelection in selection.subjects.values) {
      final chapterNames = subjectSelection.chapters.keys.toList();

      if (chapterNames.isEmpty) {
        continue;
      }

      final questionCount = subjectSelection.questionCount;
      final difficulty = subjectSelection.difficulty;

      for (final chapter in chapterNames) {
        final chapterSelection = subjectSelection.chapters[chapter]!;

        final topics = chapterSelection.topics;

        if (topics.isEmpty) {
          final questions = await _questionService.getQuestions(
            exam: exam,
            subject: subjectSelection.subject,
            chapter: chapter,
            difficulty: difficulty,
          );

          allQuestions.addAll(
            _takeRandom(questions, questionCount),
          );
        } else {
          final chapterQuestions = <Question>[];

          for (final topic in topics) {
            final questions = await _questionService.getQuestions(
              exam: exam,
              subject: subjectSelection.subject,
              chapter: chapter,
              topic: topic,
              difficulty: difficulty,
            );

            chapterQuestions.addAll(questions);
          }

          allQuestions.addAll(
            _takeRandom(chapterQuestions, questionCount),
          );
        }
      }
    }

    allQuestions.shuffle();
    return allQuestions;
  }

  List<Question> _takeRandom(
    List<Question> questions,
    int count,
  ) {
    final selected = List<Question>.from(questions);
    selected.shuffle();

    if (selected.length <= count) {
      return selected;
    }

    return selected.take(count).toList();
  }
}
