import 'package:finance_helper/data/database.dart';
import 'package:flutter/material.dart';
import 'package:finance_helper/data/models/transaction.dart';
import 'package:finance_helper/data/models/card.dart';

Future<void> showTransactionBottomSheet(
    BuildContext context,
    TransactionModel? transaction,
    List<CardModel> cards,
    Function onTransactionUpdated) async {
  TextEditingController amountController =
      TextEditingController(text: transaction?.amount.toString() ?? '');
  TextEditingController categoryController =
      TextEditingController(text: transaction?.category ?? '');
  CardModel? selectedCard = transaction != null
      ? cards.firstWhere((c) => c.id == transaction.cardId)
      : null;
  String transactionType = transaction?.type ?? 'expense';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            transaction == null ? 'Добавить транзакцию' : 'Редактировать транзакцию',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Сумма'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Категория'),
          ),
          const SizedBox(height: 12),
          StatefulBuilder(
            builder: (context, setStateDialog) {
              return DropdownButton<CardModel?>(
                value: selectedCard,
                hint: const Text('Выберите карту'),
                onChanged: (newCard) {
                  setStateDialog(() {
                    selectedCard = newCard;
                  });
                },
                items: cards.map((card) {
                  return DropdownMenuItem<CardModel?>(
                    value: card,
                    child: Text(card.name),
                  );
                }).toList(),
              );
            }
          ),
          const SizedBox(height: 12),
          StatefulBuilder(
            builder: (context, setStateDialog) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Расход'),
                    selected: transactionType == 'expense',
                    onSelected: (selected) {
                      setStateDialog(() {
                        transactionType = 'expense';
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Доход'),
                    selected: transactionType == 'income',
                    onSelected: (selected) {
                      setStateDialog(() {
                        transactionType = 'income';
                      });
                    },
                  ),
                ],
              );
            }
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
                onPressed: () async {
                  if (selectedCard == null) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Выберите карту перед добавлением транзакции!')),
                      );
                    }
                    return;
                  }

                  final newTransaction = TransactionModel(
                    id: transaction?.id,
                    amount: double.tryParse(amountController.text) ?? 0.0,
                    category: categoryController.text,
                    date: transaction?.date ?? DateTime.now(),
                    type: transaction?.type ?? 'expense',
                    cardId: selectedCard!.id!,
                  );

                  if (transaction == null) {
                    await AppDatabase.instance.transactionDao.insertTransaction(newTransaction);
                  } else {
                    await AppDatabase.instance.transactionDao.updateTransaction(newTransaction);
                  }

                  await onTransactionUpdated();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Сохранить'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

Future<void> confirmDeleteTransaction(BuildContext context, int id, Function onConfirmed) async {
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