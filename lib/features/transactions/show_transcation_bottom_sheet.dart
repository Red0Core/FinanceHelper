// lib/features/transactions/show_transaction_bottom_sheet.dart
import 'package:finance_helper/features/category/category_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance_helper/data/database.dart';
import 'package:finance_helper/data/models/transaction.dart';
import 'package:finance_helper/data/models/card.dart';
import 'package:finance_helper/data/models/category.dart';

Future<void> showTransactionBottomSheet(
  BuildContext context,
  TransactionInterface? transaction, // теперь принимаем TransactionInterface
  List<CardModel> cards,
  Future<void> Function() onTransactionUpdated,
) async {
  // Контроллеры
  final TextEditingController amountController =
      TextEditingController(text: transaction?.amount.toString() ?? '');
  final TextEditingController descriptionController =
      TextEditingController(text: transaction?.description ?? '');

  // Определяем выбранную карту и тип транзакции
  CardModel? selectedCard;
  CardModel? toCard;
  TransactionType transactionType;
  DateTime? selectedDate = transaction?.date;

  // Переменная для хранения выбранной категории
  CategoryInterface? selectedCategory;
  
  // Инициализируем выбранную категорию, если это редактирование транзакции
  if (transaction is TransactionModel) {
    // Загружаем категорию из базы по имени/ID или используем заглушку
    final categories = await AppDatabase.instance.categoryDao.getAllCategories();
    final subcategories = await AppDatabase.instance.categoryDao.getAllSubcategories();
    
    // Сначала проверяем в подкатегориях (они имеют приоритет)
    selectedCategory = [...subcategories, ...categories].firstWhere(
      (s) => s.name == transaction.category,
      orElse: () => CategoryModel(name: transaction.category)
    );
  }

  if (transaction == null) {
    transactionType = TransactionType.expense;
  } 
  else if (transaction is TransferModel) {
    // Для перевода выбираем две карты
    selectedCard = cards.firstWhere((c) => c.id == transaction.sourceCardId);
    toCard = cards.firstWhere((c) => c.id == transaction.destinationCardId);
    transactionType = TransactionType.transfer;
  } 
  else if (transaction is TransactionModel) {
    // Для обычной транзакции выбираем одну карту
    selectedCard = cards.firstWhere((c) => c.id == transaction.cardId);
    transactionType = transaction.type;
  } 
  else {
    transactionType = TransactionType.expense;
  }

  Future<void> checkCashbackOptimization(TransactionModel txn, BuildContext outerContext) async {
    // Получаем все настройки кешбэка
    final allCashbacks = await AppDatabase.instance.cashbackDao.getAllCashbacks();
    
    // Сначала ищем кешбэк для точного совпадения с категорией транзакции
    var relevantCashbacks = allCashbacks
        .where((c) => c.category == txn.category)
        .toList();
        
    // Если кешбэк не найден напрямую, проверим, является ли категория транзакции подкатегорией
    if (relevantCashbacks.isEmpty) {
      // Получаем подкатегории, чтобы найти родительскую категорию
      final subcategories = await AppDatabase.instance.categoryDao.getAllSubcategories();
      final matchingSubcat = subcategories.where(
        (s) => s.name == txn.category
      );
      
      if (matchingSubcat.isNotEmpty) {
        // Нашли подкатегорию, теперь ищем родительскую категорию
        final categories = await AppDatabase.instance.categoryDao.getAllCategories();
        final parentCategory = categories.firstWhere(
          (c) => c.id == matchingSubcat.first.categoryId,
        );
        
        // Ищем кешбэк для родительской категории
        relevantCashbacks = allCashbacks
            .where((c) => c.category == parentCategory.name)
            .toList();
    }
    }

    // Если нашли релевантные кешбэки (прямые или через родительскую категорию)
    if (relevantCashbacks.isNotEmpty) {
      final bestCashback =
          relevantCashbacks.reduce((a, b) => a.percentage > b.percentage ? a : b);
      if (bestCashback.cardId != txn.cardId) {
        final betterCard = cards.firstWhere((c) => c.id == bestCashback.cardId);
        if (outerContext.mounted) {
          ScaffoldMessenger.of(outerContext).showSnackBar(
            SnackBar(
              content: Text(
                  'Лучше использовать карту ${betterCard.name} для этой транзакции (кешбек ${bestCashback.percentage}%)'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  void handleValidationError(String message) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              transaction == null ? 'Добавить транзакцию' : 'Редактировать транзакцию',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Сумма'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Text('Дата: ${selectedDate != null ? DateFormat('dd.MM.yyyy').format(selectedDate!) : 'Сейчас/Сегодня'}'),
                        IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Выбор типа транзакции
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Расход'),
                          selected: transactionType == TransactionType.expense,
                          onSelected: (selected) {
                            setStateDialog(() {
                              transactionType = TransactionType.expense;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Доход'),
                          selected: transactionType == TransactionType.income,
                          onSelected: (selected) {
                            setStateDialog(() {
                              transactionType = TransactionType.income;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Перевод'),
                          selected: transactionType == TransactionType.transfer,
                          onSelected: (selected) {
                            setStateDialog(() {
                              transactionType = TransactionType.transfer;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Если транзакция или перевод – выбор карты/откуда
                    DropdownMenu<CardModel>(
                      initialSelection: selectedCard,
                      label: transactionType == TransactionType.transfer
                          ? const Text('Откуда?')
                          : const Text('Карта'),
                      onSelected: (newCard) {
                        setStateDialog(() {
                          selectedCard = newCard;
                        });
                      },
                      dropdownMenuEntries: cards
                          .map((card) => DropdownMenuEntry<CardModel>(
                                value: card,
                                label: card.name,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    // У перевода – выбор карты/куда
                    if (transactionType == TransactionType.transfer)
                      DropdownMenu<CardModel>(
                        initialSelection: toCard,
                        label: const Text('Куда?'),
                        onSelected: (newCard) {
                          setStateDialog(() {
                            toCard = newCard;
                          });
                        },
                        dropdownMenuEntries: cards
                            .map((card) => DropdownMenuEntry<CardModel>(
                                  value: card,
                                  label: card.name,
                                ))
                            .toList(),
                      )
                    // У транзакциии выбор категории
                    else
                      CategorySelector(
                        selectedCategory: selectedCategory,
                        onCategorySelected: (category) {
                          setStateDialog(() {
                            selectedCategory = category;
                          });
                        },
                      )
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  child: const Text('Сохранить'),
                  onPressed: () async {
                    if (selectedCard == null) {
                      handleValidationError('Выберите карту перед добавлением транзакции!');
                      return;
                    }
                    if (transactionType == TransactionType.transfer) {
                      if (toCard == null) {
                        handleValidationError('Выберите карту получателя для перевода!');
                        return;
                      }
                      if (selectedCard == toCard) {
                        handleValidationError('Карта отправителя и получателя не могут совпадать!');
                        return;
                      }
                    }
                    final parsedAmount = double.tryParse(amountController.text) ?? 0.0;
                    final newTransaction = transactionType == TransactionType.transfer
                        ? TransferModel(
                            id: transaction is TransferModel ? transaction.id : null,
                            amount: parsedAmount,
                            date: transaction?.date ?? selectedDate ?? DateTime.now(),
                            sourceCardId: selectedCard!.id!,
                            destinationCardId: toCard!.id!,
                            description: descriptionController.text,
                          )
                        : TransactionModel(
                            id: transaction is TransactionModel ? transaction.id : null,
                            amount: parsedAmount,
                            category: selectedCategory?.name ?? '',
                            date: transaction?.date ?? selectedDate ?? DateTime.now(),
                            type: transactionType,
                            cardId: selectedCard!.id!,
                            description: descriptionController.text,
                          );
        
                    if (transaction == null) {
                      // Транзакции не было, это добавление
                      if (transactionType == TransactionType.transfer) {
                        await AppDatabase.instance.transferDao.insertTransfer(newTransaction as TransferModel);
                      } else {
                        await AppDatabase.instance.transactionDao.insertTransaction(newTransaction as TransactionModel);
                      }
                    } else {
                      // Транзакция существовала, это редактирование
                      if (transactionType == TransactionType.transfer) {
                        if (transaction is TransferModel) {
                          // Перевод был и остался
                          await AppDatabase.instance.transferDao.updateTransfer(newTransaction as TransferModel);
                        } else {
                          // Перевод не был, а стал
                          await AppDatabase.instance.transferDao.deleteTransferById(transaction.id!);
                          await AppDatabase.instance.transferDao.insertTransfer(newTransaction as TransferModel);
                        }
                      } else {
                        if (transaction is TransferModel) {
                          // Перевод был, а стало что-то другое
                          await AppDatabase.instance.transferDao.deleteTransferById(transaction.id!);
                          await AppDatabase.instance.transactionDao.insertTransaction(newTransaction as TransactionModel);
                        } else {
                          // Обычная транзакция была и осталась
                          await AppDatabase.instance.transactionDao.updateTransaction(newTransaction as TransactionModel);
                        }
                      }
                    }
        
                    await onTransactionUpdated();
                    if (context.mounted) {
                      Navigator.pop(context);
                      if (newTransaction is TransactionModel) {
                        checkCashbackOptimization(newTransaction, context);
                      }
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

Future<void> confirmDeleteTransaction(BuildContext context, Function onConfirmed) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Удаление транзакции'),
      content: const Text('Вы уверены, что хотите удалить эту транзакцию?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () async {
            await onConfirmed();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
}
