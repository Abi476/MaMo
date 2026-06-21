import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Pattern Singleton: Memastikan hanya ada satu koneksi database yang aktif
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inisialisasi Database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ujikom_mobile.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Membuat Tabel (Sesuai Ketentuan 2, 3, 4, dan 5)
  Future<void> _onCreate(Database db, int version) async {
    // Tabel untuk Fitur Login, Sign Up, dan Edit Profil
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        email TEXT UNIQUE,
        password TEXT,
        profile_image_path TEXT
      )
    ''');

    // Tabel Data Utama yang menyimpan nama tempat dan koordinat untuk integrasi Maps
    await db.execute('''
      CREATE TABLE destinasi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_tempat TEXT,
        deskripsi TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');
  }

  // LINGKUP FITUR: LOGIN, SIGN UP, EDIT PROFIL
  // Fitur Sign Up: Menyimpan user baru ke database
  Future<int> registerUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  // Fitur Login: Memvalidasi email dan password
  Future<List<Map<String, dynamic>>> loginCheck(String email, String password) async {
    Database db = await database;
    return await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
  }

  // Mendapatkan data profil berdasarkan ID (untuk ditampilkan di halaman edit)
  Future<Map<String, dynamic>?> getUserProfile(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Fitur Edit Profil: Mengubah data nama atau password user
  Future<int> updateUserProfile(int id, Map<String, dynamic> dataBaru) async {
    Database db = await database;
    return await db.update(
      'users',
      dataBaru,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // TAMBAHAN: LINGKUP FITUR LUPA PASSWORD
  // Cek apakah email terdaftar di database lokal
  Future<bool> checkEmailExists(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Memperbarui password berdasarkan email
  Future<int> resetPasswordByEmail(String email, String newPassword) async {
    Database db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // LINGKUP FITUR: CRUD DATA UTAMA & MAPS
  // Create (Tambah & Simpan Data)
  Future<int> insertDestinasi(Map<String, dynamic> lokasi) async {
    Database db = await database;
    return await db.insert('destinasi', lokasi);
  }

  // Read (Tampil Data untuk daftar tempat tujuan di aplikasi)
  Future<List<Map<String, dynamic>>> getAllDestinasi() async {
    Database db = await database;
    return await db.query('destinasi', orderBy: 'id DESC');
  }

  // Update (Ubah Data Tempat/Koordinat)
  Future<int> updateDestinasi(int id, Map<String, dynamic> lokasiBaru) async {
    Database db = await database;
    return await db.update(
      'destinasi',
      lokasiBaru,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete (Hapus Data - Opsional tapi melengkapi syarat CRUD)
  Future<int> deleteDestinasi(int id) async {
    Database db = await database;
    return await db.delete(
      'destinasi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}