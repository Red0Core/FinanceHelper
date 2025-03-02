import 'package:finance_helper/data/database.dart';
import 'package:finance_helper/features/cashback/cashback_screen.dart';
import 'package:finance_helper/features/home/home_screen.dart';
import 'package:finance_helper/features/transactions/transaction_detail_screen.dart';
import 'package:finance_helper/features/transactions/transactions_screen.dart';
import 'package:finance_helper/features/transactions/transfer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.recreateAndFillDatabaseWithTestData();
  await AppDatabase.instance.setDefaultCategories();
  await initializeDateFormatting('ru_RU', null);
  Intl.defaultLocale = 'ru_RU';

  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Finance Helper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/transfer/:id',
      builder: (context, state) {
        final args = state.extra as TransferDetailArguments;
        return TransferDetailScreen(
          transfer: args.transfer,
          sourceCard: args.sourceCard,
          destinationCard: args.destinationCard,
        );
      },
    ),
    GoRoute(
      path: '/transaction/:id',
      builder: (context, state) {
        final args = state.extra as TransactionDetailArguments;
        return TransactionDetailScreen(transaction: args.transaction, cardName: args.cardName);
      }
    ),
  ],
);

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  VoidCallback fabCallback = () {};

  // Метод для обновления FAB callback, который можно передавать в дочерние экраны.
  void updateFABCallback(VoidCallback callback) {
    setState(() {
      fabCallback = callback;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(), // Позволяет свайпать между экранами
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            HomeScreen(setFABCallback: updateFABCallback),
            TransactionsScreen(setFABCallback: updateFABCallback),
            CashbackScreen(setFABCallback: updateFABCallback),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Кошелек'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Транзакции'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Кешбек'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fabCallback,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat
    );
  }
}
