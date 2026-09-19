import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class QuestionDatabase {
  static final QuestionDatabase instance = QuestionDatabase._init();

  static Database? _database;

  QuestionDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('examforge_questions.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id TEXT PRIMARY KEY,
        exam TEXT NOT NULL,
        subject TEXT NOT NULL,
        chapter TEXT NOT NULL,
        topic TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        question TEXT NOT NULL,
        options TEXT NOT NULL,
        correct_answer INTEGER NOT NULL,
        explanation TEXT,
        source_type TEXT NOT NULL,
        source_name TEXT,
        year INTEGER,
        source_reference TEXT,
        fingerprint TEXT UNIQUE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_exam ON questions(exam)',
    );

    await db.execute(
      'CREATE INDEX idx_subject ON questions(subject)',
    );

    await db.execute(
      'CREATE INDEX idx_chapter ON questions(chapter)',
    );

    await db.execute(
      'CREATE INDEX idx_topic ON questions(topic)',
    );

    await db.execute(
      'CREATE INDEX idx_difficulty ON questions(difficulty)',
    );

    await db.execute(
      'CREATE INDEX idx_exam_subject_chapter ON questions(exam, subject, chapter)',
    );
  }

  Future<int> insertQuestion(Map<String, dynamic> question) async {
    final db = await database;

    return await db.insert(
      'questions',
      question,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> getQuestionCount() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM questions',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
