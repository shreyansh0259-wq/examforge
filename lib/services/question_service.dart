import '../database/question_database.dart';
import '../models/question.dart';

class QuestionService {
  final QuestionDatabase _database = QuestionDatabase.instance;

  Future<int> addQuestion(Question question) async {
    return await _database.insertQuestion(question.toMap());
  }

  Future<int> getTotalQuestions() async {
    return await _database.getQuestionCount();
  }
}
