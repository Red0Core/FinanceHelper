import 'package:sqflite/sqflite.dart';
import 'package:finance_helper/data/models/cashback.dart';

class CashbackDao {
  final Database db;

  CashbackDao(this.db);

  Future<void> insertCashback(CashbackModel cashback) async {
    await db.insert(
      'cashback',
      cashback.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CashbackModel>> getCashbacksByCardId(int cardId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'cashback',
      where: 'cardId = ?',
      whereArgs: [cardId],
    );
    return List.generate(maps.length, (i) {
      return CashbackModel.fromMap(maps[i]);
    });
  }

  Future<void> updateCashback(CashbackModel cashback) async {
    await db.update(
      'cashback',
      cashback.toMap(),
      where: 'id = ?',
      whereArgs: [cashback.id],
    );
  }

  Future<void> deleteCashback(int id) async {
    await db.delete(
      'cashback',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CashbackModel>> getAllCashbacks() async {
    final List<Map<String, dynamic>> maps = await db.query('cashback');
    return List.generate(maps.length, (i) {
      return CashbackModel.fromMap(maps[i]);
    });
  }
}
