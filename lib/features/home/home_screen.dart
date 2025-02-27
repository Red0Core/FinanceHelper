import 'package:finance_helper/data/database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:finance_helper/data/models/card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<CardModel> _cards = [];
  Map<int, double> _cardBalances = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await AppDatabase.instance.cardDao.getAllCards();
    Map<int, double> balances = {};
    for (var card in cards) {
      balances[card.id!] = await card.balance;
    }

    if (!mounted) return;
    setState(() {
      _cards = cards;
      _cardBalances = balances;
      _isLoading = false;
    });
  }

  Future<void> _addCard() async {
    await AppDatabase.instance.cardDao.insertCard(CardModel(name: 'Новая карта'));
    _loadCards();
  }

  Future<void> _deleteCard(int cardId) async {
    final transactions = await AppDatabase.instance.transactionDao.getAllTransactions();
    if (transactions.any((t) => t.cardId == cardId)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нельзя удалить карту с транзакциями!')),
      );
      return;
    }
    await AppDatabase.instance.cardDao.deleteCard(cardId);
    _loadCards();
  }

  Future<void> _editCard(CardModel card) async {
    TextEditingController nameController = TextEditingController(text: card.name);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать карту'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Название карты'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedCard = CardModel(
                id: card.id,
                name: nameController.text,
              );
              await AppDatabase.instance.cardDao.updateCard(updatedCard);
              _loadCards();
              if (context.mounted) {
                context.pop();
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Баланс')),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : Column(
          children: [
            _cards.isEmpty
            ? const Expanded(child: Center(child: Text("Нет карт")))
            : Expanded(
              child: ListView.builder(
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text("${card.name} (${card.id})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text('Баланс: ${NumberFormat.currency(symbol: '₽').format(_cardBalances[card.id] ?? 0.0)}'),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCard(card.id!),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editCard(card),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _addCard,
                    child: const Text('Добавить карту'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.goNamed('transactions'),
                    child: const Text('Перейти к транзакциям'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.goNamed('cashback'),
                    child: const Text('Перейти к кешбекам'),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
}