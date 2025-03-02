import 'package:sqflite/sqflite.dart';
import 'package:finance_helper/data/models/transaction.dart';

class TransactionDao {
  final Database db;

  TransactionDao(this.db);

  Future<void> insertTransaction(TransactionModel transaction) async {
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final List<Map<String, dynamic>> maps = await db.query('transactions');

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransactionById(int id) async {
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TransactionModel>> getAllTransactionsByCardId(int cardId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'card_id = ?',
      whereArgs: [cardId],
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return TransactionModel.fromMap(maps.first);
  }
}
