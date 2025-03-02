enum TransactionType {
  all('all'),
  income('income'),
  expense('expense'),
  transfer('transfer');

  final String value;
  const TransactionType(this.value);

  factory TransactionType.fromString(String value) {
    switch (value) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.all;
    }
  }
}

sealed class TransactionInterface {
  int? get id;
  double get amount;
  DateTime get date;
  String? get description;
}

class TransactionModel extends TransactionInterface {
  @override
  final int? id;
  @override
  final double amount;
  @override
  final DateTime date;
  @override
  final String? description;
  final String category;
  final TransactionType type;
  final int cardId;

  TransactionModel({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    required this.cardId,
    this.description,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) =>
    TransactionModel(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      type: TransactionType.fromString(map['type']),
      cardId: map['card_id'],
      description: map['description'],
    );

  Map<String, dynamic> toMap() =>
    {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type.value,
      'card_id': cardId,
      'description': description,
    };
}

class TransferModel extends TransactionInterface {
  @override
  final int? id;
  @override
  final double amount;
  @override
  final DateTime date;
  @override
  final String? description;
  final int sourceCardId;
  final int destinationCardId;

  TransferModel({
    this.id,
    required this.amount,
    required this.date,
    required this.sourceCardId,
    required this.destinationCardId,
    this.description
  });

  factory TransferModel.fromMap(Map<String, dynamic> map) =>
    TransferModel(
      id: map['id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      sourceCardId: map['source_card_id'],
      destinationCardId: map['destination_card_id'],
      description: map['description'],
    );
  
  Map<String, dynamic> toMap() =>
    {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'source_card_id': sourceCardId,
      'destination_card_id': destinationCardId,
      'description': description,
    };
}
