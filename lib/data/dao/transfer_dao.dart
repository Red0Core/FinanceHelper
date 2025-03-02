import 'package:sqflite/sqflite.dart';
import 'package:finance_helper/data/models/transaction.dart';

class TransferDao {
  final Database db;

  TransferDao(this.db);

  Future<int> insertTransfer(TransferModel transfer) async {
    return await db.insert('transfers', transfer.toMap());
  }

  Future<void> updateTransfer(TransferModel transfer) async {
    await db.update(
      'transfers',
      transfer.toMap(),
      where: 'id = ?',
      whereArgs: [transfer.id],
    );
  }

  Future<void> deleteTransferById(int id) async {
    await db.delete(
      'transfers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TransferModel>> getAllTransfers() async {
    final List<Map<String, dynamic>> maps = await db.query('transfers');
    return maps.map((map) => TransferModel.fromMap(map)).toList();
  }
}