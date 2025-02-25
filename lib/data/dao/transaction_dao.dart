import '../database.dart';
import '../models/transaction.dart';

class TransactionDao {
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<int> deleteTransaction(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}