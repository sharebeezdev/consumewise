import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;

  // Function to return the file-based database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;

    // Get the database path to store the file-based database
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'profile_database.db');

    // Open the file-based database
    print('Opening file-based database at path: $path');
    _database = await openDatabase(
      path,
      version: 1, // No need to worry about versions as this is a new DB
      onCreate: _createDb, // Call the function to create tables
    );
    return _database!;
  }

  // Create both the profile and scanned products table
  static void _createDb(Database db, int version) async {
    // Creating the profile table with creationDate, lastUpdateDate, and createdBy
    print('Creating profile table in database');
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        age INTEGER,
        gender TEXT,
        dietPreference TEXT,
        allergies TEXT,
        medicalCondition TEXT,
        environmentallyConscious INTEGER,
        nutritionalGoal TEXT,
        productInterests TEXT,
        dataSharingPreference TEXT,
        language TEXT,
        creationDate TEXT NOT NULL,
        lastUpdateDate TEXT NOT NULL,
        createdBy TEXT NOT NULL
      )
    ''');

    // Creating the scanned products table with creationDate, lastUpdateDate, and createdBy
    print('Creating scanned products table in database');
    await db.execute('''
      CREATE TABLE scanned_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uniqueId TEXT NOT NULL,
        imagePath TEXT,
        apiResponse TEXT,
        creationDate TEXT NOT NULL,
        lastUpdateDate TEXT NOT NULL,
        createdBy TEXT NOT NULL
      )
    ''');
  }

  // Insert new profile data with creationDate, lastUpdateDate, and createdBy
  static Future<int> insertProfile(Map<String, dynamic> data) async {
    final db = await database;

    // Add current timestamps and createdBy
    String currentDate = DateTime.now().toUtc().toIso8601String();
    data['creationDate'] = currentDate;
    data['lastUpdateDate'] = currentDate;
    data['createdBy'] = 'ConsumeWise'; // Default createdBy

    // Insert profile data
    return await db.insert('profile', data);
  }

  // Fetch the profile data
  static Future<Map<String, dynamic>?> fetchProfile() async {
    final db = await database;
    final result = await db.query('profile', limit: 1);
    if (result.isNotEmpty) {
      print('Fetched profile: ${result.first}');
      return result.first;
    }
    print('No profile found in the database');
    return null;
  }

  // Update the profile data, ensuring lastUpdateDate is set
  static Future<int> updateProfile(Map<String, dynamic> data) async {
    final db = await database;

    // Ensure the profile exists before updating
    final existingProfile = await fetchProfile();
    if (existingProfile != null) {
      // Update the lastUpdateDate
      data['lastUpdateDate'] = DateTime.now().toUtc().toIso8601String();

      return await db.update('profile', data,
          where: 'id = ?', whereArgs: [existingProfile['id']]);
    } else {
      print('No profile found for updating. Inserting new profile.');
      return await insertProfile(data);
    }
  }

  // Insert scanned product data with creationDate, lastUpdateDate, and createdBy
  static Future<int> insertScannedProduct(Map<String, dynamic> data) async {
    final db = await database;

    // Add current timestamps and createdBy
    String currentDate = DateTime.now().toUtc().toIso8601String();
    data['creationDate'] = currentDate;
    data['lastUpdateDate'] = currentDate;
    data['createdBy'] = 'ConsumeWise'; // Default createdBy

    print('Inserting scanned product: $data');
    return await db.insert('scanned_products', data);
  }

  // Fetch scanned product by unique ID
  static Future<Map<String, dynamic>?> fetchScannedProductById(
      String uniqueId) async {
    final db = await database;
    final result = await db.query('scanned_products',
        where: 'uniqueId = ?', whereArgs: [uniqueId]);
    if (result.isNotEmpty) {
      print('Fetched scanned product: ${result.first}');
      return result.first;
    }
    print('No scanned product found in the database');
    return null;
  }

  // Fetch all scanned products (for displaying the list of scanned items, if needed)
  static Future<List<Map<String, dynamic>>> fetchAllScannedProducts() async {
    final db = await database;
    final result = await db.query('scanned_products');
    print('Fetched all scanned products: $result');
    return result;
  }

  static Future<List<Map<String, dynamic>>> fetchTopScannedProducts(
      int limit) async {
    final db = await DatabaseHelper.database;
    return await db.query('scanned_products',
        orderBy: 'lastUpdateDate DESC', limit: limit);
  }
}
