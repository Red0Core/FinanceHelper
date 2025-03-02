import 'package:finance_helper/features/transactions/transaction_widget.dart';
import 'package:finance_helper/features/transactions/transfer_widget.dart';
import 'package:flutter/material.dart';
import 'package:finance_helper/data/models/transaction.dart';
import 'package:finance_helper/data/models/card.dart';
import 'package:finance_helper/data/database.dart';
import 'show_transcation_bottom_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  final Function(VoidCallback callback) setFABCallback;
  const TransactionsScreen({super.key, required this.setFABCallback});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<TransactionInterface> _combinedTransactions = [];
  List<TransactionInterface> _transactions = [];
  List<CardModel> _cards = [];
  CardModel? _selectedCard;
  TransactionType _selectedTransactionType = TransactionType.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setFABCallback(() => showTransactionBottomSheet(
            context,
            null,
            _cards,
            _loadTransactions,
          ));
    });
    _loadData();
  }

  Future<void> _loadTransactions() async {
    final transactions = await AppDatabase.instance.transactionDao.getAllTransactions();
    final transfers = await AppDatabase.instance.transferDao.getAllTransfers();

    // Для объединения в единый список можно пометить переводы специальным образом,
    // либо использовать наследование, если хотите отображать их единообразно.
    // Например, можно создать общий интерфейс или базовый класс, который расширяют оба типа.

    // Здесь мы сортируем по дате (предполагается, что обе модели имеют поле date)
    List<TransactionInterface> combined = [...transactions, ...transfers];
    combined.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _transactions = combined;
      _combinedTransactions = combined;
    });
  }
  
  Future<void> _loadCards() async {
    final cards = await AppDatabase.instance.cardDao.getAllCards();
    setState(() {
      _cards = cards;
    });
  }

  Future<void> _loadData() async {
    await _loadCards(); // Загружаем карты первыми, чтобы они были доступны для фильтрации
    await _loadTransactions();
  }

  List<TransactionInterface> _filterTransactions() {
    // Транзакции всегда отсортированы по дате, поэтому просто идет фильтрация по выбранным параметрам
    
    return _transactions.where((t) {
      // Если выбрана карта, фильтруем по ней:
      if (_selectedCard != null) {
        if (t is TransactionModel) {
          // Фильтрация для обычных транзакций
          if (t.cardId != _selectedCard!.id) {
            return false;
          }
        }
        else if (t is TransferModel) {
          // Для переводов показываем, если выбранная карта является исходной или целевой
          if (_selectedCard!.id != t.sourceCardId &&
              _selectedCard!.id != t.destinationCardId) {
            return false;
          }
        }
      }
      
      // Фильтрация по типу транзакции для обычных транзакций.
      // Для переводов можно либо игнорировать этот фильтр, либо добавить свою логику (пока не решил)
      if (t is TransactionModel) {
        if (_selectedTransactionType != TransactionType.all &&
            t.type != _selectedTransactionType) {
          return false;
        }
      }
      
      return true;
    }).toList();
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
                        DropdownMenu<CardModel?>(
                          width: MediaQuery.of(context).size.width / 2 - 24,
                          initialSelection: _selectedCard,
                          label: const Text('Карта'),
                          onSelected: (newCard) {
                            setState(() {
                              _selectedCard = newCard;
                              _combinedTransactions = _filterTransactions();
                            });
                          },
                          dropdownMenuEntries: [
                            DropdownMenuEntry<CardModel?>(value: null, label: 'Все'),
                            ..._cards.map((card) {
                              return DropdownMenuEntry<CardModel>(
                                value: card,
                                label: card.name,
                              );
                            })
                          ]
                        ),
                        const SizedBox(width: 12),
                        DropdownMenu<TransactionType>(
                          width: MediaQuery.of(context).size.width / 2 - 24,
                          initialSelection: _selectedTransactionType,
                          onSelected: (TransactionType? newValue) {
                            setState(() {
                              _selectedTransactionType = newValue!;
                              _combinedTransactions = _filterTransactions();
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
                    itemCount: _combinedTransactions.length,
                    itemBuilder: (context, index) {
                      final item = _combinedTransactions[index];
                      switch (item) {
                        case TransferModel():
                          return TransferWidget(
                            transfer: item,
                            cards: _cards,
                            onDelete: () async {
                              await AppDatabase.instance.transferDao.deleteTransferById(item.id!);
                              await _loadTransactions();
                            },
                            onEdit: _loadTransactions,
                          );
                        case TransactionModel():
                          return TransactionWidget(
                            transaction: item,
                            cards: _cards,
                            onDelete: () async {
                              await AppDatabase.instance.transactionDao.deleteTransactionById(item.id!);
                              await _loadTransactions();
                            },
                            onEdit: _loadTransactions,
                          );
                      }
                    }
                  ),
                ),
              ],
            ),
    );
  }
}
