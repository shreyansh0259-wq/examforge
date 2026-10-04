import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CollegeDatabase {
  static final CollegeDatabase instance = CollegeDatabase._internal();

  CollegeDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'examforge_college.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE college_cutoffs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            record_key TEXT NOT NULL UNIQUE,
            exam TEXT NOT NULL,
            college TEXT NOT NULL,
            course TEXT NOT NULL,
            category TEXT NOT NULL,
            counselling TEXT NOT NULL,
            quota TEXT,
            state TEXT,
            institute_type TEXT,
            year INTEGER NOT NULL,
            round INTEGER NOT NULL,
            opening_rank INTEGER,
            closing_rank INTEGER,
            closing_score INTEGER,
            source TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_college_exam_year
          ON college_cutoffs(exam, year)
        ''');

        await db.execute('''
          CREATE INDEX idx_college_rank
          ON college_cutoffs(exam, year, closing_rank)
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE college_cutoffs ADD COLUMN quota TEXT',
          );
          await db.execute(
            'ALTER TABLE college_cutoffs ADD COLUMN state TEXT',
          );
          await db.execute(
            'ALTER TABLE college_cutoffs ADD COLUMN institute_type TEXT',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE college_cutoffs ADD COLUMN record_key TEXT',
          );
        }

        if (oldVersion < 4) {
          await db.execute('''
            UPDATE college_cutoffs
            SET record_key =
              lower(
                exam || '|' ||
                year || '|' ||
                counselling || '|' ||
                round || '|' ||
                college || '|' ||
                course || '|' ||
                category || '|' ||
                coalesce(quota, '') || '|' ||
                coalesce(state, '')
              )
            WHERE record_key IS NULL
          ''');

          await db.execute('''
            CREATE UNIQUE INDEX IF NOT EXISTS idx_college_record_key
            ON college_cutoffs(record_key)
          ''');
        }
      },
    );
  }
}

extension CollegeDatabaseOperations on CollegeDatabase {
  Future<int> insertCutoff(Map<String, dynamic> data) async {
    final db = await database;

    final record = Map<String, dynamic>.from(data);

    record['record_key'] ??= [
      record['exam'],
      record['year'],
      record['counselling'],
      record['round'],
      record['college'],
      record['course'],
      record['category'],
      record['quota'] ?? '',
      record['state'] ?? '',
    ].join('|').toLowerCase();

    return db.insert(
      'college_cutoffs',
      record,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> findByRank({
    required String exam,
    required int year,
    required int rank,
    String? category,
    String? counselling,
  }) async {
    final db = await database;

    final where = <String>[
      'exam = ?',
      'year = ?',
      'closing_rank IS NOT NULL',
      'closing_rank >= ?',
    ];

    final args = <dynamic>[
      exam,
      year,
      rank,
    ];

    if (category != null) {
      where.add('category = ?');
      args.add(category);
    }

    if (counselling != null) {
      where.add('counselling = ?');
      args.add(counselling);
    }

    return db.query(
      'college_cutoffs',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'closing_rank ASC',
    );
  }
}
