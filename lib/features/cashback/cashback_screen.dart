import 'package:flutter/material.dart';
import 'package:finance_helper/data/database.dart';
import 'package:finance_helper/data/models/cashback.dart';
import 'package:finance_helper/data/models/card.dart';

class CashbackScreen extends StatefulWidget {
  final Function(VoidCallback callback) setFABCallback;
  const CashbackScreen({super.key, required this.setFABCallback});

  @override
  State<CashbackScreen> createState() => _CashbackScreenState();
}

class _CashbackScreenState extends State<CashbackScreen> {
  List<CashbackModel> _cashbacks = [];
  List<CardModel> _cards = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setFABCallback(_addCashback);
    });
    _loadData();
  }

  Future<void> _loadData() async {
    final cashbacks = await AppDatabase.instance.cashbackDao.getAllCashbacks();
    final cards = await AppDatabase.instance.cardDao.getAllCards();
    setState(() {
      _cashbacks = cashbacks;
      _cards = cards;
    });
  }

  Future<void> _addCashback() async {
    TextEditingController categoryController = TextEditingController();
    TextEditingController percentageController = TextEditingController();
    CardModel? selectedCard;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Добавить кешбек'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Категория'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: percentageController,
                  decoration: const InputDecoration(labelText: 'Процент кешбека'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownMenu<CardModel?>(
                  initialSelection: selectedCard,
                  label: const Text('Выберите карту'),
                  onSelected: (newCard) {
                    setState(() {
                      selectedCard = newCard;
                    });
                  },
                  dropdownMenuEntries: _cards.map((card) {
                    return DropdownMenuEntry<CardModel>(
                      value: card,
                      label: card.name,
                    );
                  }).toList()
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedCard == null || categoryController.text.isEmpty || percentageController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Заполните все поля!')),
                    );
                    return;
                  }

                  final newCashback = CashbackModel(
                    cardId: selectedCard!.id!,
                    category: categoryController.text,
                    percentage: double.tryParse(percentageController.text) ?? 0.0,
                  );
                  await AppDatabase.instance.cashbackDao.insertCashback(newCashback);
                  _loadData();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editCashback(CashbackModel cashback) async {
    TextEditingController categoryController = TextEditingController(text: cashback.category);
    TextEditingController percentageController = TextEditingController(text: cashback.percentage.toString());
    CardModel? selectedCard = _cards.firstWhere((c) => c.id == cashback.cardId);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Редактировать кешбек'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Категория'),
                ),
                TextField(
                  controller: percentageController,
                  decoration: const InputDecoration(labelText: 'Процент кешбека'),
                  keyboardType: TextInputType.number,
                ),
                DropdownMenu<CardModel>(
                  initialSelection: selectedCard,
                  label: const Text('Выберите карту'),
                  onSelected: (newCard) {
                    setState(() {
                      selectedCard = newCard;
                    });
                  },
                  dropdownMenuEntries: _cards.map((card) {
                    return DropdownMenuEntry<CardModel>(
                      value: card,
                      label: card.name,
                    );
                  }).toList()
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updatedCashback = CashbackModel(
                    id: cashback.id,
                    cardId: selectedCard!.id!,
                    category: categoryController.text,
                    percentage: double.tryParse(percentageController.text) ?? cashback.percentage,
                  );
                  await AppDatabase.instance.cashbackDao.updateCashback(updatedCashback);
                  _loadData();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteCashback(int id) async {
    await AppDatabase.instance.cashbackDao.deleteCashback(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кешбеки'),
      ),
      body: ListView.builder(
        itemCount: _cashbacks.length,
        itemBuilder: (context, index) {
          final cashback = _cashbacks[index];
          final card = _cards.firstWhere((c) => c.id == cashback.cardId, orElse: () => CardModel(id: -1, name: 'Неизвестная карта'));
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('${cashback.category} - ${cashback.percentage}%'),
              subtitle: Text('Карта: ${card.name}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editCashback(cashback),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCashback(cashback.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
