import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static const _databaseName = "passou_aqui.db";
  static const _databaseVersion = 2;

  static const tableUserPreferences = 'user_preferences';

  static const columnId = 'id';
  static const columnDarkMode = 'darkMode';
  static const columnFontSize = 'fontSize';
  static const columnHighContrast = 'highContrast';

  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const boolType = 'INTEGER NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE $tableUserPreferences (
      $columnId $idType,
      $columnDarkMode $boolType,
      $columnFontSize $textType,
      $columnHighContrast $boolType
    )
    ''');

    // Insert default preferences
    await db.insert(tableUserPreferences, {
      columnDarkMode: 0,
      columnFontSize: 'medium',
      columnHighContrast: 0,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Recria a tabela com a nova estrutura
      await db.execute('DROP TABLE IF EXISTS $tableUserPreferences');
      await _createDB(db, newVersion);
    }
  }

  Future<int> insert(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(tableUserPreferences, row);
  }

  Future<int> update(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row[columnId];
    debugPrint('📝 DatabaseHelper: Updating row with id $id: $row');
    final result = await db.update(
      tableUserPreferences,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    debugPrint('✅ DatabaseHelper: Update result: $result rows affected');
    return result;
  }

  Future<Map<String, dynamic>?> queryRow() async {
    final db = await instance.database;
    debugPrint('🔍 DatabaseHelper: Querying user preferences...');
    final List<Map<String, dynamic>> maps =
        await db.query(tableUserPreferences);

    if (maps.isEmpty) {
      debugPrint('⚠️ DatabaseHelper: No user preferences found in database');
      return null;
    }

    debugPrint('✅ DatabaseHelper: Found preferences: ${maps.first}');
    return maps.first;
  }

  Future<void> delete() async {
    final db = await instance.database;
    await db.delete(tableUserPreferences);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
