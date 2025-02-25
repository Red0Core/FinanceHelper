class Card {
  final int? id;
  final String name;
  final double balance;
  final String? cashback;

  Card({
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

  factory Card.fromMap(Map<String, dynamic> map) {
    return Card(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      cashback: map['cashback'],
    );
  }
}
