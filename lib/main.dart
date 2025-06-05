import 'package:flutter/material.dart';
import 'package:my_finance_mobile/pages/edit_expense_form.dart';
import 'package:my_finance_mobile/pages/expenses_summary.dart';
import 'package:my_finance_mobile/pages/home.dart';
import 'package:my_finance_mobile/pages/login.dart';
import 'package:my_finance_mobile/pages/register_form.dart';
import 'package:my_finance_mobile/pages/show_expense.dart';
import 'package:my_finance_mobile/pages/create_expense_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Finance App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/register': (context) => const RegisterForm(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/summary': (context) => const ExpensesSummary(),
        '/create-expense': (context) => const CreateExpenseForm(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/show-expense') {
          final expense = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ShowExpensePage(expense: expense),
          );
        }
        if (settings.name == '/edit-expense') {
          final expense = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => EditExpenseForm(expense: expense),
          );
        }
        return null;
      },
    );
  }
}
