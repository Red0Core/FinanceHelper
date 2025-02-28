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
  List<TransactionModel> _filteredTransactions = [];
  List<CardModel> _cards = [];
  CardModel? _selectedCard;
  TransactionType _selectedTransactionType = TransactionType.all;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _deleteTransaction(int id) async {
    await AppDatabase.instance.transactionDao.deleteTransaction(id);
    await _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await AppDatabase.instance.transactionDao.getAllTransactions();

    transactions.sort((b, a) => a.date.compareTo(b.date));

    setState(() {
      _transactions = transactions;
      _filteredTransactions = _filterTransactionByCardAndType(_transactions, _selectedCard, _selectedTransactionType);
    });
  }
  
  Future<void> _loadCards() async {
    final cards = await AppDatabase.instance.cardDao.getAllCards();
    setState(() {
      _cards = cards;
    });
  }

  Future<void> _loadData() async {
    await _loadCards(); // Load Cards first to populate the dropdown
    await _loadTransactions();
  }

  List<TransactionModel> _filterTransactionByCardAndType(
    List<TransactionModel> transactions,
    CardModel? card,
    TransactionType transactionType
  ) {
    return transactions.where((t) {
      // Фильтрация по карте, если карта выбрана
      if (card != null && t.cardId != card.id) {
        return false;
      }
      
      // Фильтрация по типу транзакции
      if (transactionType != TransactionType.all && t.type != transactionType) {
        return false;
      }
      
      return true;
    }).toList();
  }

  void _filterTransactions() {
    setState(() { // Use setState here to trigger a rebuild of the ListView
      _filteredTransactions = _filterTransactionByCardAndType(_transactions, _selectedCard, _selectedTransactionType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Транзакции')
      ),
      body: Column(
              children: [
                if (_cards.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownMenu<CardModel>(
                          width: MediaQuery.of(context).size.width / 2 - 24,
                          initialSelection: _selectedCard,
                          label: const Text('Карта'),
                          onSelected: (newCard) {
                            setState(() {
                              _selectedCard = newCard;
                              _filterTransactions();
                            });
                          },
                          dropdownMenuEntries: _cards.map((card) {
                            return DropdownMenuEntry<CardModel>(
                              value: card,
                              label: card.name,
                            );
                          }).toList()
                        ),
                        const SizedBox(width: 12),
                        DropdownMenu<TransactionType>(
                          width: MediaQuery.of(context).size.width / 2 - 24,
                          initialSelection: _selectedTransactionType,
                          onSelected: (TransactionType? newValue) {
                            setState(() {
                            _selectedTransactionType = newValue!;
                            _filterTransactions();
                            });
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: TransactionType.all, label: 'Все'),
                            DropdownMenuEntry(value: TransactionType.income, label: 'Доход'),
                            DropdownMenuEntry(value: TransactionType.expense, label: 'Расход'),
                          ],
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return Card(
                        key: ValueKey(transaction.id),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(transaction.category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text('${NumberFormat.currency(symbol: '₽').format(transaction.amount)} (${transaction.cardId}) • ${DateFormat("dd MMM yyy, HH:mm").format(transaction.date)}'),
                          onTap: () => context.push('/transaction/${transaction.id}'),
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
                                  )
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
