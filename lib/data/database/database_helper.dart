import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static Database? _database;
  static DatabaseHelper? _instance;
  static const String _tableName = 'user_preferences';
  static const String _dbName = 'passou_aqui.db';
  static const int _version = 2;

  // Construtor privado
  DatabaseHelper._();

  // Singleton factory
  static Future<DatabaseHelper> get instance async {
    if (_instance == null) {
      debugPrint('🔄 DatabaseHelper: Criando nova instância...');
      final dbHelper = DatabaseHelper._();
      await dbHelper._initDatabase();
      _instance = dbHelper;
      debugPrint('✅ DatabaseHelper: Instância criada com sucesso');
    }
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) {
      debugPrint('ℹ️ DatabaseHelper: Usando banco de dados existente');
      return _database!;
    }
    debugPrint('🔄 DatabaseHelper: Inicializando banco de dados...');
    await _initDatabase();
    return _database!;
  }

  Future<void> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);

      debugPrint('📁 DatabaseHelper: Caminho do banco: $path');

      _database = await openDatabase(
        path,
        version: _version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) {
          debugPrint('✅ DatabaseHelper: Banco de dados aberto com sucesso');
        },
      );

      debugPrint('✅ DatabaseHelper: Banco de dados inicializado com sucesso');
    } catch (e) {
      debugPrint('❌ DatabaseHelper: Erro ao inicializar banco de dados: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      debugPrint('🔄 DatabaseHelper: Criando tabela $_tableName...');
      await db.execute('''
        CREATE TABLE $_tableName(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          darkMode INTEGER NOT NULL DEFAULT 0,
          language TEXT NOT NULL DEFAULT 'pt_BR',
          fontSize TEXT NOT NULL DEFAULT 'medium',
          highContrast INTEGER NOT NULL DEFAULT 0,
          lastUpdated TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      debugPrint('✅ DatabaseHelper: Tabela criada com sucesso');
    } catch (e) {
      debugPrint('❌ DatabaseHelper: Erro ao criar tabela: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      debugPrint(
          '🔄 DatabaseHelper: Atualizando banco de dados de $oldVersion para $newVersion...');

      if (oldVersion < 2) {
        // Adiciona a coluna lastUpdated se não existir
        await db.execute('''
          ALTER TABLE $_tableName 
          ADD COLUMN lastUpdated TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        ''');
        debugPrint(
            '✅ DatabaseHelper: Coluna lastUpdated adicionada com sucesso');
      }

      debugPrint('✅ DatabaseHelper: Banco de dados atualizado com sucesso');
    } catch (e) {
      debugPrint('❌ DatabaseHelper: Erro ao atualizar banco de dados: $e');
      rethrow;
    }
  }

  Future<int> insert(Map<String, dynamic> row) async {
    try {
      debugPrint('💾 DatabaseHelper: Inserindo nova preferência...');
      final db = await database;
      row['lastUpdated'] = DateTime.now().toIso8601String();
      final id = await db.insert(_tableName, row);
      debugPrint(
          '✅ DatabaseHelper: Preferência inserida com sucesso (ID: $id)');
      return id;
    } catch (e) {
      debugPrint('❌ DatabaseHelper: Erro ao inserir preferência: $e');
      rethrow;
    }
  }

  Future<int> update(Map<String, dynamic> row) async {
    try {
      final db = await database;
      final id = row['id'];
      row['lastUpdated'] = DateTime.now().toIso8601String();

      debugPrint('🔄 DatabaseHelper: Atualizando preferência (ID: $id)...');
      debugPrint('📝 DatabaseHelper: Dados: $row');

      final result = await db.update(
        _tableName,
        row,
        where: 'id = ?',
        whereArgs: [id],
      );

      debugPrint('✅ DatabaseHelper: Preferência atualizada com sucesso');
      return result;
    } catch (e) {
      debugPrint('❌ DatabaseHelper: Erro ao atualizar preferência: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> queryRow() async {
    try {
      final db = await database;
      debugPrint('🔍 DatabaseHelper: Buscando preferências...');

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'lastUpdated DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        debugPrint('ℹ️ DatabaseHelper: Nenhuma preferência encontrada');
        return null;
      }

      debugPrint('✅ DatabaseHelper: Preferências encontradas: ${maps.first}');
      return maps.first;
    } catch (e) {
      debugPrint('❌ DatabaseHelper: Erro ao buscar preferências: $e');
      rethrow;
    }
  }

  Future<void> delete() async {
    try {
      final db = await database;
      debugPrint('🗑️ DatabaseHelper: Deletando todas as preferências...');
      await db.delete(_tableName);
      debugPrint('✅ DatabaseHelper: Preferências deletadas com sucesso');
    } catch (e) {
      debugPrint('❌ DatabaseHelper: Erro ao deletar preferências: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    try {
      if (_database != null) {
        debugPrint('🔒 DatabaseHelper: Fechando conexão com o banco...');
        await _database!.close();
        _database = null;
        debugPrint('✅ DatabaseHelper: Conexão fechada com sucesso');
      }
    } catch (e) {
      debugPrint('❌ DatabaseHelper: Erro ao fechar conexão: $e');
      rethrow;
    }
  }
}
