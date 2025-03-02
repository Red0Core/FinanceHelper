import 'package:finance_helper/data/dao/category_dao.dart';
import 'package:finance_helper/data/dao/transfer_dao.dart';
import 'package:finance_helper/data/models/category.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:finance_helper/data/dao/card_dao.dart';
import 'package:finance_helper/data/dao/transaction_dao.dart';
import 'package:finance_helper/data/dao/cashback_dao.dart';
import 'package:finance_helper/data/dao/subscription_dao.dart';
import 'package:finance_helper/data/dao/financial_goal_dao.dart';
import 'package:finance_helper/data/models/card.dart';
import 'package:finance_helper/data/models/transaction.dart';
import 'dart:math';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  // Private DAOs
  late final CardDao _cardDao;
  late final TransactionDao _transactionDao;
  late final CashbackDao _cashbackDao;
  late final SubscriptionDao _subscriptionDao;
  late final FinancialGoalDao _financialGoalDao;
  late final TransferDao _transferDao;
  late final CategoryDao _categoryDao;

  AppDatabase._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance.db');
    await _initializeDaos();
    return _database!;
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

  Future<void> _initializeDaos() async {
    final db = await database;
    _cardDao = CardDao(db);
    _transactionDao = TransactionDao(db);
    _cashbackDao = CashbackDao(db);
    _subscriptionDao = SubscriptionDao(db);
    _financialGoalDao = FinancialGoalDao(db);
    _transferDao = TransferDao(db);
    _categoryDao = CategoryDao(db);
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
        description TEXT,
        FOREIGN KEY (card_id) REFERENCES cards (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE transfers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_card_id INTEGER NOT NULL,
        destination_card_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (source_card_id) REFERENCES cards (id) ON DELETE CASCADE,
        FOREIGN KEY (destination_card_id) REFERENCES cards (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
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
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        emoji TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE subcategories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        emoji TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');
  }

  // Геттеры DAO
  CardDao get cardDao => _cardDao;
  TransactionDao get transactionDao => _transactionDao;
  CashbackDao get cashbackDao => _cashbackDao;
  SubscriptionDao get subscriptionDao => _subscriptionDao;
  FinancialGoalDao get financialGoalDao => _financialGoalDao;
  TransferDao get transferDao => _transferDao;
  CategoryDao get categoryDao => _categoryDao;

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> recreateAndFillDatabaseWithTestData() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'finance.db');
    await deleteDatabase(path);
    _database = null;
    await database;

    final cards = [
      CardModel(name: 'Сбербанк'),
      CardModel(name: 'Тинькофф'),
      CardModel(name: 'Райффайзен'),
      CardModel(name: 'Альфа-Банк'),
    ];

    for (final card in cards) {
      await AppDatabase.instance.cardDao.insertCard(card);
    }

    final insertedCards = await AppDatabase.instance.cardDao.getAllCards();
    final random = Random();

    final categories = ['Еда', 'Транспорт', 'Развлечения', 'Зарплата', 'Одежда', 'Дом', 'Подарки'];
    final types = [TransactionType.expense, TransactionType.income, TransactionType.transfer];

    final now = DateTime.now();

    for (int i = 0; i < 20; i++) {
      final type = types[random.nextInt(types.length)];
      final cardId = insertedCards[random.nextInt(insertedCards.length)].id!;
      final amount = double.parse((random.nextDouble() * 1000).toStringAsFixed(2));
      final date = now.subtract(Duration(days: random.nextInt(30)));
      if (type == TransactionType.transfer) {
        await AppDatabase.instance.transferDao.insertTransfer(
            TransferModel(
              amount: amount,
              date: date,
              sourceCardId: cardId,
              destinationCardId: insertedCards.where((c) => c.id != cardId).toList()[random.nextInt(insertedCards.length - 1)].id!,
            )
        );
      }
      else {
        await AppDatabase.instance.transactionDao.insertTransaction(
            TransactionModel(
              amount: amount,
              category: categories[random.nextInt(categories.length)],
              date: date,
              type: type,
              cardId: cardId,
            )
        );
      }
    }
  }

  Future<void> setDefaultCategories() async {
    // Значит уже есть категории
    if ((await AppDatabase.instance.categoryDao.getAllCategories()).isNotEmpty) {
      return;
    }
    // Список категорий
    final defaultCategories = [
      CategoryModel(name: 'Еда и питание', emoji: '🍽️'),
      CategoryModel(name: 'Транспорт', emoji: '🚗'),
      CategoryModel(name: 'Жильё', emoji: '🏠'),
      CategoryModel(name: 'Покупки', emoji: '🛍️'),
      CategoryModel(name: 'Здоровье', emoji: '🏥'),
      CategoryModel(name: 'Развлечения', emoji: '🎭'),
      CategoryModel(name: 'Путешествия', emoji: '✈️'),
      CategoryModel(name: 'Образование', emoji: '📚'),
      CategoryModel(name: 'Финансы', emoji: '💰'),
      CategoryModel(name: 'Доход', emoji: '💵'),
      CategoryModel(name: 'Подписки', emoji: '📱'),
    ];

    for (final category in defaultCategories) {
      await AppDatabase.instance.categoryDao.insertCategory(category);
    }

    final insertedCategories = await AppDatabase.instance.categoryDao.getAllCategories();
    
    // Список подкатегорий (добавлять после получения insertedCategories)
    final defaultSubcategories = [
      // Еда и питание
      SubcategoryModel(categoryId: insertedCategories[0].id!, name: 'Продукты', emoji: '🛒'),
      SubcategoryModel(categoryId: insertedCategories[0].id!, name: 'Кафе и рестораны', emoji: '🍝'),
      SubcategoryModel(categoryId: insertedCategories[0].id!, name: 'Доставка еды', emoji: '🛵'),
      SubcategoryModel(categoryId: insertedCategories[0].id!, name: 'Фастфуд', emoji: '🍔'),
      SubcategoryModel(categoryId: insertedCategories[0].id!, name: 'Кофейни', emoji: '☕'),
      
      // Транспорт
      SubcategoryModel(categoryId: insertedCategories[1].id!, name: 'Общественный транспорт', emoji: '🚇'),
      SubcategoryModel(categoryId: insertedCategories[1].id!, name: 'Такси', emoji: '🚕'),
      SubcategoryModel(categoryId: insertedCategories[1].id!, name: 'Топливо', emoji: '⛽'),
      SubcategoryModel(categoryId: insertedCategories[1].id!, name: 'Парковка', emoji: '🅿️'),
      SubcategoryModel(categoryId: insertedCategories[1].id!, name: 'Автосервис', emoji: '🔧'),
      
      // Жильё
      SubcategoryModel(categoryId: insertedCategories[2].id!, name: 'Аренда', emoji: '🔑'),
      SubcategoryModel(categoryId: insertedCategories[2].id!, name: 'Ипотека', emoji: '🏦'),
      SubcategoryModel(categoryId: insertedCategories[2].id!, name: 'Коммунальные платежи', emoji: '💡'),
      SubcategoryModel(categoryId: insertedCategories[2].id!, name: 'Интернет и ТВ', emoji: '📡'),
      SubcategoryModel(categoryId: insertedCategories[2].id!, name: 'Ремонт', emoji: '🔨'),
      
      // Покупки
      SubcategoryModel(categoryId: insertedCategories[3].id!, name: 'Одежда', emoji: '👕'),
      SubcategoryModel(categoryId: insertedCategories[3].id!, name: 'Электроника', emoji: '📱'),
      SubcategoryModel(categoryId: insertedCategories[3].id!, name: 'Косметика', emoji: '💄'),
      SubcategoryModel(categoryId: insertedCategories[3].id!, name: 'Товары для дома', emoji: '🏡'),
      SubcategoryModel(categoryId: insertedCategories[3].id!, name: 'Подарки', emoji: '🎁'),
      
      // Здоровье
      SubcategoryModel(categoryId: insertedCategories[4].id!, name: 'Лекарства', emoji: '💊'),
      SubcategoryModel(categoryId: insertedCategories[4].id!, name: 'Врач', emoji: '👨‍⚕️'),
      SubcategoryModel(categoryId: insertedCategories[4].id!, name: 'Стоматология', emoji: '🦷'),
      SubcategoryModel(categoryId: insertedCategories[4].id!, name: 'Фитнес', emoji: '🏋️'),
      SubcategoryModel(categoryId: insertedCategories[4].id!, name: 'Салоны красоты', emoji: '💇'),
      
      // Развлечения
      SubcategoryModel(categoryId: insertedCategories[5].id!, name: 'Кино', emoji: '🎬'),
      SubcategoryModel(categoryId: insertedCategories[5].id!, name: 'Концерты', emoji: '🎵'),
      SubcategoryModel(categoryId: insertedCategories[5].id!, name: 'Игры', emoji: '🎮'),
      SubcategoryModel(categoryId: insertedCategories[5].id!, name: 'Хобби', emoji: '🎨'),
      SubcategoryModel(categoryId: insertedCategories[5].id!, name: 'Книги', emoji: '📚'),
      
      // Путешествия
      SubcategoryModel(categoryId: insertedCategories[6].id!, name: 'Отели', emoji: '🏨'),
      SubcategoryModel(categoryId: insertedCategories[6].id!, name: 'Авиабилеты', emoji: '✈️'),
      SubcategoryModel(categoryId: insertedCategories[6].id!, name: 'Экскурсии', emoji: '🧳'),
      SubcategoryModel(categoryId: insertedCategories[6].id!, name: 'Сувениры', emoji: '🎪'),
      
      // Образование
      SubcategoryModel(categoryId: insertedCategories[7].id!, name: 'Курсы', emoji: '👨‍🏫'),
      SubcategoryModel(categoryId: insertedCategories[7].id!, name: 'Учебники', emoji: '📖'),
      SubcategoryModel(categoryId: insertedCategories[7].id!, name: 'Репетиторы', emoji: '👩‍🎓'),
      
      // Финансы
      SubcategoryModel(categoryId: insertedCategories[8].id!, name: 'Кредиты', emoji: '💳'),
      SubcategoryModel(categoryId: insertedCategories[8].id!, name: 'Комиссии', emoji: '🧾'),
      SubcategoryModel(categoryId: insertedCategories[8].id!, name: 'Страхование', emoji: '🔒'),
      SubcategoryModel(categoryId: insertedCategories[8].id!, name: 'Инвестиции', emoji: '📈'),
      
      // Доход
      SubcategoryModel(categoryId: insertedCategories[9].id!, name: 'Зарплата', emoji: '💼'),
      SubcategoryModel(categoryId: insertedCategories[9].id!, name: 'Подработка', emoji: '👨‍💻'),
      SubcategoryModel(categoryId: insertedCategories[9].id!, name: 'Бонусы', emoji: '🎯'),
      SubcategoryModel(categoryId: insertedCategories[9].id!, name: 'Дивиденды', emoji: '📊'),
      SubcategoryModel(categoryId: insertedCategories[9].id!, name: 'Подарки', emoji: '🎊'),
      
      // Подписки
      SubcategoryModel(categoryId: insertedCategories[10].id!, name: 'Стриминг', emoji: '📺'),
      SubcategoryModel(categoryId: insertedCategories[10].id!, name: 'Музыка', emoji: '🎵'),
      SubcategoryModel(categoryId: insertedCategories[10].id!, name: 'Приложения', emoji: '📲'),
      SubcategoryModel(categoryId: insertedCategories[10].id!, name: 'Игровые', emoji: '🎮'),
      SubcategoryModel(categoryId: insertedCategories[10].id!, name: 'Другие', emoji: '🔄'),
    ];

    for (final subcategory in defaultSubcategories) {
      await AppDatabase.instance.categoryDao.insertSubcategory(subcategory);
    }
  }

}
