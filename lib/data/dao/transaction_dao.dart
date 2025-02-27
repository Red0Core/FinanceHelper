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
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(int id) async {
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

  Future<double> getCardBalance(int cardId) async {
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(
        CASE 
          WHEN type = 'income' THEN amount 
          ELSE -amount 
        END
      ) as balance
      FROM transactions
      WHERE card_id = ?
    ''', [cardId]);

    if (result.isNotEmpty && result[0]['balance'] != null) {
      return result[0]['balance'] as double;
    } else {
      return 0.0; // No transactions for the card
    }
  }
}
