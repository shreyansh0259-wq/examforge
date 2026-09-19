import '../models/question.dart';
import 'question_service.dart';

class TestGenerator {
  final QuestionService _questionService = QuestionService();

  Future<List<Question>> generateTest({
    required String exam,
    String? subject,
    String? chapter,
    String? topic,
    String? difficulty,
    required int questionCount,
  }) async {
    final questions = await _questionService.getQuestions(
      exam: exam,
      subject: subject,
      chapter: chapter,
      topic: topic,
      difficulty: difficulty,
    );

    if (questions.length <= questionCount) {
      return questions;
    }

    final selected = List<Question>.from(questions);
    selected.shuffle();

    return selected.take(questionCount).toList();
  }
}
