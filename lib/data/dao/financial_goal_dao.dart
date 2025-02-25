import '../database.dart';
import '../models/financial_goal.dart';

class FinancialGoalDao {
  Future<int> insertGoal(FinancialGoal goal) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('financial_goals', goal.toMap());
  }

  Future<List<FinancialGoal>> getAllGoals() async {
    final db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('financial_goals');
    return List.generate(maps.length, (i) {
      return FinancialGoal.fromMap(maps[i]);
    });
  }

  Future<int> deleteGoal(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.delete(
      'financial_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
