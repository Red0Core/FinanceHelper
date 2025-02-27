enum TransactionType {
  all('all'),
  income('income'),
  expense('expense');

  final String value;
  const TransactionType(this.value);

  factory TransactionType.fromString(String value) {
    switch (value) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        return TransactionType.all;
    }
  }
}

class TransactionModel {
  final int? id;
  final double amount;
  final String category;
  final DateTime date;
  final TransactionType type;
  final int cardId;

  TransactionModel({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    required this.cardId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type.value,
      'card_id': cardId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      type: TransactionType.fromString(map['type']),
      cardId: map['card_id'],
    );
  }
}
