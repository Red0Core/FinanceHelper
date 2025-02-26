import '../database.dart';
import '../models/subscription.dart';

class SubscriptionDao {
  Future<int> insertSubscription(SubscriptionModel subscription) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('subscriptions', subscription.toMap());
  }

  Future<List<SubscriptionModel>> getAllSubscriptions() async {
    final db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('subscriptions');
    return List.generate(maps.length, (i) {
      return SubscriptionModel.fromMap(maps[i]);
    });
  }

  Future<int> deleteSubscription(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.delete(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
