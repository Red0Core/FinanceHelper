import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:finance_helper/data/models/transaction.dart';
import 'package:finance_helper/data/models/card.dart';
import 'package:finance_helper/data/database.dart';
import 'show_transcation_bottom_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<TransactionModel> _transactions = [];
  List<CardModel> _cards = [];
  CardModel? _selectedCard;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _deleteTransaction(int id) async {
    await AppDatabase.instance.transactionDao.deleteTransaction(id);
    final transactions = await AppDatabase.instance.transactionDao.getAllTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  double _calculateCardBalance(int cardId, List<TransactionModel> transactions) {
    double balance = 0.0;
    for (var transaction in transactions.where((t) => t.cardId == cardId)) {
      balance += transaction.type == 'income' ? transaction.amount : -transaction.amount;
    }
    return balance;
  }

  Future<void> _loadData() async {
    final transactions = await AppDatabase.instance.transactionDao.getAllTransactions();
    final cards = await AppDatabase.instance.cardDao.getAllCards();

    transactions.sort((b, a) => a.date.compareTo(b.date));

    for (var card in cards) {
      card.balance = _calculateCardBalance(card.id!, transactions);
      await AppDatabase.instance.cardDao.updateCard(card);
    }
    setState(() {
      _transactions = transactions;
      _cards = cards;
    });
  }

  List<TransactionModel> _filteredTransactionsByCurrentCard() {
    if (_selectedCard == null) return _transactions; // Если карта не выбрана, показываем все транзакции
    return _transactions.where((t) => t.cardId == _selectedCard!.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Транзакции'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          if (_cards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<CardModel?>(
                value: _selectedCard,
                hint: const Text('Выберите карту'),
                onChanged: (newCard) {
                  setState(() {
                    _selectedCard = newCard;
                  });
                },
                items: [
                  const DropdownMenuItem<CardModel?>(
                    value: null,
                    child: Text('Все карты'),
                  ),
                  ..._cards.map((card) {
                    return DropdownMenuItem<CardModel?>(
                      value: card,
                      child: Text(card.name),
                    );
                  }),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTransactionsByCurrentCard().length,
              itemBuilder: (context, index) {
                final transaction = _filteredTransactionsByCurrentCard()[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(transaction.category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('${NumberFormat.currency(locale: 'ru_RU', symbol: '₽').format(transaction.amount)} (${transaction.cardId}) • ${DateFormat("dd MMM yyy, HH:mm").format(transaction.date)}'),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => confirmDeleteTransaction(context, transaction.id!, () => _deleteTransaction(transaction.id!)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showTransactionBottomSheet(
                              context,
                              transaction,
                              _cards,
                              _loadData,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTransactionBottomSheet(
          context,
          null,
          _cards,
          _loadData,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
