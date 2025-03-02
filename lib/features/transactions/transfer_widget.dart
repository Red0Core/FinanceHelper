import 'package:finance_helper/data/models/transaction.dart';
import 'package:finance_helper/features/transactions/show_transcation_bottom_sheet.dart';
import 'package:finance_helper/features/transactions/transfer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:finance_helper/data/models/card.dart';
import 'package:go_router/go_router.dart';

class TransferWidget extends StatelessWidget {
  final TransferModel transfer;
  final List<CardModel> cards;
  final Future<void> Function() onDelete;
  final Future<void> Function() onEdit;
  const TransferWidget({
    super.key,
    required this.transfer,
    required this.cards,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final sourceCard = cards.firstWhere((c) => c.id == transfer.sourceCardId);
    final destCard = cards.firstWhere((c) => c.id == transfer.destinationCardId);
    
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Slidable(
        key: ValueKey(transfer.id),
        // Панель для свайпа влево 
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [          
            SlidableAction(
              onPressed: (context) => showTransactionBottomSheet(
                context,
                transfer,
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
            leading: const Icon(Icons.compare_arrows, color: Colors.blue),
            title: const Text('Перевод', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${sourceCard.name} → ${destCard.name}'),
            trailing: Text(
              NumberFormat.currency(symbol: '₽').format(transfer.amount),
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            onTap: () => context.push(
              '/transfer/${transfer.id}',
              extra: TransferDetailArguments(
                  transfer: transfer,
                  sourceCard: sourceCard,
                  destinationCard: destCard,
                ),
              ),
          ),
      ),
    );
  }
}