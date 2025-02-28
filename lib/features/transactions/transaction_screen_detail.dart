import 'package:flutter/material.dart';
import 'package:finance_helper/data/database.dart';
import 'package:finance_helper/data/models/transaction.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final int transactionId;
  const TransactionDetailsScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  TransactionModel? _transaction;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    final transaction = await AppDatabase.instance.transactionDao.getTransactionById(widget.transactionId);
    if (!mounted) return;
    setState(() {
      _transaction = transaction;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: const Text('Детали транзакции'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(), // Используем context.pop() для возврата назад
              ),
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transaction == null
                ? const Center(child: Text('Транзакция не найдена'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Text('Категория: ${_transaction!.category}'),
                        Text('Сумма: ${_transaction!.amount}'),
                        Text('Дата: ${_transaction!.date}'),
                        Text('Тип: ${_transaction!.type}'),
                      ],
                    ),
                  ),
    );
  }
}
