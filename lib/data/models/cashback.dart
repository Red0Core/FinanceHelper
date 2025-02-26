class CashbackModel {
  final int? id;
  final int cardId;
  final String category;
  final double percentage;

  CashbackModel({
    this.id,
    required this.cardId,
    required this.category,
    required this.percentage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardId': cardId,
      'category': category,
      'percentage': percentage,
    };
  }

  factory CashbackModel.fromMap(Map<String, dynamic> map) {
    return CashbackModel(
      id: map['id'],
      cardId: map['cardId'],
      category: map['category'],
      percentage: map['percentage'],
    );
  }
}
