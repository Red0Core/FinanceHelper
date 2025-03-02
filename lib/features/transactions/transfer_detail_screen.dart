import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance_helper/data/models/transaction.dart';
import 'package:finance_helper/data/models/card.dart';
import 'package:go_router/go_router.dart';

class TransferDetailArguments {
  final TransferModel transfer;
  final CardModel sourceCard;
  final CardModel destinationCard;
  
  TransferDetailArguments({
    required this.transfer,
    required this.sourceCard,
    required this.destinationCard,
  });
}

class TransferDetailScreen extends StatelessWidget {
  final TransferModel transfer;
  final CardModel sourceCard;
  final CardModel destinationCard;

  const TransferDetailScreen({
    super.key,
    required this.transfer,
    required this.sourceCard,
    required this.destinationCard,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('dd MMM yyyy, HH:mm').format(transfer.date);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали перевода'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Перевод',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                NumberFormat.currency(locale: 'ru_RU', symbol: '₽').format(transfer.amount),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.arrow_downward, color: Colors.red),
                        title: const Text('Источник'),
                        subtitle: Text(sourceCard.name),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.arrow_upward, color: Colors.lightGreen),
                        title: const Text('Назначение'),
                        subtitle: Text(destinationCard.name),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Дата'),
                        subtitle: Text(dateFormatted),
                      ),
                      if (transfer.description != null && transfer.description!.isNotEmpty) ...[
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(transfer.description!)
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}