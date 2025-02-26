import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:finance_helper/data/models/transaction.dart';
import 'package:finance_helper/data/models/card.dart';
import 'package:finance_helper/data/database.dart';
import 'package:finance_helper/data/models/cashback.dart';
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
  String _selectedTransactionType = 'all';
  List<CashbackModel> _cashbacks = [];

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
    final cashbacks = await AppDatabase.instance.cashbackDao.getAllCashbacks();

    transactions.sort((b, a) => a.date.compareTo(b.date));

    for (var card in cards) {
      card.balance = _calculateCardBalance(card.id!, transactions);
      await AppDatabase.instance.cardDao.updateCard(card);
    }
    setState(() {
      _transactions = transactions;
      _cards = cards;
      _cashbacks = cashbacks;
    });
  }

  List<TransactionModel> _filteredTransactionsByCurrentCardAndType() {
    return _transactions.where((t) {
      // Фильтрация по карте, если карта выбрана
      if (_selectedCard != null && t.cardId != _selectedCard!.id) {
        return false;
      }
      
      // Фильтрация по типу транзакции
      if (_selectedTransactionType != 'all' && t.type != _selectedTransactionType) {
        return false;
      }
      
      return true;
    }).toList();
  }

  void _checkCashbackOptimization(TransactionModel transaction) {
    final relevantCashbacks = _cashbacks.where((c) => c.category == transaction.category).toList();
    if (relevantCashbacks.isNotEmpty) {
      final bestCashback = relevantCashbacks.reduce((a, b) => a.percentage > b.percentage ? a : b);
      if (bestCashback.cardId != transaction.cardId) {
        final betterCard = _cards.firstWhere((c) => c.id == bestCashback.cardId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Лучше использовать карту ${betterCard.name} для этой транзакции (кешбек ${bestCashback.percentage}%)'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<CardModel?>(
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
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedTransactionType,
                    onChanged: (String? newValue) {
                      setState(() {
                      _selectedTransactionType = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem(value: 'all', child: Text('Все')),
                      DropdownMenuItem(value: 'income', child: Text('Доход')),
                      DropdownMenuItem(value: 'expense', child: Text('Расход')),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTransactionsByCurrentCardAndType().length,
              itemBuilder: (context, index) {
                final transaction = _filteredTransactionsByCurrentCardAndType()[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(transaction.category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('${NumberFormat.currency(symbol: '₽').format(transaction.amount)} (${transaction.cardId}) • ${DateFormat("dd MMM yyy, HH:mm").format(transaction.date)}'),
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
                            onPressed: () {
                              showTransactionBottomSheet(
                                context,
                                transaction,
                                _cards,
                                _loadData,
                              );
                              _checkCashbackOptimization(transaction);
                            }
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
