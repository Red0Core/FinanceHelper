import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:finance_helper/data/dao/card_dao.dart';
import 'package:finance_helper/data/dao/transaction_dao.dart';
import 'package:finance_helper/data/dao/cashback_dao.dart';
import 'package:finance_helper/data/dao/subscription_dao.dart';
import 'package:finance_helper/data/dao/financial_goal_dao.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  late final CardDao cardDao;
  late final TransactionDao transactionDao;
  late final CashbackDao cashbackDao;
  late final SubscriptionDao subscriptionDao;
  late final FinancialGoalDao financialGoalDao;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance.db');
    _initializeDaos();
    return _database!;
  }

  void _initializeDaos() {
    cardDao = CardDao(_database!);
    transactionDao = TransactionDao(_database!);
    cashbackDao = CashbackDao(_database!);
    subscriptionDao = SubscriptionDao(_database!);
    financialGoalDao = FinancialGoalDao(_database!);
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        card_id INTEGER NOT NULL,
        FOREIGN KEY (card_id) REFERENCES cards (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        cashback TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE subscriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        renewal_date TEXT NOT NULL,
        card_id INTEGER NOT NULL,
        FOREIGN KEY (card_id) REFERENCES cards (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE financial_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        saved_amount REAL NOT NULL,
        deadline TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE cashback (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cardId INTEGER NOT NULL,
        category TEXT NOT NULL,
        percentage REAL NOT NULL,
        FOREIGN KEY (cardId) REFERENCES cards (id) ON DELETE CASCADE
      )
    ''');

  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
