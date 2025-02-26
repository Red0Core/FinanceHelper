import 'package:sqflite/sqflite.dart';
import 'package:finance_helper/data/models/subscription.dart';

class SubscriptionDao {
  final Database db;

  SubscriptionDao(this.db);

  Future<void> insertSubscription(SubscriptionModel subscription) async {
    await db.insert(
      'subscriptions',
      subscription.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SubscriptionModel>> getAllSubscriptions() async {
    final List<Map<String, dynamic>> maps = await db.query('subscriptions');
    return List.generate(maps.length, (i) {
      return SubscriptionModel.fromMap(maps[i]);
    });
  }

  Future<void> updateSubscription(SubscriptionModel subscription) async {
    await db.update(
      'subscriptions',
      subscription.toMap(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
  }

  Future<void> deleteSubscription(int id) async {
    await db.delete(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
