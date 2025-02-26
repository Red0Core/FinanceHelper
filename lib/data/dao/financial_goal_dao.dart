import 'package:sqflite/sqflite.dart';
import 'package:finance_helper/data/models/financial_goal.dart';

class FinancialGoalDao {
  final Database db;

  FinancialGoalDao(this.db);

  Future<void> insertFinancialGoal(FinancialGoalModel goal) async {
    await db.insert(
      'financial_goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FinancialGoalModel>> getAllFinancialGoals() async {
    final List<Map<String, dynamic>> maps = await db.query('financial_goals');
    return List.generate(maps.length, (i) {
      return FinancialGoalModel.fromMap(maps[i]);
    });
  }

  Future<void> updateFinancialGoal(FinancialGoalModel goal) async {
    await db.update(
      'financial_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteFinancialGoal(int id) async {
    await db.delete(
      'financial_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
