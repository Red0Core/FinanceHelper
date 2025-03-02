import 'package:finance_helper/features/transactions/show_transcation_bottom_sheet.dart';
import 'package:finance_helper/features/transactions/transaction_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:finance_helper/data/models/transaction.dart';
import 'package:finance_helper/data/models/card.dart';
import 'package:go_router/go_router.dart';

// Карточка транзакции в списке транзакций
class TransactionWidget extends StatelessWidget {
  final TransactionModel transaction;
  final List<CardModel> cards;
  final Future<void> Function() onDelete;
  final Future<void> Function() onEdit;

  const TransactionWidget({
    super.key,
    required this.transaction,
    required this.cards,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final card = cards.firstWhere((c) => c.id == transaction.cardId);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Slidable(
        key: ValueKey(transaction.id),
        // Панель для свайпа влево 
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [          
            SlidableAction(
              onPressed: (context) => showTransactionBottomSheet(
                context,
                transaction,
                cards,
                onEdit
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              autoClose: true,
            ),
            SlidableAction(
              onPressed: (context) async => await onDelete(),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
              autoClose: true,
            ),
          ],
        ),
        child: ListTile(
          title: Text(transaction.category, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              '${NumberFormat.currency(symbol: '₽').format(transaction.amount)} • '
              '${card.name} • '
              '${DateFormat("dd MMM yyyy").format(transaction.date)}'
          ),
          trailing: Icon(
            transaction.type == TransactionType.expense ? Icons.arrow_downward : Icons.arrow_upward,
            color: transaction.type == TransactionType.expense ? Colors.red : Colors.green,
          ),
          onTap: () => context.push(
            '/transaction/${transaction.id}',
            extra: TransactionDetailArguments(transaction: transaction, cardName: card.name),
          ),
        ),
      )
    );
  }
}
