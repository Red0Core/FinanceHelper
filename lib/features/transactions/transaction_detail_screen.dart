import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance_helper/data/models/transaction.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailArguments {
  final TransactionModel transaction;
  final String cardName;

  TransactionDetailArguments({
    required this.transaction,
    required this.cardName,
  });
}

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;
  final String cardName;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.cardName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(transaction.date);
    final amountFormatted = NumberFormat.currency(locale: 'ru_RU', symbol: '₽').format(transaction.amount);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали транзакции'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Заголовок с категорией транзакции
              Text(
                transaction.category,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Отображаем сумму
              Text(
                amountFormatted,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: transaction.type == TransactionType.expense ? Colors.redAccent : Colors.lightGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Карточка с деталями
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.credit_card),
                        title: const Text('Карта'),
                        subtitle: Text(cardName),
                      ),
                      const Divider(),

                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Дата'),
                        subtitle: Text(formattedDate),
                      ),
                      const Divider(),
                      
                      transaction.type == TransactionType.expense
                      ? ListTile(
                          leading: const Icon(Icons.arrow_downward, color: Colors.red),
                          title: const Text('Расход'),
                        )
                      : ListTile(
                          leading: const Icon(Icons.arrow_upward, color: Colors.lightGreen),
                          title: const Text('Доход'),
                        ),
                      
                      if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(transaction.description!)
                        ),  
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Кнопка закрытия экрана
              ElevatedButton.icon(
                onPressed: () => context.pop(),
                label: const Text('Закрыть', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}