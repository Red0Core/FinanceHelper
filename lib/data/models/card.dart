import 'package:finance_helper/data/database.dart';

class CardModel {
  final int? id;
  final String name;

  CardModel({
    this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CardModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  Future<double> get balance async {
    return await AppDatabase.instance.transactionDao.getCardBalance(id!);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'],
      name: map['name'],
    );
  }
}
