/* flutter */
import 'dart:io';

import 'package:expire_app/models/product.dart';
import 'package:openfoodfacts/model/Nutriments.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'dart:typed_data';

/* helpers */
import '../constants.dart' as constants;
import '../helpers/user_info.dart' as userInfo;

class DBManager {
  /* singleton */
  DBManager._privateConstructor();

  static final DBManager _instance = DBManager._privateConstructor();
  static DBManager get instance => _instance;

  userInfo.UserInfo _user = userInfo.UserInfo.instance;

  bool _init = false;
  late sql.Database _db;
  static const DB_name = 'DB.db';

  Future<void> init() async {
    final dbPath = await sql.getDatabasesPath();

    // todo: remove
    //await sql.deleteDatabase(path.join(dbPath, DB_name));
    this._db = await sql.openDatabase(
      path.join(dbPath, DB_name),
      onCreate: (db, version) async {
        print("Init db");
        /* nutriments table*/
        await db.execute(
          "CREATE TABLE NUTRIMENTS ("
          "ID INTEGER PRIMARY KEY AUTOINCREMENT,"
          "ENERGY TEXT,"
          "FAT TEXT,"
          "SATURATED_FAT TEXT,"
          "CARBOHYDRATES TEXT,"
          "SUGAR TEXT,"
          "FIBERS TEXT,"
          "PROTEINS TEXT,"
          "SALT TEXT"
          ")",
        );
        /* ingredients level table*/
        await db.execute(
          "CREATE TABLE INGREDIENTSLEVEL ("
          "ID INTEGER PRIMARY KEY AUTOINCREMENT,"
          "FAT_LEVEL TEXT,"
          "SATURATED_FAT_LEVEL TEXT,"
          "SUGAR_LEVEL TEXT,"
          "SALT_LEVEL TEXT"
          ")",
        );
        /* product table */
        await db.execute(
          "CREATE TABLE PRODUCT ("
          "ID TEXT PRIMARY KEY, "
          "TITLE TEXT NOT NULL,"
          "EXPIRATION TEXT NOT NULL,"
          "CREATORID TEXT NOT NULL,"
          "CREATORNAME TEXT NOT NULL,"
          "DATEADDED TEXT NOT NULL,"
          "IMAGE BLOB,"
          "NUTRIMENTS_REF INTEGER,"
          "INGREDIENTSTEXT TEXT,"
          "NUTRISCORE TEXT,"
          "ALLERGENS TEXT,"
          "ECOSCORE TEXT,"
          "PACKAGING TEXT,"
          "INGREDIENTSLEVEL_REF INTEGER," // todo
          "ISPALMOILFREE TEXT,"
          "ISVEGETARIAN TEXT,"
          "ISVEGAN TEXT,"
          "BRANDNAME TEXT,"
          "QUANTITY STRING,"
          "FOREIGN KEY(NUTRIMENTS_REF) REFERENCES NUTRIMENTS(ID),"
          "FOREIGN KEY(INGREDIENTSLEVEL_REF) REFERENCES INGREDIENTSLEVEL(ID)"
          ")",
        );

        /*await db
          .execute('CREATE TABLE user_products(id TEXT PRIMARY KEY, title TEXT, expiration TEXT, creatorId TEXT, image TEXT)');*/
      },
      version: 1,
    );

    this._init = true;
  }

  void checkInit() {
    if (this._init == false) {
      throw Exception("init() function was not called. Please use await DBManager.instance.init() to initialize database.");
    }
  }

  Future<List<Product>> getProducts() async {
    this.checkInit();

    List<Product> products = [];

    final productsJSON = await _db.rawQuery('SELECT * FROM PRODUCT');
    for (final productJSON in productsJSON) {
      Nutriments? nutriments;
      int? nutriments_ref = productJSON["NUTRIMENTS_REF"] as int?;
      if (nutriments_ref != null) {
        var queryRes = (await _db.rawQuery('SELECT * FROM NUTRIMENTS WHERE ID = ? LIMIT 1', [nutriments_ref]));
        if (queryRes.isNotEmpty) {
          final nutrimentsJSON = queryRes.first;

          nutriments = _parseNutriments(nutrimentsJSON);
        }
      }

      Map<String, String>? ingredientLevels;
      int? ingredientsLevel_ref = productJSON["INGREDIENTSLEVEL_REF"] as int?;
      if (ingredientsLevel_ref != null) {
        var queryRes = (await _db.rawQuery('SELECT * FROM INGREDIENTSLEVEL WHERE ID = ? LIMIT 1', [ingredientsLevel_ref]));
        if (queryRes.isNotEmpty) {
          final ingredientLevelsJSON = queryRes.first;
          ingredientLevels = _parseIngredientsLevel(ingredientLevelsJSON);
        }
      }

      products.add(
        Product(
          id: productJSON['ID'] as String,
          title: productJSON['TITLE']! as String,
          expiration: DateTime.parse(productJSON['EXPIRATION']! as String),
          creatorId: productJSON['CREATORID']! as String,
          creatorName: productJSON['CREATORNAME']! as String,
          dateAdded: DateTime.parse(productJSON['DATEADDED']! as String),
          image: productJSON['IMAGE'] as Uint8List,
          nutriments: nutriments,
          ingredientsText: productJSON['INGREDIENTSTEXT'] as String,
          nutriscore: productJSON['NUTRISCORE'] as String,
          allergens: productJSON['ALLERGENS'] == null ? null : (productJSON['ALLERGENS'] as String).split(","),
          ecoscore: productJSON['ECOSCORE'] as String,
          packaging: productJSON['PACKAGING'] as String,
          ingredientLevels: ingredientLevels,
          isPalmOilFree: productJSON['ISPALMOILFREE'] as String,
          isVegetarian: productJSON['ISVEGETARIAN'] as String,
          isVegan: productJSON['ISVEGAN'] as String,
          brandName: productJSON['BRANDNAME'] as String,
          quantity: productJSON['QUANTITY'] as String,
        ),
      );
    }

    return products;
  }

  Future<void> addProduct({required Product product, Uint8List? imageRaw}) async {
    this.checkInit();

    /* nutriments */
    final nutrimentsJSON = product.nutriments?.toJson();
    int? nutriments_ref;
    if (nutrimentsJSON != null) {
      _db.rawInsert(
        'INSERT INTO NUTRIMENTS(ENERGY, FAT, SATURATED_FAT, CARBOHYDRATES, SUGAR, FIBERS, PROTEINS, SALT) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          nutrimentsJSON["energy-kcal"], // ENERGY
          nutrimentsJSON["fat_100g"], // FAT
          nutrimentsJSON["saturated-fat_100g"], // SATURATED_FAT
          nutrimentsJSON["carbohydrates_100g"], // CARBOHYDRATES
          nutrimentsJSON["sugars_100g"], // SUGAR
          nutrimentsJSON["fiber_100g"], // FIBERS
          nutrimentsJSON["proteins_100g"], // PROTEINS
          nutrimentsJSON["salt_100g"], // SALT
        ],
      );
      nutriments_ref = (await _db.rawQuery("SELECT last_insert_rowid()")).first["last_insert_rowid()"] as int;
    }

    /* ingredients level */
    final ingredientsLevelJSON = product.ingredientLevels;
    int? ingredientsLevel_ref;
    if (ingredientsLevelJSON != null) {
      _db.rawInsert(
        'INSERT INTO INGREDIENTSLEVEL(FAT_LEVEL, SATURATED_FAT_LEVEL, SUGAR_LEVEL, SALT_LEVEL) VALUES (?, ?, ?, ?)',
        [
          ingredientsLevelJSON["fat"], // FAT
          ingredientsLevelJSON["saturated-fat"], // SATURATED_FAT
          ingredientsLevelJSON["sugars"], // SUGAR
          ingredientsLevelJSON["salt"], // SALT
        ],
      );
      ingredientsLevel_ref = (await _db.rawQuery("SELECT last_insert_rowid()")).first["last_insert_rowid()"] as int;
    }

    /* products */
    _db.rawInsert(
      'INSERT INTO PRODUCT(ID, TITLE, EXPIRATION, CREATORID, CREATORNAME, DATEADDED, IMAGE, NUTRIMENTS_REF, INGREDIENTSTEXT, NUTRISCORE, ALLERGENS, ECOSCORE, PACKAGING, INGREDIENTSLEVEL_REF, ISPALMOILFREE, ISVEGETARIAN, ISVEGAN, BRANDNAME, QUANTITY) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        product.id, // ID
        product.title, // TITLE
        product.expiration.toIso8601String(), // EXPIRATION
        _user.userId, // CREATORID
        _user.displayName, // CREATORNAME
        product.dateAdded.toIso8601String(), // DATEADDED
        imageRaw, // IMAGE
        nutriments_ref, // NUTRIMENTS_REF
        product.ingredientsText, // INGREDIENTSTEXT
        product.nutriscore, // NUTRISCORE
        product.allergens?.join(","), // ALLERGENS
        product.ecoscore, // ECOSCORE
        product.packaging, // PACKAGING
        ingredientsLevel_ref, // INGREDIENTSLEVEL
        product.isPalmOilFree, // ISPALMOILFREE
        product.isVegetarian, // ISVEGETARIAN
        product.isVegan, // ISVEGAN
        product.brandName, // BRANDNAME
        product.quantity, // QUANTITY
      ],
    );
  }

  Future<void> deleteProduct({required String productId}) async {
    this.checkInit();

    _db.rawDelete('DELETE FROM PRODUCT WHERE ID = ?', [productId]);
  }

  Nutriments? _parseNutriments(Map<String, dynamic> JSONnutriments) {
    if (JSONnutriments.isEmpty) {
      return null;
    }

    Nutriments nutriments = new Nutriments();
    nutriments.energyKcal = JSONnutriments['ENERGY'] == null ? null : double.tryParse(JSONnutriments['ENERGY']);
    nutriments.fat = JSONnutriments['FAT'] == null ? null : double.tryParse(JSONnutriments['FAT']);
    nutriments.saturatedFat = JSONnutriments['SATURATED_FAT'] == null ? null : double.tryParse(JSONnutriments['SATURATED_FAT']);
    nutriments.carbohydrates = JSONnutriments['CARBOHYDRATES'] == null ? null : double.tryParse(JSONnutriments['CARBOHYDRATES']);
    nutriments.sugars = JSONnutriments['SUGAR'] == null ? null : double.tryParse(JSONnutriments['SUGAR']);
    nutriments.fiber = JSONnutriments['FIBERS'] == null ? null : double.tryParse(JSONnutriments['FIBERS']);
    nutriments.proteins = JSONnutriments['PROTEINS'] == null ? null : double.tryParse(JSONnutriments['PROTEINS']);
    nutriments.salt = JSONnutriments['SALT'] == null ? null : double.tryParse(JSONnutriments['SALT']);

    return nutriments;
  }

  Map<String, String>? _parseIngredientsLevel(Map<String, dynamic> JSONingredientsLevel) {
    if (JSONingredientsLevel.isEmpty) {
      return null;
    }

    Map<String, String> levels = {
      'fat': JSONingredientsLevel["FAT_LEVEL"],
      'salt': JSONingredientsLevel["SALT_LEVEL"],
      'saturated-fat': JSONingredientsLevel["SATURATED_FAT_LEVEL"],
      'sugars': JSONingredientsLevel["SUGAR_LEVEL"],
    };

    return levels;
  }

  /*static Future<void> insert(String table, Map<String, Object> data) async {
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

  static Future<String> getCreatorId({required String productId}) async {
    final data = await DBHelper.getData(table: 'user_products', where: "id == (?)", whereArgs: [productId]);
    return data[0]['creatorId'];
  }

  static Future<List<Map<String, dynamic>>> getProductsFromFamilyId({required String familyId}) async {
    final sqlDB = await DBHelper.database();

    final data = await sqlDB.rawQuery(""" SELECT * FROM user_products
    WHERE creatorID IN (SELECT userId FROM family WHERE familyId = '$familyId')
    """);

    return data;
  }*/
}
