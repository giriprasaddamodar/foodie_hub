import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/food_item.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('foodiehub.db');
    return _database!;
  }

  //────────────────────────────────────────
  // INIT DATABASE
  //────────────────────────────────────────
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // bump version for new column support
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add hour and minute columns if upgrading from old version
      await db.execute('ALTER TABLE schedules ADD COLUMN hour INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE schedules ADD COLUMN minute INTEGER DEFAULT 0');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        gender TEXT,
        phone TEXT,
        city TEXT,
        created_at TEXT
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT,
        image TEXT,
        price REAL,
        category TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Cart table
    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT,
        image TEXT,
        price REAL,
        quantity INTEGER,
        category TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Schedules table
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        body TEXT,
        scheduled_time TEXT,
        hour INTEGER,
        minute INTEGER,
        notifId INTEGER
      )
    ''');

    // App flags
    await db.execute('''
      CREATE TABLE app_flags (
        key TEXT PRIMARY KEY,
        value INTEGER
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        body TEXT,
        time TEXT,
        opened INTEGER DEFAULT 0
      )
    ''');
  }

  //────────────────────────────────────────
  // USER FUNCTIONS
  //────────────────────────────────────────
  Future<int> insertUser(User user) async {
    final db = await database;
    final map = user.toMap();
    map['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('users', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserByEmailPassword(String email, String password) async {
    final db = await database;
    final res = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    return res.isNotEmpty ? User.fromMap(res.first) : null;
  }

  Future<bool> checkUserExists(String email) async {
    final db = await database;
    final res = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return res.isNotEmpty;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? User.fromMap(res.first) : null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> updateUserPassword(String email, String newPassword) async {
    final db = await database;
    return await db.update('users', {'password': newPassword}, where: 'email = ?', whereArgs: [email]);
  }

  //────────────────────────────────────────
  // FAVORITES
  //────────────────────────────────────────
  Future<void> insertFavorite(FoodItem item, int userId) async {
    final db = await database;
    await db.insert('favorites', {
      'name': item.name,
      'image': item.image,
      'price': item.price,
      'category': item.category,
      'userId': userId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(String name, int userId) async {
    final db = await database;
    await db.delete('favorites', where: 'name = ? AND userId = ?', whereArgs: [name, userId]);
  }

  Future<List<FoodItem>> getFavorites(int userId) async {
    final db = await database;
    final res = await db.query('favorites', where: 'userId = ?', whereArgs: [userId]);
    return res.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<void> removeFromFavorites(int userId, String foodName) async {
    final db = await database; await db.delete('favorites', where: 'userId = ? AND name = ?', whereArgs: [userId, foodName]);
  }

  //────────────────────────────────────────
  // CART
  //────────────────────────────────────────
  Future<void> insertCartItem(FoodItem item, int quantity, int userId) async {
    final db = await database;
    final existing = await db.query('cart', where: 'name = ? AND userId = ?', whereArgs: [item.name, userId]);

    if (existing.isNotEmpty) {
      int currentQty = existing.first['quantity'] as int;
      await db.update('cart', {'quantity': currentQty + quantity}, where: 'name = ? AND userId = ?', whereArgs: [item.name, userId]);
    } else {
      await db.insert('cart', {
        'name': item.name,
        'image': item.image,
        'price': item.price,
        'category': item.category,
        'quantity': quantity,
        'userId': userId,
      });
    }
  }

  Future<void> updateCartQuantity(int userId, String name, int quantity) async {
    final db = await database;
    await db.update('cart', {'quantity': quantity}, where: 'name = ? AND userId = ?', whereArgs: [name, userId]);
  }

  Future<List<Map<String, dynamic>>> getCartItems(int userId) async {
    final db = await database;
    return await db.query('cart', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<void> removeCartItem(String name, int userId) async {
    final db = await database;
    await db.delete('cart', where: 'name = ? AND userId = ?', whereArgs: [name, userId]);
  }

  Future<void> clearCart(int userId) async {
    final db = await database;
    await db.delete('cart', where: 'userId = ?', whereArgs: [userId]);
  }

  //────────────────────────────────────────
  // SCHEDULES (ADMIN)
  //────────────────────────────────────────
  Future<int> insertSchedule(Map<String, dynamic> schedule) async {
    final db = await database;
    return await db.insert('schedules', schedule, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    final db = await database;
    final rows = await db.query('schedules', orderBy: 'scheduled_time');
    return rows.map((r) => {
      'id': r['id'],
      'title': r['title'],
      'body': r['body'],
      'scheduled_time': r['scheduled_time'],
      'hour': r['hour'],
      'minute': r['minute'],
      'notifId': r['notifId'],
    }).toList();
  }

  Future<int> updateSchedule(Map<String, dynamic> schedule) async {
    final db = await database;
    return await db.update('schedules', schedule, where: 'id = ?', whereArgs: [schedule['id']]);
  }

  Future<int> deleteSchedule(int id) async {
    final db = await database;
    return await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  //────────────────────────────────────────
  // APP FLAGS
  //────────────────────────────────────────
  Future<void> setFlag(String key, int value) async {
    final db = await database;
    await db.insert('app_flags', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int?> getFlag(String key) async {
    final db = await database;
    final res = await db.query('app_flags', where: 'key = ?', whereArgs: [key], limit: 1);
    if (res.isEmpty) return null;
    return res.first['value'] as int?;
  }

  Future<bool> isFirstTimeUser() async {
    final v = await getFlag('first_time');
    return v == null || v == 1;
  }

  Future<void> setFirstTime(int value) async {
    await setFlag('first_time', value);
  }

  //────────────────────────────────────────
  // NOTIFICATIONS
  //────────────────────────────────────────
  Future<int> insertNotification(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('notifications', data);
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return await db.query('notifications', orderBy: 'time DESC');
  }

  Future<int> deleteNotification(int id) async {
    final db = await database;
    return await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAllNotifications() async {
    final db = await database;
    return await db.delete('notifications');
  }

  Future<int> markNotificationOpened(int id) async {
    final db = await database;
    return await db.update('notifications', {'opened': 1}, where: 'id = ?', whereArgs: [id]);
  }

  //────────────────────────────────────────
  // CLOSE DB
  //────────────────────────────────────────
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
