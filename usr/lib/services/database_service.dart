import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:gluarash/models/sensor_data.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'sensor_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sensor_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        rawData TEXT NOT NULL,
        analyzedResult TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertData(SensorData data) async {
    final db = await database;
    await db.insert(
      'sensor_data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SensorData>> getData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sensor_data',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return SensorData.fromMap(maps[i]);
    });
  }
}
