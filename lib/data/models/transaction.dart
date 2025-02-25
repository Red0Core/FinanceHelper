class Transaction {
  final int? id;
  final double amount;
  final String category;
  final String date;
  final String type;
  final int cardId;

  Transaction({
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
      'date': date,
      'type': type,
      'card_id': cardId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'],
      type: map['type'],
      cardId: map['card_id'],
    );
  }
}

