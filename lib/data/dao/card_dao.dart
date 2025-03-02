import 'package:sqflite/sqflite.dart';
import 'package:finance_helper/data/models/card.dart';

class CardDao {
  final Database db;

  CardDao(this.db);

  Future<void> insertCard(CardModel card) async {
    await db.insert(
      'cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CardModel>> getAllCards() async {
    final List<Map<String, dynamic>> maps = await db.query('cards');
    return List.generate(maps.length, (i) {
      return CardModel.fromMap(maps[i]);
    });
  }

  Future<void> updateCard(CardModel card) async {
    await db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(int id) async {
    await db.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getCardBalance(int cardId) async {
    // Сумма по обычным транзакциям
    final List<Map<String, dynamic>> transactionResult = await db.rawQuery('''
      SELECT SUM(
        CASE 
          WHEN type = 'income' THEN amount 
          ELSE -amount 
        END
      ) as balance
      FROM transactions
      WHERE card_id = ?
    ''', [cardId]);

    double transactionBalance = 0.0;
    if (transactionResult.isNotEmpty && transactionResult[0]['balance'] != null) {
      transactionBalance = transactionResult[0]['balance'] as double;
    }

    // Сумма по переводам, где карта является источником
    final List<Map<String, dynamic>> transferOutResult = await db.rawQuery('''
      SELECT SUM(amount) as transferOut
      FROM transfers
      WHERE source_card_id = ?
    ''', [cardId]);

    double transferOut = 0.0;
    if (transferOutResult.isNotEmpty && transferOutResult[0]['transferOut'] != null) {
      transferOut = transferOutResult[0]['transferOut'] as double;
    }

    // Сумма по переводам, где карта является получателем
    final List<Map<String, dynamic>> transferInResult = await db.rawQuery('''
      SELECT SUM(amount) as transferIn
      FROM transfers
      WHERE destination_card_id = ?
    ''', [cardId]);

    double transferIn = 0.0;
    if (transferInResult.isNotEmpty && transferInResult[0]['transferIn'] != null) {
      transferIn = transferInResult[0]['transferIn'] as double;
    }

    // Итоговый баланс
    return transactionBalance - transferOut + transferIn;
  }
}
