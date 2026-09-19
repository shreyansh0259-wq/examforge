import 'dart:convert';

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

  Future<List<Question>> getQuestions({
    required String exam,
    String? subject,
    String? chapter,
    String? topic,
    String? difficulty,
    int? limit,
  }) async {
    final db = await _database.database;

    final conditions = <String>['exam = ?'];
    final arguments = <dynamic>[exam];

    if (subject != null) {
      conditions.add('subject = ?');
      arguments.add(subject);
    }

    if (chapter != null) {
      conditions.add('chapter = ?');
      arguments.add(chapter);
    }

    if (topic != null) {
      conditions.add('topic = ?');
      arguments.add(topic);
    }

    if (difficulty != null) {
      conditions.add('difficulty = ?');
      arguments.add(difficulty);
    }

    final result = await db.query(
      'questions',
      where: conditions.join(' AND '),
      whereArgs: arguments,
      limit: limit,
    );

    return result.map((row) {
      return Question(
        id: row['id'] as String,
        exam: row['exam'] as String,
        subject: row['subject'] as String,
        chapter: row['chapter'] as String,
        topic: row['topic'] as String,
        difficulty: row['difficulty'] as String,
        question: row['question'] as String,
        options: List<String>.from(
          jsonDecode(row['options'] as String),
        ),
        correctAnswer: row['correct_answer'] as int,
        explanation: row['explanation'] as String?,
        sourceType: row['source_type'] as String,
        sourceName: row['source_name'] as String?,
        year: row['year'] as int?,
        sourceReference: row['source_reference'] as String?,
        fingerprint: row['fingerprint'] as String?,
      );
    }).toList();
  }
}
