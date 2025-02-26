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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await AppDatabase.instance.cardDao.getAllCards();
    if (!mounted) return;
    setState(() {
      _cards = cards;
      _isLoading = false;
    });
  }

  Future<void> _addCard() async {
    await AppDatabase.instance.cardDao.insertCard(CardModel(name: 'Новая карта', balance: 1000.0));
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
    TextEditingController balanceController = TextEditingController(text: card.balance.toString());

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
            TextField(
              controller: balanceController,
              decoration: const InputDecoration(labelText: 'Баланс'),
              keyboardType: TextInputType.number,
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
                balance: double.tryParse(balanceController.text) ?? card.balance,
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
          ? const Center(child: Text("Нет карт"))
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
                    subtitle: Text('Баланс: ${NumberFormat.currency(locale: 'ru_RU', symbol: '₽').format(card.balance)}'),
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
                  onPressed: () => context.go('/transactions'),
                  child: const Text('Перейти к транзакциям'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}