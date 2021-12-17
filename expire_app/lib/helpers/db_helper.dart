import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();

    return sql.openDatabase(path.join(dbPath, 'DB.db'), onCreate: (db, version) {
      return db.execute('CREATE TABLE user_products(id TEXT PRIMARY KEY, title TEXT, expiration TEXT, image TEXT)');
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final sqlDB = await DBHelper.database();
    sqlDB.insert(table, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final sqlDB = await DBHelper.database();
    return sqlDB.query(table);
  }

  static Future<void> delete(String table, String id) async {
    final sqlDB = await DBHelper.database();
    sqlDB.rawDelete(
      'DELETE FROM $table WHERE id = ?',
      [id],
    );
  }
}
