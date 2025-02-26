class TransactionModel {
  final int? id;
  final double amount;
  final String category;
  final DateTime date;
  final String type;
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
      'type': type,
      'card_id': cardId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      cardId: map['card_id'],
    );
  }
}

