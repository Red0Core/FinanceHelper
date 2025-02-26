class CardModel {
  final int? id;
  final String name;
  double balance;

  CardModel({
    this.id,
    required this.name,
    required this.balance,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CardModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
    );
  }
}
