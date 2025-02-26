class SubscriptionModel {
  final int? id;
  final String name;
  final double amount;
  final String renewalDate;
  final int cardId;

  SubscriptionModel({
    this.id,
    required this.name,
    required this.amount,
    required this.renewalDate,
    required this.cardId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'renewal_date': renewalDate,
      'card_id': cardId,
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      renewalDate: map['renewal_date'],
      cardId: map['card_id'],
    );
  }
}
