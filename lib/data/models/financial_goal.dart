class FinancialGoalModel {
  final int? id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;

  FinancialGoalModel({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'deadline': deadline?.toIso8601String(),
    };
  }

  factory FinancialGoalModel.fromMap(Map<String, dynamic> map) {
    return FinancialGoalModel(
      id: map['id'],
      name: map['name'],
      targetAmount: map['target_amount'],
      savedAmount: map['saved_amount'],
      deadline: DateTime.tryParse(map['deadline']),
    );
  }
}