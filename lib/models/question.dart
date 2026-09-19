import 'dart:convert';

class Question {
  final String id;
  final String exam;
  final String subject;
  final String chapter;
  final String topic;
  final String difficulty;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final String sourceType;
  final String? sourceName;
  final int? year;
  final String? sourceReference;
  final String? fingerprint;

  const Question({
    required this.id,
    required this.exam,
    required this.subject,
    required this.chapter,
    required this.topic,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.sourceType,
    this.sourceName,
    this.year,
    this.sourceReference,
    this.fingerprint,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      exam: json['exam'],
      subject: json['subject'],
      chapter: json['chapter'],
      topic: json['topic'],
      difficulty: json['difficulty'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
      sourceType: json['source_type'],
      sourceName: json['source'] ?? json['source_name'],
      year: json['year'],
      sourceReference: json['source_reference'],
      fingerprint: json['fingerprint'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exam': exam,
      'subject': subject,
      'chapter': chapter,
      'topic': topic,
      'difficulty': difficulty,
      'question': question,
      'options': jsonEncode(options),
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'source_type': sourceType,
      'source_name': sourceName,
      'year': year,
      'source_reference': sourceReference,
      'fingerprint': fingerprint,
    };
  }
}
