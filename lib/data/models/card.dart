class CardModel {
  final int? id;
  final String name;
  final double balance;
  final String? cashback;

  CardModel({
    this.id,
    required this.name,
    required this.balance,
    this.cashback,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'cashback': cashback,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      cashback: map['cashback'],
    );
  }
}
