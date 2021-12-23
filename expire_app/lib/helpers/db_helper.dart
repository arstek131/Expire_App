import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();

    return sql.openDatabase(path.join(dbPath, 'DB.db'), onCreate: (db, version) async {
      await db
          .execute('CREATE TABLE user_products(id TEXT PRIMARY KEY, title TEXT, expiration TEXT, creatorId TEXT, image TEXT)');
      await db.execute('CREATE TABLE users(userId TEXT PRIMARY KEY, displayName TEXT)');
      await db.execute('CREATE TABLE family(familyId TEXT NOT NULL, userId TEXT NOT NULL, PRIMARY KEY (familyId, userId))');
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final sqlDB = await DBHelper.database();
    sqlDB.insert(table, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getData({required String table, String? where = null, whereArgs = null}) async {
    final sqlDB = await DBHelper.database();
    return sqlDB.query(table, where: where, whereArgs: whereArgs);
  }

  static Future<void> delete(String table, String id) async {
    final sqlDB = await DBHelper.database();
    sqlDB.rawDelete(
      'DELETE FROM $table WHERE id = ?',
      [id],
    );
  }

  static Future<String?> getFamilyIdFromUserId(String userId) async {
    final data = await DBHelper.getData(table: 'family', where: "userId == (?)", whereArgs: [userId]);

    return data.isEmpty ? null : data[0]['familyId'];
  }

  static Future<String?> getDisplayNameFromUserId(String userId) async {
    final data = await DBHelper.getData(table: 'users', where: "userId == (?)", whereArgs: [userId]);

    return data.isEmpty ? null : data[0]['displayName'];
  }
}
