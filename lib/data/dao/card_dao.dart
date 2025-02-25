import '../database.dart';
import '../models/card.dart';

class CardDao {
  Future<int> insertCard(Card card) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('cards', card.toMap());
  }

  Future<List<Card>> getAllCards() async {
    final db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('cards');
    return List.generate(maps.length, (i) {
      return Card.fromMap(maps[i]);
    });
  }

  Future<int> deleteCard(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}