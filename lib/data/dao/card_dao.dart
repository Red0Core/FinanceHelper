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
}
