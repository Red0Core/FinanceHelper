import 'package:finance_helper/data/models/category.dart';
import 'package:finance_helper/features/category/category_selector.dart';
import 'package:flutter/material.dart';
import 'package:finance_helper/data/database.dart';
import 'package:finance_helper/data/models/cashback.dart';
import 'package:finance_helper/data/models/card.dart';

class CashbackScreen extends StatefulWidget {
  final Function(VoidCallback callback) setFABCallback;
  const CashbackScreen({super.key, required this.setFABCallback});

  @override
  State<CashbackScreen> createState() => _CashbackScreenState();
}

class _CashbackScreenState extends State<CashbackScreen> {
  List<CashbackModel> _cashbacks = [];
  List<CardModel> _cards = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setFABCallback(_showCashbackDialog);
    });
    _loadData();
  }

  Future<void> _loadData() async {
    final cashbacks = await AppDatabase.instance.cashbackDao.getAllCashbacks();
    final cards = await AppDatabase.instance.cardDao.getAllCards();
    setState(() {
      _cashbacks = cashbacks;
      _cards = cards;
    });
  }

  // Вспомогательный метод для получения объекта категории по имени
  Future<CategoryInterface?> categoryFromName(String name) async {
    final categories = await AppDatabase.instance.categoryDao.getAllCategories();
    final subcategories = await AppDatabase.instance.categoryDao.getAllSubcategories();
    
    // Проверяем сначала в подкатегориях, затем в категориях
    final allCategoriesAndSubcategories = [...subcategories, ...categories];
    try {
      return allCategoriesAndSubcategories.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  Future<void> _showCashbackDialog([CashbackModel? cashback]) async {
    // Определяем, режим редактирования или добавления
    final bool isEditing = cashback != null;
    
    // Инициализируем контроллеры с начальными значениями
    TextEditingController percentageController = TextEditingController(
      text: isEditing ? cashback.percentage.toString() : ''
    );
    
    CategoryInterface? dialogSelectedCategory = 
      isEditing ? await categoryFromName(cashback.category) : null;

    // Выбираем карту (null для нового кешбэка или существующую для редактирования)
    CardModel? selectedCard = 
      isEditing 
      ? _cards.firstWhere((c) => c.id == cashback.cardId)
      : null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(isEditing ? 'Редактировать кешбек' : 'Добавить кешбек'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CategorySelector(
                  selectedCategory: dialogSelectedCategory,
                  onCategorySelected: (category) {
                    setStateDialog(() {
                      dialogSelectedCategory = category;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownMenu<CardModel>(
                  initialSelection: selectedCard,
                  label: const Text('Выберите карту'),
                  onSelected: (newCard) {
                    setStateDialog(() {
                      selectedCard = newCard;
                    });
                  },
                  dropdownMenuEntries: _cards.map((card) {
                    return DropdownMenuEntry<CardModel>(
                      value: card,
                      label: card.name,
                    );
                  }).toList()
                ),
                TextField(
                  controller: percentageController,
                  decoration: const InputDecoration(labelText: 'Процент кешбека'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Валидация полей
                  if (selectedCard == null || 
                      dialogSelectedCategory == null || 
                      percentageController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Заполните все поля!')),
                    );
                    return;
                  }

                  final model = CashbackModel(
                    id: isEditing ? cashback.id : null,
                    cardId: selectedCard!.id!,
                    category: dialogSelectedCategory!.name,
                    percentage: double.tryParse(percentageController.text) ?? 
                              (isEditing ? cashback.percentage : 0.0),
                  );

                  // Сохраняем или обновляем в зависимости от режима
                  if (isEditing) {
                    await AppDatabase.instance.cashbackDao.updateCashback(model);
                  } else {
                    await AppDatabase.instance.cashbackDao.insertCashback(model);
                  }
                  
                  // Перезагружаем данные и закрываем диалог
                  _loadData();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteCashback(int id) async {
    await AppDatabase.instance.cashbackDao.deleteCashback(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кешбеки'),
      ),
      body: ListView.builder(
        itemCount: _cashbacks.length,
        itemBuilder: (context, index) {
          final cashback = _cashbacks[index];
          final card = _cards.firstWhere((c) => c.id == cashback.cardId, orElse: () => CardModel(id: -1, name: 'Неизвестная карта'));
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('${cashback.category} - ${cashback.percentage}%'),
              subtitle: Text('Карта: ${card.name}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showCashbackDialog(cashback),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCashback(cashback.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
